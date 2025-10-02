import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_data_provider.dart';
import '../theme/color_extensions.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
  }

  // Method to refresh statistics data (can be called from parent)
  void refreshStatisticsData() {
    // Data is automatically refreshed through the provider
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Consumer<HabitDataProvider>(
        builder: (context, habitProvider, child) {
          if (habitProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (habitProvider.habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No statistics available',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some habits to see your progress!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Statistics
                _buildOverallStatsCard(context, habitProvider),
                const SizedBox(height: 16),
                
                // Individual Habit Statistics
                _buildIndividualHabitsCard(context, habitProvider),
                const SizedBox(height: 16),
                
                // Completion Trends
                _buildCompletionTrendsCard(context, habitProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallStatsCard(BuildContext context, HabitDataProvider habitProvider) {
    final totalHabits = habitProvider.habits.length;
    final today = DateTime.now();
    final todayCompletions = habitProvider.habits.where((habit) => 
      habitProvider.isHabitCompleted(habit.id!, today)
    ).length;
    final overallCompletionRate = totalHabits > 0 ? (todayCompletions / totalHabits) * 100 : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Statistics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Habits',
                    totalHabits.toString(),
                    Icons.list_alt,
                    Theme.of(context).colorScheme.statsBlue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Completed Today',
                    todayCompletions.toString(),
                    Icons.check_circle,
                    Theme.of(context).colorScheme.statsGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Completion Rate',
                    '${overallCompletionRate.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Theme.of(context).colorScheme.statsOrange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Active Streaks',
                    habitProvider.streaks.values.where((streak) => streak > 0).length.toString(),
                    Icons.local_fire_department,
                    Theme.of(context).colorScheme.statsRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Current Streak',
                    habitProvider.streaks.values.isNotEmpty 
                        ? habitProvider.streaks.values.reduce((a, b) => a > b ? a : b).toString()
                        : '0',
                    Icons.local_fire_department,
                    Theme.of(context).colorScheme.statsAmber,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Max Streak',
                    habitProvider.bestStreaks.values.isNotEmpty 
                        ? habitProvider.bestStreaks.values.reduce((a, b) => a > b ? a : b).toString()
                        : '0',
                    Icons.emoji_events,
                    Theme.of(context).colorScheme.statsPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualHabitsCard(BuildContext context, HabitDataProvider habitProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Individual Habit Progress',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...habitProvider.habits.map((habit) {
              final streak = habitProvider.getStreak(habit.id!);
              final bestStreak = habitProvider.getBestStreak(habit.id!);
              final completionRate = habitProvider.getCompletionRate(habit.id!);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(
                      habit.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${completionRate.toStringAsFixed(1)}% completion rate',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (streak > 0 || bestStreak > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (streak > 0)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$streak',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (bestStreak > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$bestStreak',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionTrendsCard(BuildContext context, HabitDataProvider habitProvider) {
    final today = DateTime.now();
    final weekDays = List.generate(7, (index) {
      final date = today.subtract(Duration(days: 6 - index));
      return DateTime(date.year, date.month, date.day); // Normalize to start of day
    });
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Completion Trend',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDays.map((date) {
                final percentage = habitProvider.getDailyCompletionPercentage(date);
                final dayName = _getDayName(date.weekday);
                
                return Column(
                  children: [
                    Text(
                      dayName,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: (percentage / 100) * 60,
                            decoration: BoxDecoration(
                              color: _getCompletionColor(percentage),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  Color _getCompletionColor(double percentage) {
    if (percentage >= 100) {
      return Theme.of(context).colorScheme.statsGreen;
    } else if (percentage >= 75) {
      return Theme.of(context).colorScheme.statsOrange;
    } else if (percentage >= 50) {
      return Theme.of(context).colorScheme.statsAmber;
    } else {
      return Theme.of(context).colorScheme.statsRed;
    }
  }
}