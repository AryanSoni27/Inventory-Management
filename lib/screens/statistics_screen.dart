import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Statistics'),
      ),
      body: Consumer<InventoryProvider>(
        builder: (ctx, inventoryProvider, _) {
          final items = inventoryProvider.items;

          if (items.isEmpty) {
            return Center(
              child: Text('No items in inventory to generate statistics.'),
            );
          }

          // Calculate statistics
          final totalItems = items.length;
          final totalQuantity = items.fold(0, (sum, item) => sum + item.quantity);
          final totalValue = inventoryProvider.getTotalInventoryValue();
          final lowStockItems = inventoryProvider.getLowStockItems(5).length;

          // Category distribution data
          final categoryMap = <String, int>{};
          for (var item in items) {
            final category = item.category ?? 'Uncategorized'; // Handle null categories
            categoryMap[category] = (categoryMap[category] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(
                  totalItems,
                  totalQuantity,
                  totalValue,
                  lowStockItems,
                ),
                SizedBox(height: 20),
                Text(
                  'Category Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 300,
                  child: categoryMap.isNotEmpty
                      ? _buildPieChart(categoryMap)
                      : Center(child: Text('No category data available')),
                ),
                SizedBox(height: 20),
                Text(
                  'Top Value Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                _buildTopValueItems(items),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(
      int totalItems,
      int totalQuantity,
      double totalValue,
      int lowStockItems,
      ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildStatCard(
          'Total Items',
          totalItems.toString(),
          Icons.category,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Quantity',
          totalQuantity.toString(),
          Icons.inventory_2,
          Colors.green,
        ),
        _buildStatCard(
          'Total Value',
          '\$${totalValue.toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.purple,
        ),
        _buildStatCard(
          'Low Stock Items',
          lowStockItems.toString(),
          Icons.warning,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth > 600 ? 280 : (constraints.maxWidth / 2) - 15,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: color, size: 24),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  Widget _buildPieChart(Map<String, int> categoryMap) {
    try {
      List<PieChartSectionData> sections = [];
      final colors = [
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.red,
        Colors.amber,
        Colors.teal,
      ];

      int i = 0;
      categoryMap.forEach((category, count) {
        final color = colors[i % colors.length];
        i++;

        sections.add(
          PieChartSectionData(
            color: color,
            value: count.toDouble(),
            title: count > 1 ? '$count' : '',
            titlePositionPercentageOffset: 0.6,
            radius: 80,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: i <= 5 ? _Badge(
              category,
              color,
              size: 12,
            ) : null,
            badgePositionPercentageOffset: 1.1,
          ),
        );
      });

      return PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 30,
          sectionsSpace: 2,
          pieTouchData: PieTouchData(enabled: true),
        ),
      );
    } catch (e) {
      // Return a fallback widget if chart generation fails
      return Center(
        child: Text('Error generating chart: ${e.toString()}'),
      );
    }
  }

  Widget _buildTopValueItems(List<InventoryItem> items) {
    // Sort items by total value (price * quantity)
    final sortedItems = List<InventoryItem>.from(items);
    sortedItems.sort((a, b) {
      final valueA = a.price * a.quantity;
      final valueB = b.price * b.quantity;
      return valueB.compareTo(valueA);
    });

    final topItems = sortedItems.take(5).toList();

    return Card(
      elevation: 2,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: topItems.length,
        itemBuilder: (context, index) {
          final item = topItems[index];
          final totalValue = item.price * item.quantity;
          return ListTile(
            title: Text(
              item.name,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('${item.quantity} × \$${item.price.toStringAsFixed(2)}'),
            trailing: Text(
              '\$${totalValue.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Badge widget for pie chart
class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final double size;

  const _Badge(
      this.text,
      this.color, {
        required this.size,
      });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: color,
        ),
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: size,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}