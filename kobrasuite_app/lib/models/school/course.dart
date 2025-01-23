import 'university.dart';

class Course {
  final int id;
  final String courseCode;
  final String professorLastName;
  final String title;
  final String semesterType;
  final int semesterYear;
  final String department;
  final int studentCount;
  final University? universityDetail;

  Course({
    required this.id,
    required this.courseCode,
    required this.professorLastName,
    required this.title,
    required this.semesterType,
    required this.semesterYear,
    required this.department,
    required this.studentCount,
    this.universityDetail,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] is int ? json['id'] as int : 0,
      courseCode: (json['course_code'] ?? '') as String,
      professorLastName: (json['professor_last_name'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      semesterType: (json['semester_type'] ?? '') as String,
      semesterYear: json['semester_year'] is int ? json['semester_year'] as int : 0,
      department: (json['department'] ?? '') as String,
      studentCount: json['student_count'] is int ? json['student_count'] as int : 0,
      universityDetail: json['university'] != null
          ? University.fromJson(json['university'] as Map<String, dynamic>)
          : null,
    );
  }

  String get semester {
    if (semesterType.isNotEmpty && semesterYear > 0) {
      return '$semesterType $semesterYear';
    }
    return 'N/A';
  }
}