// Front-end model for ChildProfile
class ChildProfile {
  final int id;
  final int parentProfile; // HomeLifeProfile ID of parent
  final String name;
  final String? dateOfBirth;
  final String createdAt;
  final String updatedAt;

  ChildProfile({
    required this.id,
    required this.parentProfile,
    required this.name,
    this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'],
      parentProfile: json['parent_profile'],
      name: json['name'] ?? '',
      dateOfBirth: json['date_of_birth'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_profile': parentProfile,
      'name': name,
      'date_of_birth': dateOfBirth,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

