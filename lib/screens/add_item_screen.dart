import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';

class AddItemScreen extends StatefulWidget {
  final InventoryItem? editItem;

  AddItemScreen({this.editItem});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isInit = true;
  var _isLoading = false;

  var _itemData = {
    'name': '',
    'category': '',
    'price': 0.0,
    'quantity': 0,
    'description': '',
    'imageUrl': '',
  };

  final _categories = ['Electronics', 'Clothing', 'Food', 'Office Supplies', 'Other'];
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (widget.editItem != null) {
        _itemData = {
          'name': widget.editItem!.name,
          'category': widget.editItem!.category,
          'price': widget.editItem!.price,
          'quantity': widget.editItem!.quantity,
          'description': widget.editItem!.description,
          'imageUrl': widget.editItem!.imageUrl,
        };

        _nameController.text = widget.editItem!.name;
        _priceController.text = widget.editItem!.price.toString();
        _quantityController.text = widget.editItem!.quantity.toString();
        _descriptionController.text = widget.editItem!.description;
        _imageUrlController.text = widget.editItem!.imageUrl;
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

      if (widget.editItem == null) {
        // Add new item
        final newItem = InventoryItem(
          id: Uuid().v4(),
          name: _itemData['name'] as String,
          category: _itemData['category'] as String,
          price: _itemData['price'] as double,
          quantity: _itemData['quantity'] as int,
          description: _itemData['description'] as String,
          imageUrl: _itemData['imageUrl'] as String,
          dateAdded: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        await inventoryProvider.addItem(newItem);
      } else {
        // Update existing item
        final updatedItem = widget.editItem!.copyWith(
          name: _itemData['name'] as String,
          category: _itemData['category'] as String,
          price: _itemData['price'] as double,
          quantity: _itemData['quantity'] as int,
          description: _itemData['description'] as String,
          imageUrl: _itemData['imageUrl'] as String,
          lastUpdated: DateTime.now(),
        );

        await inventoryProvider.updateItem(updatedItem);
      }

      Navigator.of(context).pop();
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong.'),
          actions: [
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editItem == null ? 'Add Item' : 'Edit Item'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _itemData['name'] = value!;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'Category'),
                value: _itemData['category'].toString().isNotEmpty
                    ? _itemData['category']
                    : null,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _itemData['category'] = value as String;
                  });
                },
                onSaved: (value) {
                  _itemData['category'] = value as String;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Please enter a price greater than zero';
                  }
                  return null;
                },
                onSaved: (value) {
                  _itemData['price'] = double.parse(value!);
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (int.parse(value) < 0) {
                    return 'Quantity cannot be negative';
                  }
                  return null;
                },
                onSaved: (value) {
                  _itemData['quantity'] = int.parse(value!);
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                onSaved: (value) {
                  _itemData['description'] = value!;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL (optional)'),
                keyboardType: TextInputType.url,
                onSaved: (value) {
                  _itemData['imageUrl'] = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  widget.editItem == null ? 'Add Item' : 'Save Changes',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


