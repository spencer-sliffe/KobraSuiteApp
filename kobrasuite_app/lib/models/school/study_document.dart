// lib/models/school/study_document.dart

class StudyDocument {
  final int id;
  final String title;
  final String description;
  final String fileUrl;
  final DateTime createdAt;

  StudyDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.createdAt,
  });

  factory StudyDocument.fromJson(Map<String, dynamic> json) {
    return StudyDocument(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      fileUrl: json['file'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'file': fileUrl,
    'created_at': createdAt.toIso8601String(),
  };
}