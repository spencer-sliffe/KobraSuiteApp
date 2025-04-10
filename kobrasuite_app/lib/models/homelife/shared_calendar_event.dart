// Front-end model for SharedCalendarEvent
class SharedCalendarEvent {
  final int id;
  final int household; // Household ID
  final String title;
  final String startDatetime;
  final String endDatetime;
  final String description;
  final String location;
  final String createdAt;

  SharedCalendarEvent({
    required this.id,
    required this.household,
    required this.title,
    required this.startDatetime,
    required this.endDatetime,
    this.description = '',
    this.location = '',
    required this.createdAt,
  });

  factory SharedCalendarEvent.fromJson(Map<String, dynamic> json) {
    return SharedCalendarEvent(
      id: json['id'],
      household: json['household'],
      title: json['title'] ?? '',
      startDatetime: json['start_datetime'],
      endDatetime: json['end_datetime'],
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household': household,
      'title': title,
      'start_datetime': startDatetime,
      'end_datetime': endDatetime,
      'description': description,
      'location': location,
      'created_at': createdAt,
    };
  }
}