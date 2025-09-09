import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';
import 'package:todo_app/src/feature/calendar/domain/repository/event_repository.dart';

class GetEventsForMonthUsecase {
  final EventRepository repo;
  GetEventsForMonthUsecase(this.repo);

  Future<List<EventEntity>> call(int year, int month) {
    return repo.getEventsForMonth(year, month);
  }
}