// lib/models/general/work_profile.dart

import 'household.dart';

class HomeLifeProfile {
  final int id;
  final int userId;
  final Household householdId;

  HomeLifeProfile({
    required this.id,
    required this.userId,
    required this.householdId
  });

  factory HomeLifeProfile.fromJson(Map<String, dynamic> json) {
    return HomeLifeProfile(
      id: json['id'],
      userId: json['user'],
      householdId: json['household']
    );
  }
}