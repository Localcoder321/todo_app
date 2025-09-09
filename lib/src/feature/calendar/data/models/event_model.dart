import 'package:todo_app/src/core/constants/constants.dart';
import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';

class EventModel extends EventEntity {
  EventModel({
    int? id,
    required DateTime date,
    required String title,
    String? subtitle,
    String? note,
    String? location,
    required Priority priority,
    String? startTime,
    String? endTime,
  }) : super(
         id: id,
         date: date,
         title: title,
         subtitle: subtitle,
         note: note,
         location: location,
         priority: priority,
         startTime: startTime,
         endTime: endTime,
       );

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'date': formatYmd(date),
      'title': title,
      'subtitle': subtitle,
      'note': note,
      'location': location,
      'priority': priority.index,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  factory EventModel.fromMap(Map<String, Object?> result) {
    return EventModel(
      id: result['id'] as int?,
      date: parseYmd(result['date'] as String),
      title: result['title'] as String,
      subtitle: result['subtitle'] as String?,
      note: result['note'] as String?,
      location: result['location'] as String?,
      priority: Priority.values[(result['priority'] as int?) ?? 1],
      startTime: result['start_time'] as String?,
      endTime: result['end_time'] as String?,
    );
  }
}
