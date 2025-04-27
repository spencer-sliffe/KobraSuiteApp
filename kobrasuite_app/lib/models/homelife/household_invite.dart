// Front-end model for HouseholdInvite
class HouseholdInvite {
  final int id;
  final int household; // Household ID
  final String code;
  final String createdAt;

  HouseholdInvite({
    required this.id,
    required this.household,
    required this.code,
    required this.createdAt,
  });

  factory HouseholdInvite.fromJson(Map<String, dynamic> json) {
    return HouseholdInvite(
      id: json['id'],
      household: json['household'],
      code: json['code'] ?? '',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household': household,
      'code': code,
      'created_at': createdAt,
    };
  }
}