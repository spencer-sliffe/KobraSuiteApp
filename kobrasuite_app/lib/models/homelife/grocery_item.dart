// Front-end model for GroceryItem
class GroceryItem {
  final int id;
  final int household; // Household ID
  final String name;
  final String quantity;
  final bool purchased;
  final String createdAt;

  GroceryItem({
    required this.id,
    required this.household,
    required this.name,
    this.quantity = '',
    this.purchased = false,
    required this.createdAt,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'],
      household: json['household'],
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? '',
      purchased: json['purchased'] ?? false,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household': household,
      'name': name,
      'quantity': quantity,
      'purchased': purchased,
      'created_at': createdAt,
    };
  }
}