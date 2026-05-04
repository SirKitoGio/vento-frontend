import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/inventory_service.dart';
import '../models/inventory_item.dart';

class InventoryState {
  final List<List<InventoryItem?>> matrix;
  final int queueSize;
  final List<ActionLog> history;
  final List<InventoryItem> searchResults;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  InventoryState({
    required this.matrix,
    required this.queueSize,
    required this.history,
    this.searchResults = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  InventoryState copyWith({
    List<List<InventoryItem?>>? matrix,
    int? queueSize,
    List<ActionLog>? history,
    List<InventoryItem>? searchResults,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return InventoryState(
      matrix: matrix ?? this.matrix,
      queueSize: queueSize ?? this.queueSize,
      history: history ?? this.history,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class InventoryNotifier extends StateNotifier<InventoryState> {
  final InventoryService _service;

  InventoryNotifier(this._service) : super(InventoryState(matrix: [], queueSize: 0, history: [])) {
    refreshState();
  }

  Future<void> searchItems(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchQuery: '', searchResults: []);
      return;
    }

    state = state.copyWith(searchQuery: query, isLoading: true);
    try {
      final results = await _service.search(query);
      state = state.copyWith(searchResults: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshState() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getState();
      
      // Parse matrix (assuming it's a 2D array of slots)
      final List<dynamic> matrixData = data['matrix'] ?? [];
      
      // Actually the backend StateHandler returns s.Engine.Matrix.GetState()
      // Let's map it to our 10x10 grid.
      List<List<InventoryItem?>> parsedMatrix = [];
      for (var i = 0; i < 10; i++) {
        List<InventoryItem?> row = [];
        for (var j = 0; j < 10; j++) {
          if (i < matrixData.length && j < matrixData[i].length) {
            final slot = matrixData[i][j];
            if (slot != null && (slot['item_name'] != "" && slot['item_name'] != null)) {
              row.add(InventoryItem.fromJson(slot));
            } else {
              row.add(null);
            }
          } else {
            row.add(null);
          }
        }
        parsedMatrix.add(row);
      }

      final List<dynamic> historyData = data['history'] ?? [];
      final history = historyData.map((h) => ActionLog.fromJson(h)).toList();

      state = state.copyWith(
        matrix: parsedMatrix,
        queueSize: data['queue_size'] ?? 0,
        history: history,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> ingestItem(InventoryItem item) async {
    try {
      await _service.ingest(item);
      await refreshState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> undoLast() async {
    try {
      await _service.undo();
      await refreshState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> sortMatrix() async {
    try {
      await _service.sort();
      await refreshState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearInventory() async {
    try {
      await _service.clearAll();
      await refreshState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final inventoryServiceProvider = Provider((ref) => InventoryService());

final inventoryProvider = StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  final service = ref.watch(inventoryServiceProvider);
  return InventoryNotifier(service);
});
