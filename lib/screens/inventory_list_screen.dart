import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';
import 'item_detail_screen.dart';

class InventoryListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory List'),
        actions: [
          PopupMenuButton(
            onSelected: (String value) {
              // Handle filtering options
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'all',
                child: Text('All Items'),
              ),
              PopupMenuItem(
                value: 'low_stock',
                child: Text('Low Stock'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<InventoryProvider>(
        builder: (ctx, inventoryProvider, _) {
          final items = inventoryProvider.items;

          if (items.isEmpty) {
            return Center(
              child: Text('No items in inventory. Add some!'),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, index) {
              return InventoryItemTile(item: items[index]);
            },
          );
        },
      ),
    );
  }
}

class InventoryItemTile extends StatelessWidget {
  final InventoryItem item;

  const InventoryItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

    return Dismissible(
      key: Key(item.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Do you want to remove ${item.name} from inventory?'),
            actions: [
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        inventoryProvider.deleteItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} removed from inventory'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ListTile(
          leading: item.imageUrl.isNotEmpty
              ? CircleAvatar(
            backgroundImage: NetworkImage(item.imageUrl),
          )
              : CircleAvatar(
            child: Text(item.name.substring(0, 1).toUpperCase()),
          ),
          title: Text(item.name),
          subtitle: Text('Category: ${item.category}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Qty: ${item.quantity}',
                style: TextStyle(
                  color: item.quantity <= 5 ? Colors.red : Colors.black,
                  fontWeight: item.quantity <= 5 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              SizedBox(width: 10),
              Text('\$${item.price.toStringAsFixed(2)}'),
              // Added delete button here
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // Reuse the same confirmation dialog as in Dismissible
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Confirm Delete'),
                      content: Text('Do you want to remove ${item.name} from inventory?'),
                      actions: [
                        TextButton(
                          child: Text('No'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Yes'),
                          onPressed: () {
                            inventoryProvider.deleteItem(item.id);
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.name} removed from inventory'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => ItemDetailScreen(itemId: item.id),
              ),
            );
          },
        ),
      ),
    );
  }
}