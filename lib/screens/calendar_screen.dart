import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database/database_helper.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, double> _completionPercentages = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadCompletedHabitsData();
  }

  Future<void> _loadCompletedHabitsData() async {
    try {
      final Map<DateTime, double> data = {};
      
      // Load data for the current month and surrounding months
      final startDate = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      final endDate = DateTime(_focusedDay.year, _focusedDay.month + 2, 0);
      
      for (DateTime date = startDate; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
        final percentage = await _dbHelper.getCompletionPercentage(date);
        if (percentage > 0) {
          data[date] = percentage;
        }
      }
      
      setState(() {
        _completionPercentages = data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading calendar data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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

  String _getMedalText(double completionPercentage) {
    if (completionPercentage >= 100) {
      return 'Gold Medal! 🏆';
    } else if (completionPercentage >= 75) {
      return 'Silver Medal! 🥈';
    } else if (completionPercentage >= 50) {
      return 'Bronze Medal! 🥉';
    }
    return 'No medal earned';
  }

  Color _getMedalColor(double completionPercentage) {
    if (completionPercentage >= 100) {
      return const Color(0xFFFFD700); // Gold
    } else if (completionPercentage >= 75) {
      return const Color(0xFFC0C0C0); // Silver
    } else if (completionPercentage >= 50) {
      return const Color(0xFFCD7F32); // Bronze
    }
    return Colors.grey;
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
      body: Center(
        child: Container(
          constraints: isLargeScreen ? const BoxConstraints(maxWidth: 1000) : null,
          child: Column(
            children: [
              // Calendar
              Expanded(
                child: TableCalendar<double>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: (day) {
              final normalizedDay = DateTime(day.year, day.month, day.day);
              return _completionPercentages[normalizedDay] != null
                  ? [_completionPercentages[normalizedDay]!]
                  : [];
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              formatButtonTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _loadCompletedHabitsData();
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: _getMedalIcon(events.first),
                  );
                }
                return null;
              },
            ),
                ),
              ),
          
          // Selected Day Info and Legend
          if (_selectedDay != null) ...[
                const SizedBox(height: 16),
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _getMedalIcon(_completionPercentages[_selectedDay!] ?? 0),
                          const SizedBox(width: 8),
                          Text(
                            _getMedalText(_completionPercentages[_selectedDay!] ?? 0),
                            style: TextStyle(
                              fontSize: 16,
                              color: _getMedalColor(_completionPercentages[_selectedDay!] ?? 0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_completionPercentages[_selectedDay!] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${_completionPercentages[_selectedDay!]!.toStringAsFixed(1)}% completion rate',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              
              // Legend
              const SizedBox(height: 16),
              Container(
                margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Medal Legend:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isTablet) ...[
                      // Tablet layout - side by side
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 20),
                                const SizedBox(width: 8),
                                const Text('Gold: 100% completion'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.emoji_events, color: Color(0xFFC0C0C0), size: 20),
                                const SizedBox(width: 8),
                                const Text('Silver: 75%+ completion'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 20),
                          const SizedBox(width: 8),
                          const Text('Bronze: 50%+ completion'),
                        ],
                      ),
                    ] else ...[
                      // Mobile layout - stacked
                      Row(
                        children: [
                          const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Gold: 100%',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.emoji_events, color: Color(0xFFC0C0C0), size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Silver: 75%+',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Bronze: 50%+',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

