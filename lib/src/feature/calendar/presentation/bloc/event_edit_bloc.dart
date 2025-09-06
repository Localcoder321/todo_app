import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';
import 'package:todo_app/src/feature/calendar/domain/usecase/add_event_usecase.dart';
import 'package:todo_app/src/feature/calendar/domain/usecase/delete_event_usecase.dart';
import 'package:todo_app/src/feature/calendar/domain/usecase/update_event_usecase.dart';

part 'event_edit_event.dart';
part 'event_edit_state.dart';

class EventEditBloc extends Bloc<EventEditEvent, EventEditState> {
  final AddEventUsecase addEvent;
  final UpdateEventUsecase updateEvent;
  final DeleteEventUsecase deleteEvent;
  EventEditBloc({
    required this.addEvent,
    required this.updateEvent,
    required this.deleteEvent,
  }) : super(EventEditInitial()) {
    on<CreateEvent>((e, emit) async {
      emit(EventEditSaving());
      try {
        await addEvent.call(e.event);
        emit(EventEditSaved());
      } catch (e) {
        emit(EventEditError(e.toString()));
      }
    });
    on<ModifyEvent>((e, emit) async {
      emit(EventEditSaving());
      try {
        await updateEvent.call(e.event);
        emit(EventEditSaved());
      } catch (e) {
        emit(EventEditError(e.toString()));
      }
    });
    on<RemoveEvent>((e, emit) async {
      emit(EventEditSaving());
      try {
        await deleteEvent.call(e.id);
        emit(EventEditSaved());
      } catch (e) {
        emit(EventEditError(e.toString()));
      }
    });
  }
}
