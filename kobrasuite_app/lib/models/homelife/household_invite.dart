// Front-end model for HouseholdInvite
class HouseholdInvite {
  final int id;
  final int inviter; // HomeLifeProfile ID of the inviter
  final int household; // Household ID
  final String code;
  final String createdAt;
  final String? redeemedAt;
  final int? redeemedBy; // HomeLifeProfile ID who redeemed

  HouseholdInvite({
    required this.id,
    required this.inviter,
    required this.household,
    required this.code,
    required this.createdAt,
    this.redeemedAt,
    this.redeemedBy,
  });

  factory HouseholdInvite.fromJson(Map<String, dynamic> json) {
    return HouseholdInvite(
      id: json['id'],
      inviter: json['inviter'],
      household: json['household'],
      code: json['code'] ?? '',
      createdAt: json['created_at'],
      redeemedAt: json['redeemed_at'],
      redeemedBy: json['redeemed_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inviter': inviter,
      'household': household,
      'code': code,
      'created_at': createdAt,
      'redeemed_at': redeemedAt,
      'redeemed_by': redeemedBy,
    };
  }
}