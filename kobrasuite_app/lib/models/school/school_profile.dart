// lib/models/school/school_profile.dart

import 'university.dart';

class SchoolProfile {
  final int id;
  final int? universityId;
  final University? universityDetail;
  final List<int>? courseIds;

  SchoolProfile({
    required this.id,
    this.universityId,
    this.universityDetail,
    this.courseIds,
  });

  factory SchoolProfile.fromJson(Map<String, dynamic> json) {
    return SchoolProfile(
      id: json['id'],
      universityId: json['university'],
      universityDetail: json['university_detail'] != null
          ? University.fromJson(json['university_detail'])
          : null,
      courseIds: json['courses'] != null ? List<int>.from(json['courses']) : null,
    );
  }
}