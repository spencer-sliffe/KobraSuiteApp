// File location: lib/models/school/university.dart

class University {
  final int id;
  final String name;
  final String country;
  final String domain;
  final String website;
  final String? stateProvince;
  final int? studentCount;
  final int? courseCount;

  University({
    required this.id,
    required this.name,
    required this.country,
    required this.domain,
    required this.website,
    this.stateProvince,
    this.studentCount,
    this.courseCount,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'] is int ? json['id'] as int : 0,
      name: (json['name'] ?? '') as String,
      country: (json['country'] ?? '') as String,
      domain: (json['domain'] ?? '') as String,
      website: (json['website'] ?? '') as String,
      stateProvince: json['state_province'] as String?,
      studentCount: json['student_count'] as int?,
      courseCount: json['course_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'domain': domain,
    'website': website,
    'state_province': stateProvince,
    'student_count': studentCount,
    'course_count': courseCount,
  };
}