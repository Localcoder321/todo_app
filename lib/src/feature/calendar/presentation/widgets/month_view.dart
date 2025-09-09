import 'package:flutter/material.dart';
import 'package:todo_app/src/core/constants/app_colors.dart';
import 'package:todo_app/src/core/constants/constants.dart';
import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';

class MonthView extends StatelessWidget {
  final DateTime month;
  /// day -> list of priorities
  final Map<int, List<Priority>> dayEvents;
  final DateTime selectedDate;
  final Function(DateTime) onDaySelected;

  const MonthView({
    super.key,
    required this.month,
    required this.dayEvents,
    required this.selectedDate,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final current = DateTime(month.year, month.month, day);
      final isSelected = isSameDay(selectedDate, current);
      final priorities = dayEvents[day] ?? [];

      dayWidgets.add(
        GestureDetector(
          onTap: () => onDaySelected(current),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.blue : AppColors.transparent,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Day number
                Text(
                  "$day",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.white : AppColors.black,
                  ),
                ),

                // Dots for events
                if (priorities.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: priorities.take(3).map((priority) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _priorityColor(priority),
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: dayWidgets,
    );
  }

  Color _priorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return AppColors.saturatedRed;
      case Priority.normal:
        return AppColors.saturatedOrange;
      case Priority.low:
        return AppColors.saturatedBlue;
    }
  }
}
