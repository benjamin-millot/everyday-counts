import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/habit.dart';
import '../models/habit_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'everyday_counts.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        date INTEGER NOT NULL,
        completed INTEGER NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');
  }

  // Habit CRUD operations
  Future<int> insertHabit(Habit habit) async {
    try {
      final db = await database;
      return await db.insert('habits', habit.toMap());
    } catch (e) {
      throw Exception('Failed to insert habit: $e');
    }
  }

  Future<List<Habit>> getAllHabits() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('habits');
      return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get all habits: $e');
    }
  }

  Future<Habit?> getHabit(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'habits',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Habit.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get habit: $e');
    }
  }

  Future<int> updateHabit(Habit habit) async {
    try {
      final db = await database;
      return await db.update(
        'habits',
        habit.toMap(),
        where: 'id = ?',
        whereArgs: [habit.id],
      );
    } catch (e) {
      throw Exception('Failed to update habit: $e');
    }
  }

  Future<int> deleteHabit(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'habits',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete habit: $e');
    }
  }

  // HabitEntry CRUD operations
  Future<int> insertHabitEntry(HabitEntry entry) async {
    try {
      final db = await database;
      return await db.insert('habit_entries', entry.toMap());
    } catch (e) {
      throw Exception('Failed to insert habit entry: $e');
    }
  }

  Future<List<HabitEntry>> getHabitEntries(int habitId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'habit_entries',
        where: 'habit_id = ?',
        whereArgs: [habitId],
        orderBy: 'date DESC',
      );
      return List.generate(maps.length, (i) => HabitEntry.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get habit entries: $e');
    }
  }

  Future<HabitEntry?> getHabitEntry(int habitId, DateTime date) async {
    try {
      final db = await database;
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final List<Map<String, dynamic>> maps = await db.query(
        'habit_entries',
        where: 'habit_id = ? AND date >= ? AND date < ?',
        whereArgs: [habitId, startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      );
      
      if (maps.isNotEmpty) {
        return HabitEntry.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get habit entry: $e');
    }
  }

  Future<int> updateHabitEntry(HabitEntry entry) async {
    try {
      final db = await database;
      return await db.update(
        'habit_entries',
        entry.toMap(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
    } catch (e) {
      throw Exception('Failed to update habit entry: $e');
    }
  }

  Future<int> deleteHabitEntry(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'habit_entries',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete habit entry: $e');
    }
  }

  // Statistics methods
  Future<int> getCompletedHabitsCount(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM habit_entries
      WHERE date >= ? AND date < ? AND completed = 1
    ''', [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);
    
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get completion percentage for a specific date
  Future<double> getCompletionPercentage(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    // Get total number of habits
    final totalHabitsResult = await db.rawQuery('SELECT COUNT(*) as count FROM habits');
    final totalHabits = Sqflite.firstIntValue(totalHabitsResult) ?? 0;
    
    if (totalHabits == 0) return 0.0;
    
    // Get completed habits for this date
    final completedResult = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM habit_entries
      WHERE date >= ? AND date < ? AND completed = 1
    ''', [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);
    
    final completedHabits = Sqflite.firstIntValue(completedResult) ?? 0;
    
    return (completedHabits / totalHabits) * 100;
  }

  Future<int> getTotalHabitsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM habits');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getStreak(int habitId) async {
    final today = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final entry = await getHabitEntry(habitId, date);
      
      if (entry != null && entry.completed) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  Future<double> getCompletionRate(int habitId, {int days = 30}) async {
    final db = await database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    
    final totalEntries = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM habit_entries
      WHERE habit_id = ? AND date >= ? AND date <= ?
    ''', [habitId, startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);
    
    final completedEntries = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM habit_entries
      WHERE habit_id = ? AND date >= ? AND date <= ? AND completed = 1
    ''', [habitId, startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);
    
    final total = Sqflite.firstIntValue(totalEntries) ?? 0;
    final completed = Sqflite.firstIntValue(completedEntries) ?? 0;
    
    return total > 0 ? (completed / total) * 100 : 0.0;
  }

  // Get completion rate for a specific date range
  Future<double> getCompletionRateForDateRange(int habitId, DateTime startDate, DateTime endDate) async {
    final db = await database;
    
    final totalEntries = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM habit_entries
      WHERE habit_id = ? AND date >= ? AND date <= ?
    ''', [habitId, startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);
    
    final completedEntries = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM habit_entries
      WHERE habit_id = ? AND date >= ? AND date <= ? AND completed = 1
    ''', [habitId, startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);
    
    final total = Sqflite.firstIntValue(totalEntries) ?? 0;
    final completed = Sqflite.firstIntValue(completedEntries) ?? 0;
    
    return total > 0 ? (completed / total) * 100 : 0.0;
  }

  // Get weekly completion data for charts
  Future<List<Map<String, dynamic>>> getWeeklyCompletionData(int habitId, {int weeks = 12}) async {
    final db = await database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: weeks * 7));
    
    final result = await db.rawQuery('''
      SELECT 
        strftime('%Y-%W', datetime(date/1000, 'unixepoch')) as week,
        COUNT(*) as total_days,
        SUM(completed) as completed_days
      FROM habit_entries
      WHERE habit_id = ? AND date >= ? AND date <= ?
      GROUP BY strftime('%Y-%W', datetime(date/1000, 'unixepoch'))
      ORDER BY week
    ''', [habitId, startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);
    
    return result;
  }

  // Get best streak for a habit
  Future<int> getBestStreak(int habitId) async {
    final db = await database;
    final entries = await db.query(
      'habit_entries',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date ASC',
    );
    
    int bestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;
    
    for (final entry in entries) {
      final entryDate = DateTime.fromMillisecondsSinceEpoch(entry['date'] as int);
      final isCompleted = (entry['completed'] as int) == 1;
      
      if (isCompleted) {
        if (lastDate == null || entryDate.difference(lastDate).inDays == 1) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
        bestStreak = currentStreak > bestStreak ? currentStreak : bestStreak;
        lastDate = entryDate;
      } else {
        currentStreak = 0;
      }
    }
    
    return bestStreak;
  }

  // Get total completions for a habit
  Future<int> getTotalCompletions(int habitId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM habit_entries
      WHERE habit_id = ? AND completed = 1
    ''', [habitId]);
    
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Reset all data (delete all habits and entries)
  Future<void> resetAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('habit_entries');
      await txn.delete('habits');
    });
  }
}
