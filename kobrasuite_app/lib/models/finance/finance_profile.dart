class FinanceProfile {
  final int id;
  final double budget;

  FinanceProfile({
    required this.id,
    required this.budget,
  });

  factory FinanceProfile.fromJson(Map<String, dynamic> json) {
    return FinanceProfile(
      id: json['id'],
      budget: (json['budget'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'budget': budget,
    };
  }
}