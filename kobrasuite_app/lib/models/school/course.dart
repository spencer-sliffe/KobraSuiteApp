// lib/models/school/course.dart

import 'university.dart';

class Course {
  final int id;
  final String courseCode;
  final String professorLastName;
  final String title;
  final String? semesterType;
  final int? semesterYear;
  final String? department;
  final int? studentCount;
  final University? universityDetail;

  Course({
    required this.id,
    required this.courseCode,
    required this.professorLastName,
    required this.title,
    this.semesterType,
    this.semesterYear,
    this.department,
    this.studentCount,
    this.universityDetail,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: (json['id'] is int) ? json['id'] as int : 0,

      courseCode: (json['course_code'] ?? '') as String,

      professorLastName: (json['professor_last_name'] ?? '') as String,

      title: (json['title'] ?? '') as String,

      semesterType: json['semester_type'] as String?,
      semesterYear: json['semester_year'] as int?,
      department: json['department'] as String?,

      studentCount: json['student_count'] != null
          ? json['student_count'] as int
          : 0,

      universityDetail: json['university'] != null
          ? University.fromJson(json['university'] as Map<String, dynamic>)
          : null,
    );
  }

  String get semester {
    if (semesterType != null && semesterYear != null) {
      return '$semesterType $semesterYear';
    }
    return 'N/A';
  }
}