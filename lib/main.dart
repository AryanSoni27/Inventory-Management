import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/inventory_item.dart';
import 'providers/inventory_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(

      create: (context) => InventoryProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Inventory Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}