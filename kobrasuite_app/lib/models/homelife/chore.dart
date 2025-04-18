class Chore {
  final int id;
  final int household;                    // household PK
  final String title;
  final String description;
  final String frequency;
  final int priority;
  final String? availableFrom;
  final String? availableUntil;
  final int? assignedTo;                  // HomeLifeProfile PK
  final int? childAssignedTo;             // ChildProfile PK
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
    this.childAssignedTo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chore.fromJson(Map<String, dynamic> json) => Chore(
    id: json['id'],
    household: json['household'],
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    frequency: json['frequency'] ?? '',
    priority: json['priority'] ?? 1,
    availableFrom: json['available_from'],
    availableUntil: json['available_until'],
    assignedTo: json['assigned_to'],
    childAssignedTo: json['child_assigned_to'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'household': household,
    'title': title,
    'description': description,
    'frequency': frequency,
    'priority': priority,
    'available_from': availableFrom,
    'available_until': availableUntil,
    'assigned_to': assignedTo,
    'child_assigned_to': childAssignedTo,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}