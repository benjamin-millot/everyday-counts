import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_entry.dart';
import '../database/habit_database_service.dart';

class HabitDataProvider extends ChangeNotifier {
  final HabitDatabaseService _dbHelper = HabitDatabaseService();
  
  // Core data
  List<Habit> _habits = [];
  final Map<int, Map<DateTime, bool>> _habitCompletions = {};
  DateTime _selectedDate = DateTime.now();
  
  // Computed data
  final Map<int, int> _streaks = {};
  final Map<int, int> _bestStreaks = {};
  final Map<int, double> _completionRates = {};
  final Map<DateTime, double> _dailyCompletionPercentages = {};
  
  // Loading states
  bool _isLoading = false;
  final Map<int, bool> _habitLoadingStates = {};

  // Getters
  List<Habit> get habits => _habits;
  Map<int, Map<DateTime, bool>> get habitCompletions => _habitCompletions;
  DateTime get selectedDate => _selectedDate;
  Map<int, int> get streaks => _streaks;
  Map<int, int> get bestStreaks => _bestStreaks;
  Map<int, double> get completionRates => _completionRates;
  Map<DateTime, double> get dailyCompletionPercentages => _dailyCompletionPercentages;
  bool get isLoading => _isLoading;
  
  bool isHabitCompleted(int habitId, DateTime date) {
    return _habitCompletions[habitId]?[date] ?? false;
  }
  
  int getStreak(int habitId) {
    return _streaks[habitId] ?? 0;
  }
  
  int getBestStreak(int habitId) {
    return _bestStreaks[habitId] ?? 0;
  }
  
  double getCompletionRate(int habitId) {
    return _completionRates[habitId] ?? 0.0;
  }
  
  double getDailyCompletionPercentage(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _dailyCompletionPercentages[normalizedDate] ?? 0.0;
  }

