// Front-end model for MealPlan
class MealPlan {
  final int id;
  final int household; // Household ID
  final String date;
  final String mealType;
  final String recipeName;
  final String notes;
  final String createdAt;

  MealPlan({
    required this.id,
    required this.household,
    required this.date,
    required this.mealType,
    required this.recipeName,
    this.notes = '',
    required this.createdAt,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'],
      household: json['household'],
      date: json['date'],
      mealType: json['meal_type'] ?? '',
      recipeName: json['recipe_name'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household': household,
      'date': date,
      'meal_type': mealType,
      'recipe_name': recipeName,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}






