import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../models/habit_entry.dart';
import '../database/database_helper.dart';
import '../theme/color_extensions.dart';

class HabitStatisticsScreen extends StatefulWidget {
  final Habit habit;

  const HabitStatisticsScreen({super.key, required this.habit});

  @override
  State<HabitStatisticsScreen> createState() => _HabitStatisticsScreenState();
}

class _HabitStatisticsScreenState extends State<HabitStatisticsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<HabitEntry> _entries = [];
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _totalCompletions = 0;
  double _completionRate30Days = 0.0;
  double _completionRate7Days = 0.0;
  double _completionRate90Days = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await _dbHelper.getHabitEntries(widget.habit.id!);
      final currentStreak = await _dbHelper.getStreak(widget.habit.id!);
      final bestStreak = await _dbHelper.getBestStreak(widget.habit.id!);
      final totalCompletions = await _dbHelper.getTotalCompletions(widget.habit.id!);
      final completionRate30Days = await _dbHelper.getCompletionRate(widget.habit.id!, days: 30);
      final completionRate7Days = await _dbHelper.getCompletionRate(widget.habit.id!, days: 7);
      final completionRate90Days = await _dbHelper.getCompletionRate(widget.habit.id!, days: 90);
      
      setState(() {
        _entries = entries;
        _currentStreak = currentStreak;
        _bestStreak = bestStreak;
        _totalCompletions = totalCompletions;
        _completionRate30Days = completionRate30Days;
        _completionRate7Days = completionRate7Days;
        _completionRate90Days = completionRate90Days;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading habit statistics: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.habit.icon} ${widget.habit.name}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                constraints: isLargeScreen ? const BoxConstraints(maxWidth: 800) : null,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Habit Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.habit.icon,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.habit.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.habit.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Statistics Cards
                  if (isTablet) ...[
                    // Tablet layout - 3 columns
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Current Streak',
                            '$_currentStreak days',
                            Icons.local_fire_department,
                            Theme.of(context).colorScheme.statsOrange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Best Streak',
                            '$_bestStreak days',
                            Icons.emoji_events,
                            Theme.of(context).colorScheme.statsAmber,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Total Completions',
                            '$_totalCompletions',
                            Icons.check_circle,
                            Theme.of(context).colorScheme.statsGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '7-Day Rate',
                            '${_completionRate7Days.toStringAsFixed(1)}%',
                            Icons.trending_up,
                            Theme.of(context).colorScheme.statsBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            '30-Day Rate',
                            '${_completionRate30Days.toStringAsFixed(1)}%',
                            Icons.analytics,
                            Theme.of(context).colorScheme.statsPurple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            '90-Day Rate',
                            '${_completionRate90Days.toStringAsFixed(1)}%',
                            Icons.timeline,
                            Theme.of(context).colorScheme.statsTeal,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Mobile layout - 2 columns
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Current Streak',
                            '$_currentStreak days',
                            Icons.local_fire_department,
                            Theme.of(context).colorScheme.statsOrange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Best Streak',
                            '$_bestStreak days',
                            Icons.emoji_events,
                            Theme.of(context).colorScheme.statsAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Completions',
                            '$_totalCompletions',
                            Icons.check_circle,
                            Theme.of(context).colorScheme.statsGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            '7-Day Rate',
                            '${_completionRate7Days.toStringAsFixed(1)}%',
                            Icons.trending_up,
                            Theme.of(context).colorScheme.statsBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '30-Day Rate',
                            '${_completionRate30Days.toStringAsFixed(1)}%',
                            Icons.analytics,
                            Theme.of(context).colorScheme.statsPurple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            '90-Day Rate',
                            '${_completionRate90Days.toStringAsFixed(1)}%',
                            Icons.timeline,
                            Theme.of(context).colorScheme.statsTeal,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Recent Activity
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  if (_entries.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.history,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No activity yet',
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
                        children: _entries.take(10).map((entry) {
                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: entry.completed ? Colors.green : Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                entry.completed ? Icons.check : Icons.close,
                                color: entry.completed ? Colors.white : Colors.grey[600],
                              ),
                            ),
                            title: Text(
                              DateFormat('MMM dd, yyyy').format(entry.date),
                              style: TextStyle(
                                fontWeight: entry.completed ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              entry.completed ? 'Completed' : 'Not completed',
                              style: TextStyle(
                                color: entry.completed ? Colors.green : Colors.grey[600],
                              ),
                            ),
                            trailing: entry.completed
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : const Icon(Icons.cancel, color: Colors.grey),
                          );
                        }).toList(),
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
}


