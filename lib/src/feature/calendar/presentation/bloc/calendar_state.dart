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
  final Map<String, int> counts;

  const MonthLoaded({
    required this.monthIndex,
    required this.month,
    required this.counts,
  });

  @override
  List<Object?> get props => [monthIndex, month, counts];
}

class CalendarError extends CalendarState {
  final String message;

  const CalendarError(this.message);

  @override
  List<Object?> get props => [message];
}
