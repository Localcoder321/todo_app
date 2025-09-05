import 'package:flutter/scheduler.dart';

class EventEntity {
  final int? id;
  final DateTime date;
  final String title;
  final String? subtitle;
  final Priority priority;
  final String? startTime;
  final String? endTime;

  EventEntity({
    this.id,
    required this.date,
    required this.title,
    this.subtitle,
    required this.priority,
    this.startTime,
    this.endTime,
  });
}
