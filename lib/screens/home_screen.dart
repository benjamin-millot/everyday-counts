import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_entry.dart';
import '../database/database_helper.dart';
import '../theme/color_extensions.dart';
import 'add_edit_habit_screen.dart';
import 'habit_statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Habit> _habits = [];
  DateTime _selectedDate = DateTime.now();
  Map<int, bool> _habitCompletions = {};

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    try {
      final habits = await _dbHelper.getAllHabits();
      setState(() {
        _habits = habits;
      });
      _loadHabitCompletions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading habits: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _loadHabitCompletions() async {
    try {
      final completions = <int, bool>{};
      for (final habit in _habits) {
        if (habit.id != null) {
          final entry = await _dbHelper.getHabitEntry(habit.id!, _selectedDate);
          completions[habit.id!] = entry?.completed ?? false;
        }
      }
      setState(() {
        _habitCompletions = completions;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading habit completions: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleHabitCompletion(int habitId) async {
    try {
      final isCompleted = _habitCompletions[habitId] ?? false;
      final newCompletion = !isCompleted;
      
      setState(() {
        _habitCompletions[habitId] = newCompletion;
      });

      final existingEntry = await _dbHelper.getHabitEntry(habitId, _selectedDate);
      
      if (existingEntry != null) {
        final updatedEntry = existingEntry.copyWith(completed: newCompletion);
        await _dbHelper.updateHabitEntry(updatedEntry);
      } else {
        final newEntry = HabitEntry(
          habitId: habitId,
          date: _selectedDate,
          completed: newCompletion,
        );
        await _dbHelper.insertHabitEntry(newEntry);
      }
    } catch (e) {
      // Revert the UI state on error
      setState(() {
        _habitCompletions[habitId] = !(_habitCompletions[habitId] ?? false);
      });
      
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
      final result = await Navigator.push<Habit>(
        context,
        MaterialPageRoute(builder: (context) => const AddEditHabitScreen()),
      );
      
      if (result != null) {
        await _dbHelper.insertHabit(result);
        _loadHabits();
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
      final result = await Navigator.push<Habit>(
        context,
        MaterialPageRoute(
          builder: (context) => AddEditHabitScreen(habit: habit),
        ),
      );
      
      if (result != null) {
        await _dbHelper.updateHabit(result);
        _loadHabits();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error editing habit: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteHabit(Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"?'),
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
        await _dbHelper.deleteHabit(habit.id!);
        _loadHabits();
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

  void _navigateToStatistics(Habit habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitStatisticsScreen(habit: habit),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
      ),
      body: Column(
        children: [
          // Date Selector
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: isTablet
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Selected Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                              });
                              _loadHabitCompletions();
                            },
                            icon: const Icon(Icons.chevron_left, size: 28),
                            iconSize: 28,
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = _selectedDate.add(const Duration(days: 1));
                              });
                              _loadHabitCompletions();
                            },
                            icon: const Icon(Icons.chevron_right, size: 28),
                            iconSize: 28,
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = DateTime.now();
                              });
                              _loadHabitCompletions();
                            },
                            icon: const Icon(Icons.today, size: 28),
                            iconSize: 28,
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        'Selected Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                              });
                              _loadHabitCompletions();
                            },
                            icon: const Icon(Icons.chevron_left),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = _selectedDate.add(const Duration(days: 1));
                              });
                              _loadHabitCompletions();
                            },
                            icon: const Icon(Icons.chevron_right),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = DateTime.now();
                              });
                              _loadHabitCompletions();
                            },
                            icon: const Icon(Icons.today),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          
          // Habits List
          Expanded(
            child: _habits.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_task,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No habits yet!',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first habit',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : isTablet
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _habits.length,
                        itemBuilder: (context, index) {
                          final habit = _habits[index];
                          final isCompleted = _habitCompletions[habit.id!] ?? false;
                          
                          return Card(
                            child: InkWell(
                              onTap: () => _toggleHabitCompletion(habit.id!),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: isCompleted ? Theme.of(context).colorScheme.success : Theme.of(context).colorScheme.surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              habit.icon,
                                              style: const TextStyle(fontSize: 24),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                habit.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                habit.description,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            switch (value) {
                                              case 'statistics':
                                                _navigateToStatistics(habit);
                                                break;
                                              case 'edit':
                                                _editHabit(habit);
                                                break;
                                              case 'delete':
                                                _deleteHabit(habit);
                                                break;
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'statistics',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.analytics),
                                                  SizedBox(width: 8),
                                                  Text('Statistics'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit),
                                                  SizedBox(width: 8),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete),
                                                  SizedBox(width: 8),
                                                  Text('Delete'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _habits.length,
                        itemBuilder: (context, index) {
                          final habit = _habits[index];
                          final isCompleted = _habitCompletions[habit.id!] ?? false;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isCompleted ? Theme.of(context).colorScheme.success : Theme.of(context).colorScheme.surfaceContainerHighest,
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              subtitle: Text(habit.description),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _navigateToStatistics(habit),
                                    icon: const Icon(Icons.analytics),
                                    tooltip: 'Statistics',
                                  ),
                                  IconButton(
                                    onPressed: () => _editHabit(habit),
                                    icon: const Icon(Icons.edit),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteHabit(habit),
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                              onTap: () => _toggleHabitCompletion(habit.id!),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHabit,
        child: const Icon(Icons.add),
      ),
    );
  }
}

