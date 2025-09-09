import 'package:flutter/material.dart';
import 'package:todo_app/src/core/constants/app_colors.dart';
import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';
import 'package:todo_app/src/feature/calendar/presentation/pages/event_details_page.dart';

class EventCard extends StatelessWidget {
  final EventEntity event;
  final VoidCallback? onChanged;
  const EventCard({super.key, required this.event, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForPriority(event.priority);
    final bg = colors['bg']!;
    final hat = colors['hat']!;
    final textColor = colors['text']!;

    return InkWell(
      onTap: () async {
        final changed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => EventDetailsPage(event: event)),
        );
        if (changed == true) {
          onChanged?.call();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(height: 10, width: double.infinity, color: hat),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                  if (event.subtitle != null && event.subtitle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        event.subtitle!,
                        style: TextStyle(color: textColor, fontSize: 14),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time_filled, color: hat, size: 16),
                      const SizedBox(width: 10),
                      Text(
                        "${formatTimeString(event.startTime)} - ${formatTimeString(event.endTime)}",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      if (event.location != null &&
                          event.location!.isNotEmpty) ...[
                        const SizedBox(width: 18),
                        Icon(Icons.location_on, color: hat, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Color> _colorsForPriority(Priority priority) {
    switch (priority) {
      case Priority.high:
        return {
          'bg': AppColors.paleRed,
          'hat': AppColors.saturatedRed,
          'text': AppColors.darkRed,
        };
      case Priority.normal:
        return {
          'bg': AppColors.paleOrange,
          'hat': AppColors.saturatedOrange,
          'text': AppColors.darkOrange,
        };
      case Priority.low:
        return {
          'bg': AppColors.paleBlue,
          'hat': AppColors.saturatedBlue,
          'text': AppColors.darkBlue,
        };
    }
  }

  String formatTimeString(String? s) {
    if (s == null || s.isEmpty) return '--';
    final hhmm = RegExp(r'^(\d{1,2}):(\d{2})$');
    final m = hhmm.firstMatch(s);
    if (m != null) {
      final h = int.tryParse(m.group(1)!) ?? 0;
      final mm = int.tryParse(m.group(2)!) ?? 0;
      return '${h.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
    }
    try {
      final dt = DateTime.parse(s);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return s;
    }
  }
}
