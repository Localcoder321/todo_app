import 'package:flutter/material.dart';
import 'package:todo_app/src/core/constants/app_colors.dart';
import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';
import 'package:todo_app/src/feature/calendar/presentation/widgets/event_card.dart';

class ScheduleList extends StatelessWidget {
  final List<EventEntity> events;

  const ScheduleList({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          "No events scheduled",
          style: TextStyle(color: AppColors.grey),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) => EventCard(event: events[i]),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: events.length,
    );
  }
}
