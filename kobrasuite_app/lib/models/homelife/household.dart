class Household {
  final int    id;
  final String name;
  final String householdType;
  final String joinCode;   // NEW
  final String createdAt;
  final String updatedAt;

  Household({
    required this.id,
    required this.name,
    required this.householdType,
    required this.joinCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Household.fromJson(Map<String, dynamic> json) => Household(
    id:            json['id'],
    name:          json['name'],
    householdType: json['household_type'],
    joinCode:      json['join_code'],
    createdAt:     json['created_at'],
    updatedAt:     json['updated_at'],
  );
}