class InventoryItem {
  final String id;
  final String name;
  final String category;
  final double price;
  int quantity;
  final String description;
  final String imageUrl;
  final DateTime dateAdded;
  final DateTime lastUpdated;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    this.description = '',
    this.imageUrl = '',
    required this.dateAdded,
    required this.lastUpdated,
  });

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? quantity,
    String? description,
    String? imageUrl,
    DateTime? dateAdded,
    DateTime? lastUpdated,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      dateAdded: dateAdded ?? this.dateAdded,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'description': description,
      'imageUrl': imageUrl,
      'dateAdded': dateAdded.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'],
      quantity: json['quantity'],
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      dateAdded: DateTime.parse(json['dateAdded']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}