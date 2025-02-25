import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inventory_item.dart';

class InventoryProvider with ChangeNotifier {
  List<InventoryItem> _items = [];

  List<InventoryItem> get items {
    return [..._items];
  }

  Future<void> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString('inventory_items');

    if (itemsJson != null) {
      final List<dynamic> decodedData = json.decode(itemsJson);
      _items = decodedData
          .map((item) => InventoryItem.fromJson(item))
          .toList();
      notifyListeners();
    }
  }

  Future<void> saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = json.encode(_items.map((item) => item.toJson()).toList());
    prefs.setString('inventory_items', itemsJson);
  }

  Future<void> addItem(InventoryItem item) async {
    _items.add(item);
    notifyListeners();
    await saveItems();
  }

  Future<void> updateItem(InventoryItem updatedItem) async {
    final itemIndex = _items.indexWhere((item) => item.id == updatedItem.id);
    if (itemIndex >= 0) {
      _items[itemIndex] = updatedItem;
      notifyListeners();
      await saveItems();
    }
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    await saveItems();
  }

  Future<void> updateQuantity(String id, int newQuantity) async {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      final updatedItem = _items[itemIndex].copyWith(
        quantity: newQuantity,
        lastUpdated: DateTime.now(),
      );
      _items[itemIndex] = updatedItem;
      notifyListeners();
      await saveItems();
    }
  }

  List<InventoryItem> filterByCategory(String category) {
    return _items.where((item) => item.category == category).toList();
  }

  List<InventoryItem> searchItems(String query) {
    return _items.where((item) =>
    item.name.toLowerCase().contains(query.toLowerCase()) ||
        item.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  List<InventoryItem> getLowStockItems(int threshold) {
    return _items.where((item) => item.quantity <= threshold).toList();
  }

  double getTotalInventoryValue() {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }
}