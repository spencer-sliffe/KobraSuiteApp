// lib/models/school/submission.dart

class Submission {
  final int id;
  final int assignmentId;
  final int studentId;
  final String? studentName;
  final String? textAnswer;
  final DateTime submittedAt;
  final String? answerFile;
  final String? comment;

  Submission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.studentName,
    this.textAnswer,
    required this.submittedAt,
    this.answerFile,
    this.comment,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'],
      assignmentId: json['assignment'] is int
          ? json['assignment']
          : (json['assignment'] is Map ? json['assignment']['id'] : 0),
      studentId: json['student'] is int
          ? json['student']
          : (json['student'] is Map ? json['student']['id'] : 0),
      studentName: json['student'] is Map ? json['student']['username'] ?? 'Unknown' : 'Unknown',
      textAnswer: json['text_answer'],
      submittedAt: DateTime.parse(json['submitted_at']),
      answerFile: json['answer_file'],
      comment: json['comment'],
    );
  }

  String? get answerFileUrl => answerFile;
}