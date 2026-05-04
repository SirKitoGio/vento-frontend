import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';

class DashboardScreenContent extends ConsumerWidget {
  const DashboardScreenContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryState = ref.watch(inventoryProvider);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

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
      padding: EdgeInsets.all(isMobile ? 15.0 : 30.0),
      child: Column(
        children: [
          if (!isMobile) _buildTopBar(ref),
          if (!isMobile) const SizedBox(height: 30),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (isMobile) ...[
                    _buildWarehouseOverview(items, isMobile),
                    const SizedBox(height: 20),
                    _buildVentoOverview(typeCounts, isMobile),
                  ] else 
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWarehouseOverview(items, isMobile),
                        const SizedBox(width: 20),
                        _buildVentoOverview(typeCounts, isMobile),
                      ],
                    ),
                  const SizedBox(height: 30),
                  _buildRecentLoginTable(inventoryState, isMobile),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseOverview(List<InventoryItem> items, bool isMobile) {
    // Calculate total capacity (assuming 100 from backend 10x10 matrix)
    final totalCapacity = 100;
    final filledSlots = items.length;
    final utilizationPercentage = totalCapacity > 0 ? (filledSlots / totalCapacity * 100).round() : 0;

    final content = Container(
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
              _buildCardHeader("WAREHOUSE OVERVIEW", isMobile),
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
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
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
                            ),
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
    );

    return isMobile ? content : Expanded(flex: 5, child: content);
  }

  Widget _buildVentoOverview(Map<String, int> typeCounts, bool isMobile) {
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

    final content = Container(
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
          _buildCardHeader("VENTO OVERVIEW", isMobile),
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
                            width: isMobile ? 30 : 50,
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
                                style: TextStyle(fontSize: isMobile ? 6 : 8, color: Colors.black87, fontWeight: FontWeight.w500),
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
    );

    return isMobile ? content : Expanded(flex: 5, child: content);
  }

  Widget _buildCardHeader(String title, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 15 : 25, 
          vertical: isMobile ? 8 : 12
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(0, 2))],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: const Color(0xFF003666), 
            fontWeight: FontWeight.bold, 
            fontFamily: 'Poppins', 
            fontSize: isMobile ? 18 : 22
          ),
        ),
      ),
    );
  }

  Widget _buildRecentLoginTable(InventoryState state, bool isMobile) {
    final searchQuery = state.searchQuery.toLowerCase();
    
    // Extract active items from matrix
    List<InventoryItem> activeItems = state.matrix
        .expand((row) => row)
        .where((item) => item != null)
        .cast<InventoryItem>()
        .toList();

    // Sort by startTime descending (newest first)
    activeItems.sort((a, b) => (b.startTime ?? DateTime.now()).compareTo(a.startTime ?? DateTime.now()));

    // Filter based on search query
    if (searchQuery.isNotEmpty) {
      activeItems = activeItems.where((item) => 
        item.name.toLowerCase().contains(searchQuery) || 
        item.productType.toLowerCase().contains(searchQuery)
      ).toList();
    } else {
      activeItems = activeItems.take(5).toList();
    }

    final tableContent = Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 24, horizontal: 20),
          decoration: BoxDecoration(color: AppColors.ventoYellow, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderText("PRODUCTS", isMobile),
              _buildHeaderText("PRODUCT TYPE", isMobile),
              _buildHeaderText("UNIT QTY.", isMobile),
              _buildHeaderText("UNIT PRICE", isMobile),
              _buildHeaderText("PLACE", isMobile),
              _buildHeaderText("DATE", isMobile),
            ],
          ),
        ),
        Expanded(
          child: activeItems.isEmpty 
            ? Center(child: Text(searchQuery.isEmpty ? "No active inventory items" : "No matches found", style: const TextStyle(color: Colors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: activeItems.length,
                itemBuilder: (context, index) {
                  final item = activeItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCellText(item.name, isMobile),
                        _buildCellText(item.productType, isMobile),
                        _buildCellText(item.quantity.toString(), isMobile),
                        _buildCellText("₱${item.price}", isMobile),
                        _buildCellText(item.inventoryPlace, isMobile),
                        _buildCellText(item.date, isMobile),
                      ],
                    ),
                  );
                },
              ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      height: 450, // Slightly taller for bigger content
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.ventoYellow.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(searchQuery.isEmpty ? "RECENT INVENTORY" : "SEARCH RESULTS", isMobile),
          Expanded(
            child: isMobile 
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 800, // Adjusted for 125px columns + padding
                    child: tableContent,
                  ),
                )
              : tableContent,
          ),
        ],
      ),
    );
  }

  Widget _buildCellText(String text, bool isMobile, {Color color = AppColors.navyDark}) {
    final content = Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Text(
        text, 
        style: TextStyle(
          color: color, 
          fontWeight: FontWeight.w500, 
          fontSize: isMobile ? 14 : 16
        ), 
        overflow: TextOverflow.ellipsis
      ),
    );

    return isMobile 
        ? SizedBox(width: 125, child: content)
        : Expanded(child: content);
  }

  Widget _buildHeaderText(String text, bool isMobile) {
    final content = Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Text(
        text, 
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: isMobile ? 15 : 18, 
          color: const Color(0xFF003666)
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );

    return isMobile 
        ? SizedBox(width: 125, child: content)
        : Expanded(child: content);
  }

  Widget _buildTopBar(WidgetRef ref) {
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
                Expanded(
                  child: TextField(
                    onChanged: (value) => ref.read(inventoryProvider.notifier).searchItems(value),
                    style: const TextStyle(color: Color(0xFF0F1628), fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: "Search inventory ...",
                      hintStyle: TextStyle(color: Color(0x40AD9696), fontSize: 24),
                      border: InputBorder.none,
                    ),
                  ),
                ),
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
