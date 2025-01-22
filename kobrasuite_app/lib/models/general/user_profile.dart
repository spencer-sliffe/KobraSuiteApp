// lib/models/general/user_profile.dart

class UserProfile {
  final int id;
  final int userId;
  final DateTime? dateOfBirth;
  final String? address;
  final String? profilePicture;
  final Map<String, dynamic>? preferences;

  UserProfile({
    required this.id,
    required this.userId,
    this.dateOfBirth,
    this.address,
    this.profilePicture,
    this.preferences,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      userId: json['user'],
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
      address: json['address'],
      profilePicture: json['profile_picture'],
      preferences: json['preferences'],
    );
  }
}