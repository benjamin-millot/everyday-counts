import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_data_provider.dart';
import '../widgets/habit_card.dart';
import '../theme/color_extensions.dart';
import 'habit_form_screen.dart';
import 'habit_detail_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
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
                    Icons.add_task,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No habits yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first habit to get started!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Date selector
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _previousDay,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    TextButton(
                      onPressed: _showDatePicker,
                      child: Text(
                        _formatDate(habitProvider.selectedDate),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: _nextDay,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
              
              // Habits list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: habitProvider.habits.length,
                  itemBuilder: (context, index) {
                    final habit = habitProvider.habits[index];
                    final isCompleted = habitProvider.isHabitCompleted(
                      habit.id!,
                      habitProvider.selectedDate,
                    );
                    
                    return HabitCard(
                      habit: habit,
                      isCompleted: isCompleted,
                      onToggleCompletion: () => _toggleHabitCompletion(
                        habitProvider,
                        habit.id!,
                      ),
                      onEdit: () => _editHabit(habit),
                      onDelete: () => _deleteHabit(habitProvider, habit.id!),
                      onShowStatistics: () => _showHabitStatistics(habit),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHabit,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDatePicker() {
    final habitProvider = Provider.of<HabitDataProvider>(context, listen: false);
    showDatePicker(
      context: context,
      initialDate: habitProvider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((selectedDate) {
      if (selectedDate != null) {
        habitProvider.setSelectedDate(selectedDate);
      }
    });
  }

  void _previousDay() {
    final habitProvider = Provider.of<HabitDataProvider>(context, listen: false);
    final newDate = habitProvider.selectedDate.subtract(const Duration(days: 1));
    habitProvider.setSelectedDate(newDate);
  }

  void _nextDay() {
    final habitProvider = Provider.of<HabitDataProvider>(context, listen: false);
    final newDate = habitProvider.selectedDate.add(const Duration(days: 1));
    if (newDate.isBefore(DateTime.now().add(const Duration(days: 1)))) {
      habitProvider.setSelectedDate(newDate);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _toggleHabitCompletion(
    HabitDataProvider habitProvider,
    int habitId,
  ) async {
    try {
      await habitProvider.toggleHabitCompletion(
        habitId,
        habitProvider.selectedDate,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating habit: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _addHabit() async {
    try {
      final habitProvider = Provider.of<HabitDataProvider>(context, listen: false);
      final result = await Navigator.push<Habit>(
        context,
        MaterialPageRoute(
          builder: (context) => const HabitFormScreen(),
        ),
      );

      if (result != null) {
        await habitProvider.addHabit(result);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Habit "${result.name}" added successfully!'),
              backgroundColor: Theme.of(context).colorScheme.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding habit: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _editHabit(Habit habit) async {
    try {
      final habitProvider = Provider.of<HabitDataProvider>(context, listen: false);
      final result = await Navigator.push<Habit>(
        context,
        MaterialPageRoute(
          builder: (context) => HabitFormScreen(habit: habit),
        ),
      );

      if (result != null) {
        await habitProvider.updateHabit(result);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Habit "${result.name}" updated successfully!'),
              backgroundColor: Theme.of(context).colorScheme.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating habit: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteHabit(HabitDataProvider habitProvider, int habitId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await habitProvider.deleteHabit(habitId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Habit deleted successfully!'),
              backgroundColor: Theme.of(context).colorScheme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting habit: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _showHabitStatistics(Habit habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailScreen(habit: habit),
      ),
    );
  }
}