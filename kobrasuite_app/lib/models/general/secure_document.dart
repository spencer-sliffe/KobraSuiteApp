// lib/models/general/secure_document.dart

class SecureDocument {
  final int id;
  final int userId;
  final String title;
  final String file;
  final String? description;
  final DateTime createdAt;

  SecureDocument({
    required this.id,
    required this.userId,
    required this.title,
    required this.file,
    this.description,
    required this.createdAt,
  });

  factory SecureDocument.fromJson(Map<String, dynamic> json) {
    return SecureDocument(
      id: json['id'],
      userId: json['user'],
      title: json['title'],
      file: json['file'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}