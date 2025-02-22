class BudgetCategory {
  final int id;
  final String name;
  final int budget;
  final double allocatedAmount;
  final String categoryType;

  BudgetCategory({
    required this.id,
    required this.name,
    required this.budget,
    required this.allocatedAmount,
    required this.categoryType,
  });

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      id: json['id'],
      name: json['name'] ?? '',
      budget: json['budget'],
      allocatedAmount: (json['allocated_amount'] as num).toDouble(),
      categoryType: json['category_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'budget': budget,
      'allocated_amount': allocatedAmount,
      'category_type': categoryType,
    };
  }
}