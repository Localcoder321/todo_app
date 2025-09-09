import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/src/core/constants/app_colors.dart';
import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';
import 'package:todo_app/src/feature/calendar/presentation/bloc/event_edit_bloc.dart';
import 'package:todo_app/src/feature/calendar/presentation/pages/add_edit_event_page.dart';

class EventDetailsPage extends StatelessWidget {
  final EventEntity event;
  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final start = DateTime.tryParse(event.startTime ?? '');
    final end = DateTime.tryParse(event.endTime ?? '');

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔵 HEADER CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.white,
                        ),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.transparent,
                        ),
                        label: Text(
                          "Edit",
                          style: TextStyle(color: AppColors.white),
                        ),
                        icon: const Icon(Icons.edit, color: AppColors.white),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditEventPage(event: event),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (event.subtitle != null && event.subtitle!.isNotEmpty)
                    Text(
                      event.subtitle!,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Time + Location
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_filled,
                        color: AppColors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        start != null && end != null
                            ? "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} "
                                  "- ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}"
                            : "No time",
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (event.location != null && event.location!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.place,
                          color: AppColors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          event.subtitle!,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 🕑 Reminder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Reminder",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  "15 minutes before",
                  style: TextStyle(color: AppColors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 📖 Description (NOTE field)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  event.note?.isNotEmpty == true
                      ? event.note!
                      : "No description provided.",
                  style: const TextStyle(color: AppColors.grey),
                ),
              ],
            ),
          ),

          const Spacer(),
          // 🗑️ Delete button
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 50,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFFEE8E9),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                context.read<EventEditBloc>().add(RemoveEvent(event.id!));
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, color: AppColors.red),
                    SizedBox(width: 8),
                    Text(
                      "Delete Event",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
