import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';
import 'package:todo_app/src/feature/calendar/domain/repository/event_repository.dart';

class AddEventUsecase {
  final EventRepository repo;
  AddEventUsecase(this.repo);
  Future<int> call(EventEntity e) => repo.addEvent(e);
}
