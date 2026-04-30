import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';

class DashboardScreenContent extends ConsumerWidget {
  const DashboardScreenContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryState = ref.watch(inventoryProvider);
    
    // Group items by type for Warehouse Overview
    final Map<String, int> typeCounts = {};
    for (var row in inventoryState.matrix) {
      for (var item in row) {
        if (item != null && item.productType.isNotEmpty) {
          typeCounts[item.productType] = (typeCounts[item.productType] ?? 0) + 1;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          _buildTopBar(),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildOverviewCard(
                        "WAREHOUSE OVERVIEW", 
                        flex: 6,
                        content: typeCounts.isEmpty 
                          ? const Center(child: Text("No items stored", style: TextStyle(color: Colors.grey)))
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 3.5,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: typeCounts.length,
                                itemBuilder: (context, index) {
                                  final type = typeCounts.keys.elementAt(index);
                                  final count = typeCounts[type];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2)],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            type, 
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navyMid),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          "$count", 
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.gold),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                      ),
                      const SizedBox(width: 20),
                      _buildOverviewCard(
                        "VENTO OVERVIEW", 
                        flex: 4,
                        content: _buildBarChart(inventoryState.matrix),
                        action: IconButton(
                          onPressed: () => _confirmClear(context, ref),
                          icon: const Icon(Icons.delete_sweep, color: AppColors.errorRed),
                          tooltip: "Clear All Items",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildRecentLoginTable(inventoryState.history),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagramStep(String label, String sublabel, IconData icon) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.navyMid, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navyMid)),
              Text(sublabel, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Image.asset("assets/images/vento.png", height: 54, fit: BoxFit.contain),
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
                      color: Color(0xFF90A4AE), // Greyish circle background
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
          const SizedBox(width: 30),
          Image.asset("assets/images/dashboard.png", height: 24, fit: BoxFit.contain),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String title, {required int flex, required Widget content, Widget? action}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 350,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.ventoYellow.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)],
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(color: Color(0xFF003666), fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 24),
                    ),
                  ),
                  if (action != null) action,
                ],
              ),
            ),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<List<InventoryItem?>> matrix) {
    final Map<String, int> typeQuantities = {};
    int maxQty = 10;

    for (var row in matrix) {
      for (var item in row) {
        if (item != null) {
          final type = item.productType.split(' ').first;
          typeQuantities[type] = (typeQuantities[type] ?? 0) + item.quantity;
          if (typeQuantities[type]! > maxQty) maxQty = typeQuantities[type]!;
        }
      }
    }

    if (typeQuantities.isEmpty) {
      return const Center(child: Text("No data for graph", style: TextStyle(color: Colors.grey)));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: typeQuantities.entries.map((e) {
          final heightFactor = (e.value / maxQty).clamp(0.1, 1.0);
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("${e.value}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.navyMid)),
              const SizedBox(height: 4),
              Container(
                width: 30,
                height: 180 * heightFactor,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.gold, AppColors.ventoYellow],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 40,
                child: Text(
                  e.key, 
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All Items?"),
        content: const Text("This will permanently remove all items from the warehouse engine."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              ref.read(inventoryProvider.notifier).clearInventory();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text("Clear Everything", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLoginTable(List<dynamic> history) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.ventoYellow.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
              ),
              child: Text(
                "RECENT ACTIVITY",
                style: TextStyle(
                  color: const Color(0xFF003666),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  shadows: [Shadow(blurRadius: 4, color: Colors.white.withValues(alpha: 0.8))],
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(color: AppColors.ventoYellow, borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 3, child: _buildHeaderText("PRODUCT")),
                Expanded(flex: 2, child: _buildHeaderText("TYPE")),
                Expanded(flex: 1, child: _buildHeaderText("QTY")),
                Expanded(flex: 2, child: _buildHeaderText("PRICE")),
                Expanded(flex: 2, child: _buildHeaderText("TIME")),
              ],
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? const Center(child: Text("No recent activity", style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: history.length > 5 ? 5 : history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(flex: 3, child: Text(item.item, style: const TextStyle(fontWeight: FontWeight.w500))),
                            Expanded(flex: 2, child: Text(item.productType, style: const TextStyle(color: Colors.grey))),
                            Expanded(flex: 1, child: Text("${item.qty}")),
                            Expanded(flex: 2, child: Text("₱${item.price.toStringAsFixed(2)}")),
                            Expanded(flex: 2, child: Text(DateFormat('HH:mm').format(item.timestamp))),
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

  Widget _buildHeaderText(String text) {
    return Text(
      text,
      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF003666), shadows: [Shadow(blurRadius: 2, color: Colors.white)]),
    );
  }
}
