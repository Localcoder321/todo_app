import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';

abstract class EventRepository {
  Future<int> addEvent(EventEntity e);
  Future<void> updateEvent(EventEntity e);
  Future<void> deleteEvent(int id);
  Future<List<EventEntity>> eventsOn(DateTime date);
  Future<Map<String, int>> eventCountsForMonth(int year, int month);
  Future<List<EventEntity>> eventsInRange(DateTime from, DateTime to);
}
