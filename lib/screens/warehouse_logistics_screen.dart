import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../widgets/sidebar_panels/add_inventory_panel.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';

class WarehouseLogisticsContent extends ConsumerWidget {
  const WarehouseLogisticsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryState = ref.watch(inventoryProvider);
    final selectedItem = ref.watch(selectedItemProvider);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              // Center Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "WAREHOUSE LOGISTICS",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.sort_by_alpha, color: AppColors.navyMid),
                              tooltip: "Sort Matrix",
                              onPressed: () => ref.read(inventoryProvider.notifier).sortMatrix(),
                            ),
                            IconButton(
                              icon: const Icon(Icons.undo, color: AppColors.navyMid),
                              tooltip: "Undo Last",
                              onPressed: () => ref.read(inventoryProvider.notifier).undoLast(),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: AppColors.navyMid),
                              tooltip: "Refresh",
                              onPressed: () => ref.read(inventoryProvider.notifier).refreshState(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.panelBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: inventoryState.isLoading && inventoryState.matrix.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : _buildStorageGrid(inventoryState.matrix, ref),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.panelBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: _buildInventoryList(inventoryState.matrix),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right Column
              SizedBox(
                width: 320,
                child: Column(
                  children: [
                    const Expanded(flex: 3, child: AddInventoryPanel()),
                    const SizedBox(height: 24),
                    Expanded(flex: 2, child: _buildHistoryPanel(inventoryState.history, ref)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (selectedItem != null)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => ref.read(selectedItemProvider.notifier).state = null,
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(
                  child: _buildItemDetailsCard(selectedItem, ref),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildItemDetailsCard(InventoryItem item, WidgetRef ref) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: AppColors.ventoYellow,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    item.productType,
                    style: const TextStyle(
                      color: AppColors.ventoYellow,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    item.inventoryPlace,
                    style: const TextStyle(
                      color: AppColors.ventoYellow,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => ref.read(selectedItemProvider.notifier).state = null,
                icon: const Icon(Icons.close, color: AppColors.ventoYellow, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Date:", DateFormat('MMMM dd, yyyy').format(item.startTime ?? DateTime.now())),
                    _buildDetailRow("Time in:", DateFormat('hh:mm a').format(item.startTime ?? DateTime.now())),
                    _buildDetailRow("Quantity:", item.quantity.toString()),
                    _buildDetailRow("Price:", "₱${item.price.toStringAsFixed(2)}"),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2, color: AppColors.navyDark, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Implement disregard logic here
                ref.read(selectedItemProvider.notifier).state = null;
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.successGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "Disregard",
                style: TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11, color: AppColors.successGreen),
          children: [
            TextSpan(text: "$label ", style: const TextStyle(fontWeight: FontWeight.w300)),
            TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Image.asset(
            "assets/images/vento.png",
            height: 54,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF90A4AE),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Image.asset("assets/images/vento_search.png", fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: TextField(
                      style: TextStyle(color: Color(0xFF0F1628), fontSize: 18),
                      decoration: InputDecoration(
                        hintText: "Search inventory ...",
                        hintStyle: TextStyle(color: Color(0xFFD1D1D1), fontSize: 18, fontWeight: FontWeight.w300),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: AppColors.ventoYellow.withValues(alpha: 0.8), size: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageGrid(List<List<InventoryItem?>> matrix, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 100,
      itemBuilder: (context, index) {
        final row = index ~/ 10;
        final col = index % 10;
        final item = (matrix.length > row && matrix[row].length > col) ? matrix[row][col] : null;

        return GestureDetector(
          onTap: () {
            if (item != null) {
              ref.read(selectedItemProvider.notifier).state = item;
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: item != null ? AppColors.offWhite : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Stack(
              children: [
                if (item != null)
                  Center(
                    child: Icon(Icons.inventory_2, size: 20, color: AppColors.navyMid.withOpacity(0.5)),
                  ),
                if (item != null)
                  const Positioned(
                    top: 2,
                    right: 2,
                    child: Icon(Icons.info_outline, size: 10, color: AppColors.navyMid),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInventoryList(List<List<InventoryItem?>> matrix) {
    final List<InventoryItem> items = [];
    for (var row in matrix) {
      for (var item in row) {
        if (item != null) items.add(item);
      }
    }

    if (items.isEmpty) {
      return const Center(child: Text("No items in inventory", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.navyMid,
                child: const Icon(Icons.inventory_2, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 3,
                child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),
              Expanded(
                flex: 2,
                child: Text("${item.quantity} units", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
              Expanded(
                flex: 2,
                child: Text("₱${item.price.toStringAsFixed(2)}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
              Expanded(
                flex: 2,
                child: Text(item.startTime != null ? DateFormat('MM/dd').format(item.startTime!) : "-", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryPanel(List<ActionLog> history, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.navyMid,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(PhosphorIcons.clockCounterClockwise(), color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text("Inventory History", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? const Center(child: Text("No history...", style: TextStyle(color: Colors.grey, fontSize: 12)))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final log = history[index];
                      final isAdd = log.action == "ADD";
                      final bgColor = isAdd ? const Color(0xFFA8E6CF) : const Color(0xFFFF8B94);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.item,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${isAdd ? 'Admitted Time' : 'Omitted time'} ${DateFormat('M/d/yyyy HH:mm').format(log.timestamp)}",
                                    style: const TextStyle(fontSize: 10, color: Colors.black45),
                                  ),
                                  Text(
                                    log.productType,
                                    style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 11, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            if (!isAdd)
                              InkWell(
                                onTap: () => ref.read(inventoryProvider.notifier).undoLast(),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "UNDO",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
