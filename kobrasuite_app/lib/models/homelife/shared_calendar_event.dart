class SharedCalendarEvent {
  final int id;
  final int household;
  final String title;
  final DateTime start;
  final DateTime end;
  final String description;
  final String location;
  final DateTime createdAt;

  SharedCalendarEvent({
    required this.id,
    required this.household,
    required this.title,
    required this.start,
    required this.end,
    this.description = '',
    this.location = '',
    required this.createdAt,
  });

  factory SharedCalendarEvent.fromJson(Map<String, dynamic> json) {
    return SharedCalendarEvent(
      id: json['id'] as int,
      household: json['household'] as int,
      title: json['title'] ?? '',
      start: DateTime.parse(json['start_datetime']).toLocal(),
      end: DateTime.parse(json['end_datetime']).toLocal(),
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      createdAt: json.containsKey('created_at')
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household': household,
      'title': title,
      'start_datetime': start.toUtc().toIso8601String(),
      'end_datetime': end.toUtc().toIso8601String(),
      'description': description,
      'location': location,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}