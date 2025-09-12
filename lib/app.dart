import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/src/core/routers/app_router.dart';
import 'package:todo_app/src/feature/calendar/domain/usecase/add_event_usecase.dart';
import 'package:todo_app/src/feature/calendar/domain/usecase/delete_event_usecase.dart';
import 'package:todo_app/src/feature/calendar/domain/usecase/get_event_counts_for_month_usecase.dart';
import 'package:todo_app/src/feature/calendar/domain/usecase/get_events_for_day_usecase.dart';
import 'package:todo_app/src/feature/calendar/domain/usecase/update_event_usecase.dart';
import 'package:todo_app/src/feature/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:todo_app/src/feature/calendar/presentation/bloc/event_edit_bloc.dart';

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
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Todo Calendar',
        theme: ThemeData(useMaterial3: true),
        routerConfig: AppRouter().router,
      ),
    );
  }
}
