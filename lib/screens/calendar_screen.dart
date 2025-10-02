import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/habit_data_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  // Method to refresh calendar data (can be called from parent)
  void refreshCalendarData() {
    // Data is automatically refreshed through the provider
    setState(() {});
  }

  Widget _getMedalIcon(double completionPercentage) {
    if (completionPercentage >= 100) {
      return const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 20); // Gold
    } else if (completionPercentage >= 75) {
      return const Icon(Icons.emoji_events, color: Color(0xFFC0C0C0), size: 20); // Silver
    } else if (completionPercentage >= 50) {
      return const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 20); // Bronze
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Consumer<HabitDataProvider>(
        builder: (context, habitProvider, child) {
          return Center(
            child: Container(
              constraints: isLargeScreen ? const BoxConstraints(maxWidth: 1000) : null,
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      }
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        final percentage = habitProvider.getDailyCompletionPercentage(
                          DateTime(date.year, date.month, date.day),
                        );
                        if (percentage > 0) {
                          return Positioned(
                            bottom: 1,
                            child: _getMedalIcon(percentage),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                      ),
                      formatButtonTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: Colors.red),
                    ),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                  ),
                  const SizedBox(height: 16),
                  if (_selectedDay != null)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${habitProvider.getDailyCompletionPercentage(_selectedDay!).toStringAsFixed(1)}% completion rate',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}