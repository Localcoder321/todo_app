import 'package:todo_app/src/feature/calendar/domain/repository/event_repository.dart';

class GetEventCountsForMonthUsecase {
  EventRepository repo;
  GetEventCountsForMonthUsecase(this.repo);
  Future<Map<String, int>> call(int year, int month) =>
      repo.eventCountsForMonth(year, month);
}
