import 'package:flutter/material.dart';
import 'package:todo_app/app.dart';
import 'src/feature/calendar/data/datasource/events_local_datasource.dart';
import 'src/feature/calendar/data/repository/event_repository_impl.dart';
import 'src/feature/calendar/domain/usecase/get_event_counts_for_month_usecase.dart';
import 'src/feature/calendar/domain/usecase/get_events_for_day_usecase.dart';
import 'src/feature/calendar/domain/usecase/add_event_usecase.dart';
import 'src/feature/calendar/domain/usecase/update_event_usecase.dart';
import 'src/feature/calendar/domain/usecase/delete_event_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final local = EventsLocalDatasource.instance;
  await local.init();

  final repository = EventRepositoryImpl(local);

  final getCounts = GetEventsForMonthUsecase(repository);
  final getEventsForDay = GetEventsForDayUsecase(repository);
  final addEvent = AddEventUsecase(repository);
  final updateEvent = UpdateEventUsecase(repository);
  final deleteEvent = DeleteEventUsecase(repository);

  runApp(
    MyApp(
      getEventCountsForMonth: getCounts,
      getEventsForDay: getEventsForDay,
      addEvent: addEvent,
      updateEvent: updateEvent,
      deleteEvent: deleteEvent,
    ),
  );
}
