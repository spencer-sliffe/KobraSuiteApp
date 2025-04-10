// Front-end model for ChoreCompletion
class ChoreCompletion {
  final int id;
  final int chore; // Chore ID
  final int homelifeProfile; // HomeLifeProfile ID
  final String completedAt;
  final bool isOnTime;
  final int points;

  ChoreCompletion({
    required this.id,
    required this.chore,
    required this.homelifeProfile,
    required this.completedAt,
    required this.isOnTime,
    required this.points,
  });

  factory ChoreCompletion.fromJson(Map<String, dynamic> json) {
    return ChoreCompletion(
      id: json['id'],
      chore: json['chore'],
      homelifeProfile: json['homelife_profile'],
      completedAt: json['completed_at'],
      isOnTime: json['is_on_time'],
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chore': chore,
      'homelife_profile': homelifeProfile,
      'completed_at': completedAt,
      'is_on_time': isOnTime,
      'points': points,
    };
  }
}