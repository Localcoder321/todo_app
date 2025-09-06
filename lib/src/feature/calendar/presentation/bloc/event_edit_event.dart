part of 'event_edit_bloc.dart';

abstract class EventEditEvent extends Equatable {
  const EventEditEvent();

  @override
  List<Object?> get props => [];
}

class CreateEvent extends EventEditEvent {
  final EventEntity event;
  const CreateEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class ModifyEvent extends EventEditEvent {
  final EventEntity event;
  const ModifyEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class RemoveEvent extends EventEditEvent {
  final int id;
  const RemoveEvent(this.id);

  @override
  List<Object?> get props => [id];
}
