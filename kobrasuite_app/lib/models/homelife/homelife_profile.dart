// lib/models/general/work_profile.dart

import 'household.dart';

class HomeLifeProfile {
  final int id;
  final int userId;
  final int? householdId;
  final Household? householdDetail;

  HomeLifeProfile({
    required this.id,
    required this.userId,
    required this.householdId,
    required this.householdDetail
  });

  factory HomeLifeProfile.fromJson(Map<String, dynamic> json) {
    return HomeLifeProfile(
      id: json['id'],
      userId: json['user'],
      householdId: json['household'],
      householdDetail: json['household_detail'] != null
    ? Household.fromJson(json['household_detail'])
        : null,
    );
  }
}