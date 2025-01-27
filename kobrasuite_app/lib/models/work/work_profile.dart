// lib/models/general/work_profile.dart

class WorkProfile {
  final int id;
  final int userId;

  WorkProfile({
    required this.id,
    required this.userId,
  });

  factory WorkProfile.fromJson(Map<String, dynamic> json) {
    return WorkProfile(
      id: json['id'],
      userId: json['user'],
    );
  }
}