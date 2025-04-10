// Front-end model for MedicalAppointment
class MedicalAppointment {
  final int id;
  final int household; // Household ID
  final String title;
  final String appointmentDatetime;
  final String doctorName;
  final String location;
  final String description;
  final String createdAt;

  MedicalAppointment({
    required this.id,
    required this.household,
    required this.title,
    required this.appointmentDatetime,
    this.doctorName = '',
    this.location = '',
    this.description = '',
    required this.createdAt,
  });

  factory MedicalAppointment.fromJson(Map<String, dynamic> json) {
    return MedicalAppointment(
      id: json['id'],
      household: json['household'],
      title: json['title'] ?? '',
      appointmentDatetime: json['appointment_datetime'],
      doctorName: json['doctor_name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household': household,
      'title': title,
      'appointment_datetime': appointmentDatetime,
      'doctor_name': doctorName,
      'location': location,
      'description': description,
      'created_at': createdAt,
    };
  }
}