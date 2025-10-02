import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../database/database_helper.dart';

class GlobalStatisticsScreen extends StatefulWidget {
  const GlobalStatisticsScreen({super.key});

  @override
  State<GlobalStatisticsScreen> createState() => _GlobalStatisticsScreenState();
}

class _GlobalStatisticsScreenState extends State<GlobalStatisticsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Habit> _habits = [];
  int _totalHabits = 0;
  int _totalCompletions = 0;
  int _totalCompletionsToday = 0;
  int _totalCompletionsThisWeek = 0;
  int _totalCompletionsThisMonth = 0;
  double _overallCompletionRate = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGlobalStatistics();
  }

  Future<void> _loadGlobalStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final habits = await _dbHelper.getAllHabits();
      final totalHabits = await _dbHelper.getTotalHabitsCount();
      
      int totalCompletions = 0;
      int totalCompletionsToday = 0;
      int totalCompletionsThisWeek = 0;
      int totalCompletionsThisMonth = 0;
      
      final today = DateTime.now();
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final startOfMonth = DateTime(today.year, today.month, 1);
      
      for (final habit in habits) {
        final entries = await _dbHelper.getHabitEntries(habit.id!);
        
        for (final entry in entries) {
          if (entry.completed) {
            totalCompletions++;
            
            if (isSameDay(entry.date, today)) {
              totalCompletionsToday++;
            }
            
            if (entry.date.isAfter(startOfWeek.subtract(const Duration(days: 1)))) {
              totalCompletionsThisWeek++;
            }
            
            if (entry.date.isAfter(startOfMonth.subtract(const Duration(days: 1)))) {
              totalCompletionsThisMonth++;
            }
          }
        }
      }
      
      // Calculate overall completion rate (last 30 days)
      final startOf30Days = today.subtract(const Duration(days: 30));
      int totalPossibleCompletions = 0;
      int actualCompletions = 0;
      
      for (final habit in habits) {
        for (int i = 0; i < 30; i++) {
          final date = startOf30Days.add(Duration(days: i));
          totalPossibleCompletions++;
          
          final entry = await _dbHelper.getHabitEntry(habit.id!, date);
          if (entry != null && entry.completed) {
            actualCompletions++;
          }
        }
      }
      
      final overallCompletionRate = totalPossibleCompletions > 0 
          ? (actualCompletions / totalPossibleCompletions) * 100 
          : 0.0;

      setState(() {
        _habits = habits;
        _totalHabits = totalHabits;
        _totalCompletions = totalCompletions;
        _totalCompletionsToday = totalCompletionsToday;
        _totalCompletionsThisWeek = totalCompletionsThisWeek;
        _totalCompletionsThisMonth = totalCompletionsThisMonth;
        _overallCompletionRate = overallCompletionRate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Statistics'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                constraints: isTablet ? const BoxConstraints(maxWidth: 800) : null,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Overview Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Habits',
                          '$_totalHabits',
                          Icons.list_alt,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Total Completions',
                          '$_totalCompletions',
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Today',
                          '$_totalCompletionsToday',
                          Icons.today,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'This Week',
                          '$_totalCompletionsThisWeek',
                          Icons.date_range,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'This Month',
                          '$_totalCompletionsThisMonth',
                          Icons.calendar_month,
                          Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Success Rate',
                          '${_overallCompletionRate.toStringAsFixed(1)}%',
                          Icons.trending_up,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Progress Overview
                  const Text(
                    'Progress Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildProgressBar(
                            'Today\'s Progress',
                            _totalCompletionsToday,
                            _totalHabits,
                            Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          _buildProgressBar(
                            'This Week\'s Progress',
                            _totalCompletionsThisWeek,
                            _totalHabits * 7,
                            Colors.purple,
                          ),
                          const SizedBox(height: 16),
                          _buildProgressBar(
                            'This Month\'s Progress',
                            _totalCompletionsThisMonth,
                            _totalHabits * 30,
                            Colors.teal,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Habit Performance
                  const Text(
                    'Habit Performance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  if (_habits.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.analytics,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No habits to analyze',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Card(
                      child: Column(
                        children: _habits.map((habit) {
                          return FutureBuilder<double>(
                            future: _dbHelper.getCompletionRate(habit.id!, days: 30),
                            builder: (context, snapshot) {
                              final completionRate = snapshot.data ?? 0.0;
                              return ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      habit.icon,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  habit.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(habit.description),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${completionRate.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _getCompletionRateColor(completionRate),
                                      ),
                                    ),
                                    Text(
                                      '30 days',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Achievement Summary
                  const Text(
                    'Achievement Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildAchievementRow(
                            'Perfect Day',
                            'Complete all habits in one day',
                            _totalCompletionsToday == _totalHabits && _totalHabits > 0,
                          ),
                          const Divider(),
                          _buildAchievementRow(
                            'Consistent Week',
                            'Complete at least 70% of habits this week',
                            _totalCompletionsThisWeek >= (_totalHabits * 7 * 0.7),
                          ),
                          const Divider(),
                          _buildAchievementRow(
                            'Monthly Master',
                            'Complete at least 80% of habits this month',
                            _totalCompletionsThisMonth >= (_totalHabits * 30 * 0.8),
                          ),
                        ],
                      ),
                    ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementRow(String title, String description, bool achieved) {
    return Row(
      children: [
        Icon(
          achieved ? Icons.check_circle : Icons.radio_button_unchecked,
          color: achieved ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: achieved ? Colors.green : Colors.grey[700],
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCompletionRateColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.orange;
    if (rate >= 40) return Colors.amber;
    return Colors.red;
  }

  Widget _buildProgressBar(String title, int completed, int total, Color color) {
    final percentage = total > 0 ? (completed / total) * 100 : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$completed / $total (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: total > 0 ? completed / total : 0.0,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }
}
