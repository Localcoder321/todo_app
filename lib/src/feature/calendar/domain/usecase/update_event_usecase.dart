import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';
import 'package:todo_app/src/feature/calendar/domain/repository/event_repository.dart';

class UpdateEventUsecase {
  EventRepository repo;
  UpdateEventUsecase(this.repo);
  Future<void> call(EventEntity e) => repo.updateEvent(e);
}
