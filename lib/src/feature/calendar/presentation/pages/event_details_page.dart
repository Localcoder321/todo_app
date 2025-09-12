import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/src/core/constants/app_colors.dart';
import 'package:todo_app/src/core/routers/app_router.dart';
import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';
import 'package:todo_app/src/feature/calendar/presentation/bloc/event_edit_bloc.dart';

class EventDetailsPage extends StatefulWidget {
  final EventEntity event;
  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late EventEntity _event;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  @override
  Widget build(BuildContext context) {
    final start = DateTime.tryParse(_event.startTime ?? '');
    final end = DateTime.tryParse(_event.endTime ?? '');

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        label: const Text(
                          "Edit",
                          style: TextStyle(color: AppColors.white),
                        ),
                        icon: const Icon(Icons.edit, color: AppColors.white),
                        onPressed: () async {
                          final shouldRefresh = await context.push<bool>(
                            RouteNames.addEventPage,
                            extra: _event,
                          );
                          if (shouldRefresh == true) {
                            context.read<EventEditBloc>().add(
                              ModifyEvent(_event),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _event.title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_event.subtitle != null && _event.subtitle!.isNotEmpty)
                    Text(
                      _event.subtitle!,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 12),
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
                  if (_event.location != null && _event.location!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.place,
                          color: AppColors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _event.location!,
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
                  _event.note?.isNotEmpty == true
                      ? _event.note!
                      : "No description provided.",
                  style: const TextStyle(color: AppColors.grey),
                ),
              ],
            ),
          ),
          const Spacer(),
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
                context.read<EventEditBloc>().add(RemoveEvent(_event.id!));
                context.pop(true);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
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
