// lib/models/school/discussion_thread.dart

class DiscussionThread {
  final int id;
  final String scope;
  final int scopeId;
  final String title;
  final int createdBy;
  final DateTime createdAt;

  DiscussionThread({
    required this.id,
    required this.scope,
    required this.scopeId,
    required this.title,
    required this.createdBy,
    required this.createdAt,
  });

  factory DiscussionThread.fromJson(Map<String, dynamic> json) {
    return DiscussionThread(
      id: json['id'],
      scope: json['scope'],
      scopeId: json['scope_id'],
      title: json['title'],
      createdBy: json['created_by'] is int
          ? json['created_by']
          : (json['created_by'] is Map ? json['created_by']['id'] : 0),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}