  // Initialize data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _loadAllData();
    } catch (e) {
      debugPrint('Error initializing habit data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all data from database
  Future<void> _loadAllData() async {
    // Load habits
    _habits = await _dbHelper.getAllHabits();
    
    // Load habit completions for the last 30 days
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    
    _habitCompletions.clear();
    for (final habit in _habits) {
      _habitCompletions[habit.id!] = {};
      final entries = await _dbHelper.getHabitEntries(habit.id!);
      
      for (final entry in entries) {
        if (entry.date.isAfter(startDate.subtract(const Duration(days: 1)))) {
          _habitCompletions[habit.id!]![entry.date] = entry.completed;
        }
      }
    }
    
    // Calculate streaks
    await _calculateStreaks();
    
    // Calculate best streaks
    await _calculateBestStreaks();
    
    // Calculate completion rates
    await _calculateCompletionRates();
    
    // Calculate daily completion percentages
    await _calculateDailyCompletionPercentages();
  }

  // Calculate streaks for all habits
  Future<void> _calculateStreaks() async {
    _streaks.clear();
    for (final habit in _habits) {
      _streaks[habit.id!] = await _dbHelper.getStreak(habit.id!);
    }
  }

  // Calculate best streaks for all habits
  Future<void> _calculateBestStreaks() async {
    _bestStreaks.clear();
    for (final habit in _habits) {
      _bestStreaks[habit.id!] = await _dbHelper.getBestStreak(habit.id!);
    }
  }

  // Calculate completion rates for all habits
  Future<void> _calculateCompletionRates() async {
    _completionRates.clear();
    for (final habit in _habits) {
      _completionRates[habit.id!] = await _dbHelper.getCompletionRate(habit.id!);
    }
  }

  // Calculate daily completion percentages
  Future<void> _calculateDailyCompletionPercentages() async {
    _dailyCompletionPercentages.clear();
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    
    for (DateTime date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      _dailyCompletionPercentages[normalizedDate] = await _dbHelper.getCompletionPercentage(normalizedDate);
    }
  }

  // Calculate daily completion percentage for a specific date
  Future<double> _calculateDailyCompletionPercentage(DateTime date) async {
    return await _dbHelper.getCompletionPercentage(date);
  }

  // Toggle habit completion
  Future<void> toggleHabitCompletion(int habitId, DateTime date) async {
    try {
      _habitLoadingStates[habitId] = true;
      notifyListeners();
      
      final isCompleted = isHabitCompleted(habitId, date);
      final newCompletion = !isCompleted;
      
      // Update local state immediately for responsiveness
      _habitCompletions[habitId] ??= {};
      _habitCompletions[habitId]![date] = newCompletion;
      
      // Update database
      final existingEntry = await _dbHelper.getHabitEntry(habitId, date);
      
      if (existingEntry != null) {
        final updatedEntry = existingEntry.copyWith(completed: newCompletion);
        await _dbHelper.updateHabitEntry(updatedEntry);
      } else {
        final newEntry = HabitEntry(
          habitId: habitId,
          date: date,
          completed: newCompletion,
        );
        await _dbHelper.insertHabitEntry(newEntry);
      }
      
      // Recalculate affected data
      await _recalculateAffectedData(habitId, date);
      
    } catch (e) {
      // Revert local state on error
      _habitCompletions[habitId]![date] = !(_habitCompletions[habitId]![date] ?? false);
      debugPrint('Error toggling habit completion: $e');
      rethrow;
    } finally {
      _habitLoadingStates[habitId] = false;
      notifyListeners();
    }
  }

  // Recalculate data affected by habit completion change
  Future<void> _recalculateAffectedData(int habitId, DateTime date) async {
    // Recalculate streak for this habit
    _streaks[habitId] = await _dbHelper.getStreak(habitId);
    
    // Recalculate best streak for this habit
    _bestStreaks[habitId] = await _dbHelper.getBestStreak(habitId);
    
    // Recalculate completion rate for this habit
    _completionRates[habitId] = await _dbHelper.getCompletionRate(habitId);
    
    // Recalculate daily completion percentage for this date
    final normalizedDate = DateTime(date.year, date.month, date.day);
    _dailyCompletionPercentages[normalizedDate] = await _calculateDailyCompletionPercentage(normalizedDate);
    
    // Also recalculate daily completion percentages for the last 7 days to ensure weekly trend is updated
    final today = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final trendDate = today.subtract(Duration(days: i));
      final normalizedTrendDate = DateTime(trendDate.year, trendDate.month, trendDate.day);
      _dailyCompletionPercentages[normalizedTrendDate] = await _calculateDailyCompletionPercentage(normalizedTrendDate);
    }
  }

  // Add new habit
  Future<void> addHabit(Habit habit) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final id = await _dbHelper.insertHabit(habit);
      final newHabit = habit.copyWith(id: id);
      
      _habits.add(newHabit);
      _habitCompletions[newHabit.id!] = {};
      _streaks[newHabit.id!] = 0;
      _bestStreaks[newHabit.id!] = 0;
      _completionRates[newHabit.id!] = 0.0;
      
    } catch (e) {
      debugPrint('Error adding habit: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update habit
  Future<void> updateHabit(Habit habit) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _dbHelper.updateHabit(habit);
      
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
      }
      
    } catch (e) {
      debugPrint('Error updating habit: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete habit
  Future<void> deleteHabit(int habitId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _dbHelper.deleteHabit(habitId);
      
      _habits.removeWhere((h) => h.id == habitId);
      _habitCompletions.remove(habitId);
      _streaks.remove(habitId);
      _bestStreaks.remove(habitId);
      _completionRates.remove(habitId);
      
    } catch (e) {
      debugPrint('Error deleting habit: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    await _loadAllData();
    notifyListeners();
  }

  // Reset all data
  Future<void> resetAllData() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _dbHelper.resetAllData();
      await _loadAllData();
      
    } catch (e) {
      debugPrint('Error resetting data: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
