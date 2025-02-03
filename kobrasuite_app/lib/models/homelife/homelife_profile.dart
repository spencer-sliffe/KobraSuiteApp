// lib/models/general/work_profile.dart

class HomeLifeProfile {
  final int id;
  final int userId;

  HomeLifeProfile({
    required this.id,
    required this.userId,
  });

  factory HomeLifeProfile.fromJson(Map<String, dynamic> json) {
    return HomeLifeProfile(
      id: json['id'],
      userId: json['user'],
    );
  }
}