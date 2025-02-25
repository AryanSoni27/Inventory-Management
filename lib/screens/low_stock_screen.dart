import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';
import 'item_detail_screen.dart';

class LowStockScreen extends StatefulWidget {
  @override
  _LowStockScreenState createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  int _threshold = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Low Stock Items'),
        actions: [
          IconButton(
            icon: Icon(Icons.tune),
            onPressed: () {
              _showThresholdDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 10),
                    Text(
                      'Items with quantity less than or equal to $_threshold',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (ctx, inventoryProvider, _) {
                final lowStockItems = inventoryProvider.getLowStockItems(_threshold);

                if (lowStockItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 60,
                          color: Colors.green,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No low stock items!',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: lowStockItems.length,
                  itemBuilder: (ctx, index) {
                    final item = lowStockItems[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Text(
                            item.quantity.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(item.name),
                        subtitle: Text('Category: ${item.category}'),
                        trailing: ElevatedButton(
                          child: Text('Restock'),
                          onPressed: () {
                            _showRestockDialog(context, item);
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ItemDetailScreen(itemId: item.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showThresholdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set Low Stock Threshold'),
        content: TextField(
          decoration: InputDecoration(labelText: 'Threshold'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _threshold = int.parse(value);
              });
            }
          },
          controller: TextEditingController(text: _threshold.toString()),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text('Apply'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showRestockDialog(BuildContext context, InventoryItem item) {
    int additionalQuantity = 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Restock ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current quantity: ${item.quantity}'),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: 'Add quantity'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  additionalQuantity = int.parse(value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text('Restock'),
            onPressed: () {
              if (additionalQuantity > 0) {
                Provider.of<InventoryProvider>(context, listen: false)
                    .updateQuantity(item.id, item.quantity + additionalQuantity);
                Navigator.of(ctx).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}