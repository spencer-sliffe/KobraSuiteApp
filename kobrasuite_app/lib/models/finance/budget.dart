class Budget {
  final int id;
  final int profile;
  final String name;
  final double totalAmount;
  final String startDate;
  final String endDate;
  final bool isActive;
  final List<dynamic> categories;

  Budget({
    required this.id,
    required this.profile,
    required this.name,
    required this.totalAmount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.categories = const [],
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      profile: json['profile'],
      name: json['name'] ?? '',
      totalAmount: (json['total_amount'] as num).toDouble(),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      isActive: json['is_active'] ?? false,
      categories: json['categories'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile': profile,
      'name': name,
      'total_amount': totalAmount,
      'start_date': startDate,
      'end_date': endDate,
      'is_active': isActive,
      'categories': categories,
    };
  }
}