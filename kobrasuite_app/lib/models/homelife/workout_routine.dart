// Front-end model for WorkoutRoutine
class WorkoutRoutine {
  final int id;
  final int household; // Household ID
  final String title;
  final String description;
  final String schedule;
  final String exercises;
  final String createdAt;

  WorkoutRoutine({
    required this.id,
    required this.household,
    required this.title,
    this.description = '',
    required this.schedule,
    this.exercises = '',
    required this.createdAt,
  });

  factory WorkoutRoutine.fromJson(Map<String, dynamic> json) {
    return WorkoutRoutine(
      id: json['id'],
      household: json['household'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      schedule: json['schedule'] ?? '',
      exercises: json['exercises'] ?? '',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household': household,
      'title': title,
      'description': description,
      'schedule': schedule,
      'exercises': exercises,
      'created_at': createdAt,
    };
  }
}