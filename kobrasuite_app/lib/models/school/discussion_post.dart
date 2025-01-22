// lib/models/school/discussion_post.dart

class DiscussionPost {
  final int id;
  final int threadId;
  final int authorId;
  final String content;
  final DateTime createdAt;

  DiscussionPost({
    required this.id,
    required this.threadId,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  factory DiscussionPost.fromJson(Map<String, dynamic> json) {
    return DiscussionPost(
      id: json['id'],
      threadId: json['thread'] is int
          ? json['thread']
          : (json['thread'] is Map ? json['thread']['id'] : 0),
      authorId: json['author'] is int
          ? json['author']
          : (json['author'] is Map ? json['author']['id'] : 0),
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}