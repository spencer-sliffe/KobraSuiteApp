// Front-end model for Chore
class Chore {
  final int id;
  final int household; // Household ID
  final String title;
  final String description;
  final String frequency;
  final int priority;
  final String? availableFrom;
  final String? availableUntil;
  final int? assignedTo; // HomeLifeProfile ID (if assigned)
  final String createdAt;
  final String updatedAt;

  Chore({
    required this.id,
    required this.household,
    required this.title,
    this.description = '',
    required this.frequency,
    required this.priority,
    this.availableFrom,
    this.availableUntil,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chore.fromJson(Map<String, dynamic> json) {
    return Chore(
      id: json['id'],
      household: json['household'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      frequency: json['frequency'] ?? '',
      priority: json['priority'] ?? 1,
      availableFrom: json['available_from'],
      availableUntil: json['available_until'],
      assignedTo: json['assigned_to'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household': household,
      'title': title,
      'description': description,
      'frequency': frequency,
      'priority': priority,
      'available_from': availableFrom,
      'available_until': availableUntil,
      'assigned_to': assignedTo,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
