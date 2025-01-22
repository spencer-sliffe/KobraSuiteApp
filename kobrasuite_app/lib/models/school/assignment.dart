// lib/models/school/assignment.dart

class Assignment {
  final int id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final int courseId;
  final String? courseTitle;

  Assignment({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.courseId,
    this.courseTitle,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      courseId: json['course'] is int ? json['course'] : (json['course']['id'] ?? 0),
      courseTitle: json['course'] is Map<String, dynamic>
          ? json['course']['title']
          : null,
    );
  }
}