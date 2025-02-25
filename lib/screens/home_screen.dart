import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'inventory_list_screen.dart';
import 'add_item_screen.dart';
import 'low_stock_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<InventoryProvider>(context).loadItems().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: InventorySearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        children: [
          _buildMenuItem(
            context,
            'View Inventory',
            Icons.list,
            Colors.blue,
                () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InventoryListScreen(),
              ),
            ),
          ),
          _buildMenuItem(
            context,
            'Add Item',
            Icons.add_circle,
            Colors.green,
                () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddItemScreen(),
              ),
            ),
          ),
          _buildMenuItem(
            context,
            'Low Stock',
            Icons.warning,
            Colors.orange,
                () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LowStockScreen(),
              ),
            ),
          ),
          _buildMenuItem(
            context,
            'Statistics',
            Icons.bar_chart,
            Colors.purple,
                () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StatisticsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: color,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InventorySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final searchResults = inventoryProvider.searchItems(query);

    return searchResults.isEmpty
        ? Center(child: Text('No results found'))
        : ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final item = searchResults[index];
        return ListTile(
          title: Text(item.name),
          subtitle: Text('Quantity: ${item.quantity}'),
          trailing: Text('\$${item.price.toStringAsFixed(2)}'),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('Search for inventory items'));
    }

    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final searchResults = inventoryProvider.searchItems(query);

    return searchResults.isEmpty
        ? Center(child: Text('No results found'))
        : ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final item = searchResults[index];
        return ListTile(
          title: Text(item.name),
          subtitle: Text('${item.category} - Qty: ${item.quantity}'),
          onTap: () {
            query = item.name;
            showResults(context);
          },
        );
      },
    );
  }
}
