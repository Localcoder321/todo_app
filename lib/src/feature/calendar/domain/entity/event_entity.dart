class EventEntity {
  final int? id;
  final DateTime date;
  final String title;
  final String? subtitle;
  final String? note;
  final String? location;
  final Priority priority;
  final String? startTime;
  final String? endTime;

  EventEntity({
    this.id,
    required this.date,
    required this.title,
    this.subtitle,
    this.note,
    this.location,
    required this.priority,
    this.startTime,
    this.endTime,
  });
}

enum Priority { low, normal, high }
