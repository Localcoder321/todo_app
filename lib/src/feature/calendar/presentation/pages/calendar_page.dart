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

    // initial page index centered on current month
    _currentIndex = indexFromMonth(DateTime.now());
    _pageController = PageController(initialPage: _currentIndex);

    // safe to call bloc after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<CalendarBloc>();
      bloc.add(LoadMonth(_currentIndex));
      bloc.add(LoadDayEvents(_selectedDate));

      // Subscribe to EventEditBloc stream so we react to create/update/delete actions
      // This lets CalendarPage refresh itself whenever event operations complete,
      // without needing the UI pages to return a value.
      try {
        final editBloc = context.read<EventEditBloc>();
        _eventEditSub = editBloc.stream.listen((state) {
          // Heuristic: when an edit bloc state appears (any state),
          // trigger a reload of the current month & day.
          // We avoid aggressive reloads by ignoring rapidly repeating 'loading' state names.
          final name = state.runtimeType.toString().toLowerCase();
          if (!name.contains('loading')) {
            // Slight delay to allow DB transaction to complete if needed
            Future.delayed(const Duration(milliseconds: 120), () {
              if (mounted) {
                context.read<CalendarBloc>().add(LoadMonth(_currentIndex));
                context.read<CalendarBloc>().add(LoadDayEvents(_selectedDate));
              }
            });
          }
        });
      } catch (e) {
        // If EventEditBloc is not provided for some reason, we just skip subscription.
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

  /// Called by child widgets (EventCard / ScheduleList) when events changed.
  void _onChildChanged() {
    // reload current month and day when something changed
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
          "${monthNames[monthDate.month - 1]} ${monthDate.year}",
          style: TextStyle(color: AppColors.black, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.black),
          onPressed: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
        actions: [
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
      body: BlocListener<CalendarBloc, CalendarState>(
        listener: (context, state) {
          if (state is DayEventsLoaded) {
            if (isSameDay(state.date, _selectedDate)) {
              setState(() => _dayEvents = List.from(state.events));
            }
          }
          if (state is MonthLoaded) {
            final m = state.month;
            if (_selectedDate.year != m.year ||
                _selectedDate.month != m.month) {
              setState(() => _selectedDate = DateTime(m.year, m.month, 1));
              context.read<CalendarBloc>().add(LoadDayEvents(_selectedDate));
            }
          }
          if (state is CalendarError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Calendar error: ${state.message}')),
            );
          }
        },
        child: Column(
          children: [
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
            // Calendar pager (lazy-loaded)
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

                      // If we have MonthLoaded for this index — show with counts
                      if (state is MonthLoaded && state.monthIndex == idx) {
                        final Map<int, int> dayCounts = {};
                        state.counts.forEach((k, v) {
                          try {
                            final d = parseYmd(k);
                            if (d.year == month.year &&
                                d.month == month.month) {
                              dayCounts[d.day] = v;
                            }
                          } catch (e) {
                            log("Error parsing date from counts: $e");
                          }
                        });

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: MonthView(
                            month: state.month,
                            counts: dayCounts,
                            selectedDate: _selectedDate,
                            onDaySelected: (d) {
                              setState(() => _selectedDate = d);
                              context.read<CalendarBloc>().add(
                                LoadDayEvents(d),
                              );
                            },
                          ),
                        );
                      }

                      // IMPORTANT: Fallback - show empty MonthView while DB loads.
                      // This prevents an eternal full-screen spinner while the bloc fetches counts.
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: MonthView(
                          month: month,
                          counts: const {},
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

            // Schedule / Add area (Figma style)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // date + add
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Schedule",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.add,
                          size: 18,
                          color: AppColors.white,
                        ),
                        label: const Text(
                          "Add",
                          style: TextStyle(color: AppColors.white),
                        ),
                        onPressed: () async {
                          // open Add screen with selected date prefilled
                          final changed = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddEditEventPage(initialDate: _selectedDate),
                            ),
                          );

                          // If the page returned true -> child created/updated something
                          // otherwise we also schedule a safe reload to ensure consistency.
                          if (changed == true) {
                            _onChildChanged();
                          } else {
                            // make sure to re-query current month/day (safe)
                            context.read<CalendarBloc>().add(
                              LoadMonth(_currentIndex),
                            );
                            context.read<CalendarBloc>().add(
                              LoadDayEvents(_selectedDate),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Schedule list: pass callback so EventCard can notify changes
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
