import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_app/src/core/constants/constants.dart';
import 'package:todo_app/src/feature/calendar/domain/usecase/get_event_counts_for_month_usecase.dart';
import 'package:todo_app/src/feature/calendar/domain/usecase/get_events_for_day_usecase.dart';
import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final GetEventsForMonthUsecase getEventsForMonth;
  final GetEventsForDayUsecase getEventsForDay;

  CalendarBloc({required this.getEventsForMonth, required this.getEventsForDay})
    : super(CalendarInitial()) {
    on<LoadMonth>((e, emit) async {
      emit(MonthLoading(e.monthIndex));
      try {
        final month = monthFromIndex(e.monthIndex);
        final events = await getEventsForMonth.call(month.year, month.month);
        emit(
          MonthLoaded(monthIndex: e.monthIndex, month: month, events: events),
        );
      } catch (err) {
        emit(CalendarError(err.toString()));
      }
    });

    on<LoadDayEvents>((e, emit) async {
      emit(DayEventsLoading(e.date));
      try {
        final events = await getEventsForDay.call(e.date);
        emit(DayEventsLoaded(date: e.date, events: events));
      } catch (err) {
        emit(CalendarError(err.toString()));
      }
    });
  }
}
