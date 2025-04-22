import 'grocery_item.dart';

class GroceryList {
  final int id;
  final int household;
  final String name;            // <── NEW  (comes from the API)
  final List<GroceryItem> items;
  final String runDatetime;
  final String createdAt;
  final String updatedAt;

  GroceryList({
    required this.id,
    required this.household,
    required this.name,
    required this.runDatetime,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroceryList.fromJson(Map<String, dynamic> json) {
    return GroceryList(
      id:         json['id'],
      household:  json['household'],
      name:       json['name'] ?? json['title'] ?? '',   // title fallback just in case
      runDatetime:
                  json['run_datetime'],
      items: json['items'] != null
          ? (json['items'] as List)
          .map((e) => GroceryItem.fromJson(e))
          .toList()
          : [],
      createdAt:  json['created_at'],
      updatedAt:  json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id'        : id,
      'household' : household,
      'name'      : name,
      'run_datetime':
                    runDatetime,
      'items'     : items.map((e) => e.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}