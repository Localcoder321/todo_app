part of 'event_edit_bloc.dart';

abstract class EventEditState extends Equatable {
  const EventEditState();

  @override
  List<Object?> get props => [];
}

class EventEditInitial extends EventEditState {}

class EventEditSaving extends EventEditState {}

class EventEditSaved extends EventEditState {}

class EventEditError extends EventEditState {
  final String message;
  const EventEditError(this.message);

  @override
  List<Object?> get props => [message];
}
