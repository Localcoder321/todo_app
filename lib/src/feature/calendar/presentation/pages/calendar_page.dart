import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/src/core/constants/app_colors.dart';
import 'package:todo_app/src/core/constants/constants.dart';
import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';
import 'package:todo_app/src/feature/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:todo_app/src/feature/calendar/presentation/widgets/month_view.dart';
import 'package:todo_app/src/feature/calendar/presentation/widgets/schedule_list.dart';
import 'package:todo_app/src/feature/calendar/presentation/pages/add_edit_event_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final PageController _pageController;
  late int _currentIndex;
  DateTime _selectedDate = DateTime.now();
  List<EventEntity> _dayEvents = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = indexFromMonth(DateTime.now());
    _pageController = PageController(initialPage: _currentIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<CalendarBloc>();
      bloc.add(LoadMonth(_currentIndex));
      bloc.add(LoadDayEvents(_selectedDate));
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthDate = monthFromIndex(_currentIndex);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          "${monthNames[monthDate.month - 1]} ${monthDate.year}",
          style: TextStyle(color: AppColors.black, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: BlocListener<CalendarBloc, CalendarState>(
        listener: (context, state) {
          if (state is CalendarError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Calendar error: ${state.message}')),
            );
          } else if (state is DayEventsLoaded) {
            if (isSameDay(state.date, _selectedDate)) {
              setState(() => _dayEvents = List.from(state.events));
            }
          } else if (state is MonthLoaded) {
            final m = state.month;
            if (_selectedDate.year != m.year ||
                _selectedDate.month != m.month) {
              setState(() => _selectedDate = DateTime(m.year, m.month, 1));
              context.read<CalendarBloc>().add(LoadDayEvents(_selectedDate));
            }
          }
        },
        child: Column(
          children: [
            // calendar month pages
            Expanded(
              child: BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, state) {
                  return PageView.builder(
                    controller: _pageController,
                    itemCount: monthsTotal(),
                    onPageChanged: (idx) {
                      setState(() => _currentIndex = idx);
                      context.read<CalendarBloc>().add(LoadMonth(idx));
                    },
                    itemBuilder: (context, idx) {
                      final month = monthFromIndex(idx);

                      if (state is MonthLoaded && state.monthIndex == idx) {
                        final Map<int, int> dayCounts = {};
                        state.counts.forEach((k, v) {
                          try {
                            final d = parseYmd(k);
                            if (d.year == month.year &&
                                d.month == month.month) {
                              dayCounts[d.day] = v;
                            }
                          } catch (_) {}
                        });

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
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

                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                },
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
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
                        "${_selectedDate.day} ${monthNames[_selectedDate.month - 1]} ${_selectedDate.year}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddEditEventPage(initialDate: _selectedDate),
                            ),
                          );
                          context.read<CalendarBloc>().add(
                            LoadMonth(_currentIndex),
                          );
                          context.read<CalendarBloc>().add(
                            LoadDayEvents(_selectedDate),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ScheduleList(events: _dayEvents),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
