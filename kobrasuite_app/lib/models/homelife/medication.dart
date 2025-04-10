// Front-end model for Medication
class Medication {
  final int id;
  final int household; // Household ID
  final String name;
  final String dosage;
  final String frequency;
  final String? nextDose;
  final String notes;
  final String createdAt;

  Medication({
    required this.id,
    required this.household,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.nextDose,
    this.notes = '',
    required this.createdAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      household: json['household'],
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      nextDose: json['next_dose'],
      notes: json['notes'] ?? '',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household': household,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'next_dose': nextDose,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}
