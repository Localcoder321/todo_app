import 'package:flutter/material.dart';
import 'package:todo_app/src/core/constants/app_colors.dart';
import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';
import 'package:todo_app/src/feature/calendar/presentation/widgets/event_card.dart';

class ScheduleList extends StatelessWidget {
  final List<EventEntity> events;
  final VoidCallback? onChanged;

  const ScheduleList({super.key, required this.events, this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          "No events scheduled",
          style: TextStyle(color: AppColors.grey, fontSize: 14),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) => EventCard(event: events[i], onChanged: onChanged),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: events.length,
    );
  }
}
