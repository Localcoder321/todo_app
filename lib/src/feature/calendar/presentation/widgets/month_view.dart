import 'package:flutter/material.dart';
import 'package:todo_app/src/core/constants/app_colors.dart';
import 'package:todo_app/src/core/constants/constants.dart';

class MonthView extends StatelessWidget {
  final DateTime month;
  final Map<int, int> counts;
  final DateTime selectedDate;
  final Function(DateTime) onDaySelected;
  const MonthView({
    super.key,
    required this.month,
    required this.counts,
    required this.selectedDate,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final finstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = finstDayOfMonth.weekday == 7
        ? 0
        : finstDayOfMonth.weekday;
    List<Widget> dayWidgets = [];
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final current = DateTime(month.year, month.month, day);
      final isSelected = isSameDay(selectedDate, current);
      final count = counts[day] ?? 0;
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
                Text(
                  "$day",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.white : AppColors.black,
                  ),
                ),
                if (count > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
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
}
