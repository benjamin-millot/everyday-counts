class HabitEntry {
  final int? id;
  final int habitId;
  final DateTime date;
  final bool completed;

  HabitEntry({
    this.id,
    required this.habitId,
    required this.date,
    required this.completed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date.millisecondsSinceEpoch,
      'completed': completed ? 1 : 0,
    };
  }

  factory HabitEntry.fromMap(Map<String, dynamic> map) {
    return HabitEntry(
      id: map['id'],
      habitId: map['habit_id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      completed: map['completed'] == 1,
    );
  }

  HabitEntry copyWith({
    int? id,
    int? habitId,
    DateTime? date,
    bool? completed,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
    );
  }
}

