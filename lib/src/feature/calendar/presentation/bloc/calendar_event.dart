part of 'calendar_bloc.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadMonth extends CalendarEvent {
  final int monthIndex;

  const LoadMonth(this.monthIndex);

  @override
  List<Object?> get props => [monthIndex];
}
