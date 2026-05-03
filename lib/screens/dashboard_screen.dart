import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';

class DashboardScreenContent extends ConsumerWidget {
  const DashboardScreenContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryState = ref.watch(inventoryProvider);

    if (inventoryState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text("Error: ${inventoryState.error}", style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () => ref.read(inventoryProvider.notifier).refreshState(),
              child: const Text("Retry"),
            )
          ],
        ),
      );
    }

    if (inventoryState.isLoading && inventoryState.matrix.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Calculate stats safely
    final items = inventoryState.matrix
        .expand((row) => row)
        .where((item) => item != null)
        .cast<InventoryItem>()
        .toList();
    
    // Group by product type for chart
    Map<String, int> typeCounts = {};
    for (var item in items) {
      if (item.productType.isNotEmpty) {
        typeCounts[item.productType] = (typeCounts[item.productType] ?? 0) + item.quantity;
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWarehouseOverview(items),
                      const SizedBox(width: 20),
                      _buildVentoOverview(typeCounts),
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

  Widget _buildWarehouseOverview(List<InventoryItem> items) {
    // Calculate total capacity (assuming 100 from backend 10x10 matrix)
    final totalCapacity = 100;
    final filledSlots = items.length;
    final utilizationPercentage = totalCapacity > 0 ? (filledSlots / totalCapacity * 100).round() : 0;

    return Expanded(
      flex: 5,
      child: Container(
        height: 393,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.ventoYellow.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader("WAREHOUSE OVERVIEW"),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1,
                      ),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        // Only show the utilization gear icon in the first slot if there are items
                        if (index == 0 && items.isNotEmpty) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(color: Colors.black.withOpacity(0.11)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.settings, size: 45, color: Color(0xFF011D3F)),
                                const SizedBox(height: 5),
                                Text(
                                  "%$utilizationPercentage",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF011D3F),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        // Render empty slots
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: Colors.black.withOpacity(0.11)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.warehouse, color: AppColors.navyDark, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVentoOverview(Map<String, int> typeCounts) {
    // Debugging: Print counts to console to see what's actually in the provider
    print("Dashboard TypeCounts: $typeCounts");

    // Total items to calculate percentages
    int total = typeCounts.values.fold(0, (sum, count) => sum + count);
    print("Dashboard Total Units: $total");
    
    double getPercentage(List<String> types) {
      if (total == 0) return 0;
      int sum = 0;
      // Use contains to be more flexible with the names from the dropdown
      typeCounts.forEach((key, value) {
        for (var type in types) {
          if (key.contains(type)) {
            sum += value;
          }
        }
      });
      return (sum / total * 100).roundToDouble();
    }

    final List<Map<String, dynamic>> chartData = [
      {
        'name': 'MROS', 
        'value': getPercentage(['Maintenance & Repair', 'Spare Parts', 'MROS']), 
        'color': const Color(0xFF011D3F)
      },
      {
        'name': 'Food & Beverages', 
        'value': getPercentage(['Food & Beverage']), 
        'color': const Color(0xFF023566)
      },
      {
        'name': 'Retail Merchandise', 
        'value': getPercentage(['Retail Merchandise']), 
        'color': const Color(0xFF011D3F)
      },
      {
        'name': 'Finished Goods', 
        'value': getPercentage(['Finished Goods']), 
        'color': const Color(0xFF023566)
      },
    ];

    return Expanded(
      flex: 5,
      child: Container(
        height: 393,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.ventoYellow.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader("VENTO OVERVIEW"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      minY: 0,
                      barGroups: chartData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data['value'] > 0 ? data['value'] : 0.1, // Small 0.1 to show a sliver if it's zero but present
                              color: data['color'],
                              width: 50,
                              borderRadius: BorderRadius.zero,
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 100,
                                color: const Color(0xFFD2E9FF).withOpacity(0.35),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value == 0 || value % 20 != 0) return const SizedBox.shrink();
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w300),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final name = chartData[value.toInt()]['name'];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  name,
                                  style: const TextStyle(fontSize: 8, color: Colors.black87, fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 20,
                        getDrawingHorizontalLine: (value) {
                          return const FlLine(color: Colors.black12, strokeWidth: 1);
                        },
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          bottom: BorderSide(color: Colors.black12, width: 1),
                          left: BorderSide(color: Colors.black12, width: 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(0, 2))],
        ),
        child: Text(
          title,
          style: const TextStyle(color: Color(0xFF003666), fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildRecentLoginTable(List<ActionLog> history) {
    final recentHistory = history.reversed.take(5).toList();

    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.ventoYellow.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader("RECENT INVENTORY"),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(color: AppColors.ventoYellow, borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderText("PRODUCTS"),
                _buildHeaderText("PRODUCT TYPE"),
                _buildHeaderText("UNIT QTY."),
                _buildHeaderText("UNIT PRICE"),
                _buildHeaderText("TIME"),
                _buildHeaderText("STATUS"),
              ],
            ),
          ),
          Expanded(
            child: recentHistory.isEmpty 
              ? const Center(child: Text("No items recently logged", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: recentHistory.length,
                  itemBuilder: (context, index) {
                    final log = recentHistory[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCellText(log.item),
                          _buildCellText(log.productType),
                          _buildCellText(log.qty.toString()),
                          _buildCellText("₱${log.price}"),
                          _buildCellText("12:30 AM"), // Mock Time as missing in ActionLog
                          _buildCellText(log.action, color: log.action == "INGEST" ? Colors.green : Colors.orange),
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

  Widget _buildCellText(String text, {Color color = AppColors.navyDark}) {
    return SizedBox(
      width: 100,
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 13), overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildHeaderText(String text) {
    return SizedBox(
      width: 100,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF003666))),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Image.asset("assets/images/vento.png", height: 46, fit: BoxFit.contain),
        const SizedBox(width: 30),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Image.asset("assets/images/vento_search.png", height: 30, width: 30, fit: BoxFit.contain),
                const SizedBox(width: 10),
                const Text("Value...", style: TextStyle(color: Color(0x40AD9696), fontSize: 24)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 30),
        Image.asset("assets/images/dashboard.png", height: 24, fit: BoxFit.contain),
      ],
    );
  }
}
