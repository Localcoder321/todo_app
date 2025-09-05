import 'package:todo_app/src/feature/calendar/domain/repository/event_repository.dart';

class DeleteEventUsecase {
  EventRepository repo;
  DeleteEventUsecase(this.repo);
  Future<void> call(int id) => repo.deleteEvent(id);
}
