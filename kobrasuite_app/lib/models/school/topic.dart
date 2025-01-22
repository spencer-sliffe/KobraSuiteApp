// lib/models/school/topic.dart

class Topic {
  final int id;
  final int courseId;
  final String name;
  final String? courseTitle;

  Topic({
    required this.id,
    required this.courseId,
    required this.name,
    this.courseTitle,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    final course = json['course'];
    return Topic(
      id: json['id'],
      courseId: course is Map ? course['id'] : course as int? ?? 0,
      name: json['name'],
      courseTitle: course is Map ? course['title'] : null,
    );
  }
}