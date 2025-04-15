// Front-end model for GroceryItem
class GroceryItem {
  final int id;
  final int household; // Household ID
  final int groceryList; //Grocery list ID
  final String name;
  final String quantity;
  final bool purchased;
  final String createdAt;

  GroceryItem({
    required this.id,
    required this.household,
    required this.groceryList,
    required this.name,
    this.quantity = '',
    this.purchased = false,
    required this.createdAt,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'],
      household: json['household'],
      groceryList: json['grocery_list'],
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
      'grocery_list': groceryList,
      'name': name,
      'quantity': quantity,
      'purchased': purchased,
      'created_at': createdAt,
    };
  }
}