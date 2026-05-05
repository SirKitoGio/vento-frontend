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
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    final mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile) ...[
          _buildTopBar(),
          const SizedBox(height: 20),
        ],
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
        if (isMobile)
          SizedBox(
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.panelBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: inventoryState.isLoading && inventoryState.matrix.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _buildStorageGrid(inventoryState.matrix, isMobile),
            ),
          )
        else
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
                  : _buildStorageGrid(inventoryState.matrix, isMobile),
            ),
          ),
        const SizedBox(height: 24),
        if (isMobile)
          SizedBox(
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.panelBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: _buildInventoryList(inventoryState.matrix, isMobile),
            ),
          )
        else
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.panelBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: _buildInventoryList(inventoryState.matrix, isMobile),
            ),
          ),
      ],
    );

    final sidePanel = Column(
      children: [
        if (isMobile)
          const SizedBox(height: 300, child: AddInventoryPanel())
        else
          const Expanded(flex: 3, child: AddInventoryPanel()),
        const SizedBox(height: 24),
        if (isMobile)
          SizedBox(height: 250, child: _buildHistoryPanel(inventoryState.history))
        else
          Expanded(flex: 2, child: _buildHistoryPanel(inventoryState.history)),
      ],
    );

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: isMobile 
          ? SingleChildScrollView(
              child: Column(
                children: [
                  mainContent,
                  const SizedBox(height: 30),
                  sidePanel,
                ],
              ),
            )
          : Row(
              children: [
                Expanded(child: mainContent),
                const SizedBox(width: 24),
                SizedBox(width: 320, child: sidePanel),
              ],
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
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        return TextField(
                          style: const TextStyle(color: Color(0xFF0F1628), fontSize: 18),
                          onChanged: (value) => ref.read(inventoryProvider.notifier).searchItems(value),
                          decoration: const InputDecoration(
                            hintText: "Search inventory ...",
                            hintStyle: TextStyle(color: Color(0xFFD1D1D1), fontSize: 18, fontWeight: FontWeight.w300),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        );
                      },
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

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Physical Inventory': return PhosphorIcons.package(PhosphorIconsStyle.regular);
      case 'Finished Goods': return PhosphorIcons.checkCircle(PhosphorIconsStyle.regular);
      case 'Maintenance & Repair': return PhosphorIcons.wrench(PhosphorIconsStyle.regular);
      case 'Consumable Supplies': return PhosphorIcons.batteryFull(PhosphorIconsStyle.regular);
      case 'Food & Beverage': return PhosphorIcons.coffee(PhosphorIconsStyle.regular);
      case 'Retail Merchandise': return PhosphorIcons.tag(PhosphorIconsStyle.regular);
      case 'Components': return PhosphorIcons.puzzlePiece(PhosphorIconsStyle.regular);
      case 'Spare Parts': return PhosphorIcons.gear(PhosphorIconsStyle.regular);
      case 'Custom': return PhosphorIcons.dotsThree(PhosphorIconsStyle.regular);
      default: return PhosphorIcons.package(PhosphorIconsStyle.regular);
    }
  }

  Widget _buildStorageGrid(List<List<InventoryItem?>> matrix, bool isMobile) {
    return Consumer(
      builder: (context, ref, child) {
        final inventoryState = ref.watch(inventoryProvider);
        final searchQuery = inventoryState.searchQuery.toLowerCase();
        final searchResults = inventoryState.searchResults;
        final isSearching = searchQuery.isNotEmpty;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 5 : 10,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 100,
          itemBuilder: (context, index) {
            final row = index ~/ 10;
            final col = index % 10;
            final item = (matrix.length > row && matrix[row].length > col) ? matrix[row][col] : null;

            bool isMatch = false;
            if (isSearching && item != null) {
              isMatch = searchResults.any((res) => res.name == item.name);
            }

            double opacity = 1.0;
            if (isSearching) {
              opacity = isMatch ? 1.0 : 0.3;
            }

            return Tooltip(
              message: item != null 
                  ? "${item.name}\nQty: ${item.quantity}\nPlace: ${item.inventoryPlace}" 
                  : "Empty Slot",
              child: Opacity(
                opacity: opacity,
                child: Container(
                  decoration: BoxDecoration(
                    color: item != null ? AppColors.gridOccupied : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isMatch ? AppColors.ventoYellow : AppColors.borderLight,
                      width: isMatch ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: item != null 
                        ? Icon(_getIconForType(item.productType), color: AppColors.navyMid, size: 16) 
                        : null,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInventoryList(List<List<InventoryItem?>> matrix, bool isMobile) {
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
        
        final rowContent = Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.navyMid,
              child: const Icon(Icons.inventory_2, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 15),
            if (isMobile) ...[
              SizedBox(
                width: 120,
                child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
              ),
              SizedBox(
                width: 80,
                child: Text("${item.quantity} units", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
              SizedBox(
                width: 100,
                child: Text("₱${item.price.toStringAsFixed(2)}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
              SizedBox(
                width: 60,
                child: Text(item.startTime != null ? DateFormat('MM/dd').format(item.startTime!) : "-", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
            ] else ...[
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
          ],
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: isMobile 
              ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: rowContent)
              : rowContent,
        );
      },
    );
  }

  Widget _buildHistoryPanel(List<ActionLog> history) {
    final reversedHistory = history.reversed.toList();
    const int minItems = 6;
    final int displayCount = reversedHistory.length > minItems ? reversedHistory.length : minItems;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.navyMid,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(PhosphorIcons.clipboardText(), color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Text(
                  "Inventory History",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Expanded(
            child: Theme(
              data: ThemeData(
                scrollbarTheme: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(Colors.grey[700]),
                  thickness: WidgetStateProperty.all(8),
                  radius: const Radius.circular(8),
                  thumbVisibility: WidgetStateProperty.all(true),
                ),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: displayCount,
                  itemBuilder: (context, index) {
                    if (index < reversedHistory.length) {
                      final log = reversedHistory[index];
                      final isAdd = log.action == "ADD";
                      final bgColor = isAdd ? const Color(0xFFBCE3AD) : const Color(0xFFE0B0AE);
                      final borderColor = isAdd ? const Color(0xFF9CC98B) : const Color(0xFFC99593);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.item,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${isAdd ? 'Admitted Time' : 'Omitted time'} ${DateFormat('M/d/yyyy HH:mm').format(log.timestamp)}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Placeholder
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        height: 70, // Roughly matching the height of actual items
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD0D0D0)),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
