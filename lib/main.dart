import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/feature/calendar/data/datasource/events_local_datasource.dart';
import 'src/feature/calendar/data/repository/event_repository_impl.dart';
import 'src/feature/calendar/domain/usecase/get_event_counts_for_month_usecase.dart';
import 'src/feature/calendar/domain/usecase/get_events_for_day_usecase.dart';
import 'src/feature/calendar/domain/usecase/add_event_usecase.dart';
import 'src/feature/calendar/domain/usecase/update_event_usecase.dart';
import 'src/feature/calendar/domain/usecase/delete_event_usecase.dart';
import 'src/feature/calendar/presentation/bloc/calendar_bloc.dart';
import 'src/feature/calendar/presentation/bloc/event_edit_bloc.dart';
import 'src/feature/calendar/presentation/pages/calendar_page.dart';

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

class MyApp extends StatelessWidget {
  final GetEventsForMonthUsecase getEventCountsForMonth;
  final GetEventsForDayUsecase getEventsForDay;
  final AddEventUsecase addEvent;
  final UpdateEventUsecase updateEvent;
  final DeleteEventUsecase deleteEvent;

  const MyApp({
    super.key,
    required this.getEventCountsForMonth,
    required this.getEventsForDay,
    required this.addEvent,
    required this.updateEvent,
    required this.deleteEvent,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CalendarBloc(
            getEventsForDay: getEventsForDay,
            getEventsForMonth: getEventCountsForMonth,
          ),
        ),
        BlocProvider(
          create: (_) => EventEditBloc(
            addEvent: addEvent,
            updateEvent: updateEvent,
            deleteEvent: deleteEvent,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo Calendar',
        theme: ThemeData(useMaterial3: true),
        home: const CalendarPage(),
      ),
    );
  }
}
