import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/src/core/constants/app_colors.dart';
import 'package:todo_app/src/core/constants/constants.dart';
import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';
import 'package:todo_app/src/feature/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:todo_app/src/feature/calendar/presentation/bloc/event_edit_bloc.dart';
import 'package:todo_app/src/feature/calendar/presentation/pages/add_edit_event_page.dart';
import 'package:todo_app/src/feature/calendar/presentation/widgets/month_view.dart';
import 'package:todo_app/src/feature/calendar/presentation/widgets/schedule_list.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late PageController _pageController;
  late int _currentIndex;
  DateTime _selectedDate = DateTime.now();
  List<EventEntity> _dayEvents = [];

  StreamSubscription? _eventEditSub;

  @override
  void initState() {
    super.initState();
    _currentIndex = indexFromMonth(DateTime.now());
    _pageController = PageController(initialPage: _currentIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<CalendarBloc>();
      bloc.add(LoadMonth(_currentIndex));
      bloc.add(LoadDayEvents(_selectedDate));

      try {
        final editBloc = context.read<EventEditBloc>();
        _eventEditSub = editBloc.stream.listen((state) {
          final name = state.runtimeType.toString().toLowerCase();
          if (!name.contains('loading')) {
            Future.delayed(const Duration(milliseconds: 120), () {
              if (mounted) {
                context.read<CalendarBloc>().add(LoadMonth(_currentIndex));
                context.read<CalendarBloc>().add(LoadDayEvents(_selectedDate));
              }
            });
          }
        });
      } catch (e) {
        log('EventEditBloc subscription skipped: $e');
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _eventEditSub?.cancel();
    super.dispose();
  }

  void _onChildChanged() {
    context.read<CalendarBloc>().add(LoadMonth(_currentIndex));
    context.read<CalendarBloc>().add(LoadDayEvents(_selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    final monthDate = monthFromIndex(_currentIndex);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(
          "${_selectedDate.day} ${monthNames[monthDate.month - 1]} ${monthDate.year}",
          style: TextStyle(color: AppColors.black, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocListener<CalendarBloc, CalendarState>(
        listener: (context, state) {
          if (state is DayEventsLoaded) {
            if (isSameDay(state.date, _selectedDate)) {
              setState(() => _dayEvents = List.from(state.events));
            }
          }
        },
        child: Column(
          children: [
            // header with month + arrows
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Row(
                children: [
                  Text(
                    monthNames[monthDate.month - 1],
                    style: TextStyle(color: AppColors.black, fontSize: 20),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppColors.black),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: AppColors.black),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ),

            // weekdays row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weekDaysShort
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            // month pages
            Expanded(
              child: BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, state) {
                  return PageView.builder(
                    controller: _pageController,
                    itemCount: monthsTotal(),
                    onPageChanged: (value) {
                      setState(() => _currentIndex = value);
                      context.read<CalendarBloc>().add(LoadMonth(value));
                    },
                    itemBuilder: (context, idx) {
                      final month = monthFromIndex(idx);

                      if (state is MonthLoaded && state.monthIndex == idx) {
                        final Map<int, List<Priority>> dayPriorities = {};

                        for (final e in state.events) {
                          if (e.date.year == month.year &&
                              e.date.month == month.month) {
                            dayPriorities.putIfAbsent(e.date.day, () => []);
                            dayPriorities[e.date.day]!.add(e.priority);
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: MonthView(
                            month: state.month,
                            dayEvents: dayPriorities,
                            selectedDate: _selectedDate,
                            onDaySelected: (d) {
                              setState(() => _selectedDate = d);
                              context.read<CalendarBloc>().add(LoadDayEvents(d));
                            },
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: MonthView(
                          month: month,
                          dayEvents: const {},
                          selectedDate: _selectedDate,
                          onDaySelected: (d) {
                            setState(() => _selectedDate = d);
                            context.read<CalendarBloc>().add(LoadDayEvents(d));
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // bottom schedule
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title + add btn
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Schedule",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 18, color: AppColors.white),
                        label: const Text("Add",
                            style: TextStyle(color: AppColors.white)),
                        onPressed: () async {
                          final changed = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddEditEventPage(initialDate: _selectedDate),
                            ),
                          );
                          if (changed == true) _onChildChanged();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ScheduleList(events: _dayEvents, onChanged: _onChildChanged),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
