class Pet {
  final int id, household;
  final String name, petType;

  final String foodInstructions, waterInstructions, medicationInstructions;

  final String? foodFrequency, waterFrequency, medicationFrequency;   // nullable now
  final List<String>? foodTimes,  waterTimes,  medicationTimes;

  final String createdAt, updatedAt;

  const Pet({
    required this.id,
    required this.household,
    required this.name,
    required this.petType,
    this.foodInstructions = '',
    this.waterInstructions = '',
    this.medicationInstructions = '',
    required this.foodFrequency,
    required this.waterFrequency,
    required this.medicationFrequency,
    this.foodTimes,
    this.waterTimes,
    this.medicationTimes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pet.fromJson(Map<String, dynamic> j) => Pet(
    id: j['id'],
    household: j['household'],
    name: j['name'] ?? '',
    petType: j['pet_type'] ?? '',
    foodInstructions: j['food_instructions'] ?? '',
    waterInstructions: j['water_instructions'] ?? '',
    medicationInstructions: j['medication_instructions'] ?? '',
    foodFrequency: j['food_frequency'],                 // may be null / ''
    waterFrequency: j['water_frequency'],
    medicationFrequency: j['medication_frequency'],
    foodTimes:       (j['food_times']       as List?)?.cast<String>(),
    waterTimes:      (j['water_times']      as List?)?.cast<String>(),
    medicationTimes: (j['medication_times'] as List?)?.cast<String>(),
    createdAt: j['created_at'],
    updatedAt: j['updated_at'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'household': household,
    'name': name,
    'pet_type': petType,
    'food_instructions': foodInstructions,
    'water_instructions': waterInstructions,
    'medication_instructions': medicationInstructions,
    'food_frequency': foodFrequency,
    'water_frequency': waterFrequency,
    'medication_frequency': medicationFrequency,
    'food_times': foodTimes,
    'water_times': waterTimes,
    'medication_times': medicationTimes,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}