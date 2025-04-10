  // Front-end model for Pet
  class Pet {
    final int id;
    final int household; // Household ID
    final String name;
    final String petType;
    final String specialInstructions;
    final String medications;
    final String foodInstructions;
    final String waterInstructions;
    final String createdAt;
    final String updatedAt;

    Pet({
      required this.id,
      required this.household,
      required this.name,
      required this.petType,
      this.specialInstructions = '',
      this.medications = '',
      this.foodInstructions = '',
      this.waterInstructions = '',
      required this.createdAt,
      required this.updatedAt,
    });

    factory Pet.fromJson(Map<String, dynamic> json) {
      return Pet(
        id: json['id'],
        household: json['household'],
        name: json['name'] ?? '',
        petType: json['pet_type'] ?? '',
        specialInstructions: json['special_instructions'] ?? '',
        medications: json['medications'] ?? '',
        foodInstructions: json['food_instructions'] ?? '',
        waterInstructions: json['water_instructions'] ?? '',
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'household': household,
        'name': name,
        'pet_type': petType,
        'special_instructions': specialInstructions,
        'medications': medications,
        'food_instructions': foodInstructions,
        'water_instructions': waterInstructions,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
    }
  }

