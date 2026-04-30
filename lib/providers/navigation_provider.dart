import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationState {
  final int index;
  final int refreshVersion;
  NavigationState({required this.index, required this.refreshVersion});
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState(index: 0, refreshVersion: 0));

  void setIndex(int newIndex) {
    if (state.index == newIndex) {
      // Same index clicked: update version to trigger a refresh
      state = NavigationState(
        index: newIndex, 
        refreshVersion: state.refreshVersion + 1
      );
    } else {
      // New index clicked: reset version
      state = NavigationState(index: newIndex, refreshVersion: 0);
    }
  }
}

final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>((ref) => NavigationNotifier());
