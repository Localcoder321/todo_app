import 'package:go_router/go_router.dart';
import 'package:todo_app/not_found_screen.dart';
import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';
import 'package:todo_app/src/feature/calendar/presentation/pages/add_edit_event_page.dart';
import 'package:todo_app/src/feature/calendar/presentation/pages/calendar_page.dart';
import 'package:todo_app/src/feature/calendar/presentation/pages/event_details_page.dart';

part 'route_names.dart';

class AppRouter {
  AppRouter();

  GoRouter get router => _routerInstance;

  final GoRouter _routerInstance = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RouteNames.mainPage,
    errorBuilder: (context, state) => NotFoundScreen(),
    routes: [
      GoRoute(
        path: RouteNames.mainPage,
        builder: (context, state) => CalendarPage(),
      ),
      GoRoute(
        path: RouteNames.addEventPage,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is DateTime?) {
            return AddEditEventPage(initialDate: extra);
          }
          if (extra is EventEntity) {
            return AddEditEventPage(event: extra);
          }
          return AddEditEventPage();
        },
      ),
      GoRoute(
        path: RouteNames.eventDetails,
        builder: (context, state) {
          final event = state.extra as EventEntity?;
          if (event == null) {
            return const NotFoundScreen();
          }
          return EventDetailsPage(event: event);
        },
      ),
      GoRoute(
        path: RouteNames.notFoundPage,
        builder: (context, state) => NotFoundScreen(),
      ),
    ],
  );
}
