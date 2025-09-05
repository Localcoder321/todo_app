import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_app/src/core/constants.dart';
import 'package:todo_app/src/feature/calendar/domain/usecase/get_event_counts_for_month_usecase.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final GetEventCountsForMonthUsecase getCounts;
  CalendarBloc({required this.getCounts}) : super(CalendarInitial()) {
    on<LoadMonth>((e, emit) async {
      emit(MonthLoading(e.monthIndex));
      try {
        final month = monthFromIndex(e.monthIndex);
        final counts = await getCounts.call(month.year, month.month);
        emit(
          MonthLoaded(monthIndex: e.monthIndex, month: month, counts: counts),
        );
      } catch (e) {
        emit(CalendarError(e.toString()));
      }
    });
  }
}
