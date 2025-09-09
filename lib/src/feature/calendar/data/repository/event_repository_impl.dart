import 'dart:developer';

import 'package:todo_app/src/feature/calendar/data/datasource/events_local_datasource.dart';
import 'package:todo_app/src/feature/calendar/data/models/event_model.dart';
import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';
import 'package:todo_app/src/feature/calendar/domain/repository/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventsLocalDatasource local;
  EventRepositoryImpl(this.local);

  Future<void> init() => local.init();

  @override
  Future<int> addEvent(EventEntity e) async {
    final m = EventModel(
      id: null,
      date: e.date,
      title: e.title,
      subtitle: e.subtitle,
      note: e.note,
      location: e.location,
      priority: e.priority,
      startTime: e.startTime,
      endTime: e.endTime,
    );
    return await local.insert(m);
  }

  @override
  Future<void> updateEvent(EventEntity e) async {
    final m = EventModel(
      id: e.id,
      date: e.date,
      title: e.title,
      subtitle: e.subtitle,
      note: e.note,
      location: e.location,
      priority: e.priority,
      startTime: e.startTime,
      endTime: e.endTime,
    );
    await local.update(m);
  }

  @override
  Future<void> deleteEvent(int id) async {
    log("${local.delete(id)}");
    await local.delete(id);
  }

  @override
  Future<List<EventEntity>> eventsOn(DateTime date) async {
    final models = await local.eventsOn(date);
    return models
        .map(
          (m) => EventEntity(
            id: m.id,
            date: m.date,
            title: m.title,
            subtitle: m.subtitle,
            note: m.note,
            location: m.location,
            priority: m.priority,
            startTime: m.startTime,
            endTime: m.endTime,
          ),
        )
        .toList();
  }

  @override
  Future<Map<String, int>> eventCountsForMonth(int year, int month) async {
    log("${local.eventCountsForMonth(year, month)}");
    return await local.eventCountsForMonth(year, month);
  }

  @override
  Future<List<EventEntity>> eventsInRange(DateTime from, DateTime to) async {
    final models = await local.eventsInRange(from, to);
    log("$models");
    return models
        .map(
          (m) => EventEntity(
            id: m.id,
            date: m.date,
            title: m.title,
            subtitle: m.subtitle,
            note: m.note,
            location: m.location,
            priority: m.priority,
            startTime: m.startTime,
            endTime: m.endTime,
          ),
        )
        .toList();
  }
}
