import 'grocery_item.dart';

class GroceryList {
  final int id;
  final int household; // ID of the household this list belongs to
  final String title;
  final String description;
  final List<GroceryItem> items;
  final String createdAt;
  final String updatedAt;

  GroceryList({
    required this.id,
    required this.household,
    required this.title,
    this.description = '',
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroceryList.fromJson(Map<String, dynamic> json) {
    return GroceryList(
      id: json['id'],
      household: json['household'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
          .map((item) => GroceryItem.fromJson(item))
          .toList()
          : [],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household': household,
      'title': title,
      'description': description,
      // Serializes each GroceryItem back to JSON.
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}