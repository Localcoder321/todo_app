import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';
import 'package:todo_app/src/feature/calendar/domain/repository/event_repository.dart';

class GetEventsForDayUsecase {
  EventRepository repo;
  GetEventsForDayUsecase(this.repo);
  Future<List<EventEntity>> call(DateTime date) => repo.eventsOn(date);
}
