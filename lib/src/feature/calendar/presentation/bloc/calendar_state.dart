part of 'calendar_bloc.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();
  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {}

class MonthLoading extends CalendarState {
  final int monthIndex;
  const MonthLoading(this.monthIndex);

  @override
  List<Object?> get props => [monthIndex];
}

class MonthLoaded extends CalendarState {
  final int monthIndex;
  final DateTime month;
  final List<EventEntity> events;

  const MonthLoaded({
    required this.monthIndex,
    required this.month,
    required this.events,
  });

  @override
  List<Object?> get props => [monthIndex, month, events];
}

class DayEventsLoading extends CalendarState {
  final DateTime date;
  const DayEventsLoading(this.date);

  @override
  List<Object?> get props => [date];
}

class DayEventsLoaded extends CalendarState {
  final DateTime date;
  final List<EventEntity> events;
  const DayEventsLoaded({required this.date, required this.events});

  @override
  List<Object?> get props => [date, events];
}

class CalendarError extends CalendarState {
  final String message;
  const CalendarError(this.message);

  @override
  List<Object?> get props => [message];
}
