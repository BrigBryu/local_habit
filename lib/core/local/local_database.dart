import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:domain/domain.dart';

class LocalDatabase {
  static LocalDatabase? _instance;
  static Database? _database;

  LocalDatabase._internal();

  factory LocalDatabase() {
    _instance ??= LocalDatabase._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = '${documentsDirectory.path}/habits.db';
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create habits table
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        type TEXT NOT NULL,
        stacked_on_habit_id TEXT,
        bundle_child_ids TEXT,
        parent_bundle_id TEXT,
        parent_stack_id TEXT,
        stack_child_ids TEXT,
        current_child_index INTEGER DEFAULT 0,
        timeout_minutes INTEGER,
        available_days TEXT,
        created_at TEXT NOT NULL,
        last_completed TEXT,
        last_alarm_triggered TEXT,
        session_start_time TEXT,
        last_session_started TEXT,
        session_completed_today INTEGER DEFAULT 0,
        daily_completion_count INTEGER DEFAULT 0,
        last_completion_count_reset TEXT,
        daily_failure_count INTEGER DEFAULT 0,
        last_failure_count_reset TEXT,
        avoidance_success_today INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        interval_days INTEGER,
        weekday_mask INTEGER,
        last_completion_date TEXT,
        display_order INTEGER DEFAULT 999999
      )
    ''');

    // Create completions table
    await db.execute('''
      CREATE TABLE completions (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        completed_at TEXT NOT NULL,
        completion_count INTEGER DEFAULT 1,
        notes TEXT,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_habits_user_id ON habits (user_id)');
    await db.execute('CREATE INDEX idx_habits_type ON habits (type)');
    await db.execute('CREATE INDEX idx_completions_habit_id ON completions (habit_id)');
    await db.execute('CREATE INDEX idx_completions_completed_at ON completions (completed_at)');
  }

  // Habit CRUD operations
  Future<void> insertHabit(Habit habit) async {
    final db = await database;
    await db.insert('habits', _habitToMap(habit));
  }

  Future<void> updateHabit(Habit habit) async {
    final db = await database;
    await db.update(
      'habits',
      _habitToMap(habit),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<void> deleteHabit(String habitId) async {
    final db = await database;
    await db.delete('habits', where: 'id = ?', whereArgs: [habitId]);
  }

  Future<List<Habit>> getAllHabits({String userId = 'local_user'}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'display_order ASC, created_at ASC',
    );

    return maps.map((map) => _habitFromMap(map)).toList();
  }

  Future<Habit?> getHabitById(String habitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [habitId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _habitFromMap(maps.first);
  }

  // Completion operations
  Future<void> insertCompletion({
    required String habitId,
    required DateTime completedAt,
    int completionCount = 1,
    String? notes,
    String userId = 'local_user',
  }) async {
    final db = await database;
    final id = '${habitId}_${completedAt.millisecondsSinceEpoch}';
    
    await db.insert('completions', {
      'id': id,
      'habit_id': habitId,
      'user_id': userId,
      'completed_at': completedAt.toIso8601String(),
      'completion_count': completionCount,
      'notes': notes,
    });
  }

  Future<List<Map<String, dynamic>>> getCompletionsForHabit(
    String habitId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    String whereClause = 'habit_id = ?';
    List<dynamic> whereArgs = [habitId];

    if (startDate != null) {
      whereClause += ' AND completed_at >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClause += ' AND completed_at <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    return await db.query(
      'completions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'completed_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllCompletions({
    DateTime? startDate,
    DateTime? endDate,
    String userId = 'local_user',
  }) async {
    final db = await database;
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (startDate != null) {
      whereClause += ' AND completed_at >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClause += ' AND completed_at <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    return await db.query(
      'completions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'completed_at DESC',
    );
  }

  // Helper methods to convert between Habit and Map
  Map<String, dynamic> _habitToMap(Habit habit) {
    return {
      'id': habit.id,
      'name': habit.name,
      'description': habit.description,
      'user_id': 'local_user',
      'type': habit.type.name,
      'stacked_on_habit_id': habit.stackedOnHabitId,
      'bundle_child_ids': habit.bundleChildIds?.join(','),
      'parent_bundle_id': habit.parentBundleId,
      'parent_stack_id': habit.parentStackId,
      'stack_child_ids': habit.stackChildIds?.join(','),
      'current_child_index': habit.currentChildIndex,
      'timeout_minutes': habit.timeoutMinutes,
      'available_days': habit.availableDays?.join(','),
      'created_at': habit.createdAt.toIso8601String(),
      'last_completed': habit.lastCompleted?.toIso8601String(),
      'last_alarm_triggered': habit.lastAlarmTriggered?.toIso8601String(),
      'session_start_time': habit.sessionStartTime?.toIso8601String(),
      'last_session_started': habit.lastSessionStarted?.toIso8601String(),
      'session_completed_today': habit.sessionCompletedToday ? 1 : 0,
      'daily_completion_count': habit.dailyCompletionCount,
      'last_completion_count_reset': habit.lastCompletionCountReset?.toIso8601String(),
      'daily_failure_count': habit.dailyFailureCount,
      'last_failure_count_reset': habit.lastFailureCountReset?.toIso8601String(),
      'avoidance_success_today': habit.avoidanceSuccessToday ? 1 : 0,
      'current_streak': habit.currentStreak,
      'interval_days': habit.intervalDays,
      'weekday_mask': habit.weekdayMask,
      'last_completion_date': habit.lastCompletionDate?.toIso8601String(),
      'display_order': habit.displayOrder,
    };
  }

  Habit _habitFromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      type: HabitType.values.firstWhere((e) => e.name == map['type']),
      stackedOnHabitId: map['stacked_on_habit_id'] as String?,
      bundleChildIds: map['bundle_child_ids'] != null
          ? (map['bundle_child_ids'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : null,
      parentBundleId: map['parent_bundle_id'] as String?,
      parentStackId: map['parent_stack_id'] as String?,
      stackChildIds: map['stack_child_ids'] != null
          ? (map['stack_child_ids'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : null,
      currentChildIndex: map['current_child_index'] as int? ?? 0,
      timeoutMinutes: map['timeout_minutes'] as int?,
      availableDays: map['available_days'] != null
          ? (map['available_days'] as String).split(',').map((s) => int.parse(s)).toList()
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastCompleted: map['last_completed'] != null
          ? DateTime.parse(map['last_completed'] as String)
          : null,
      lastAlarmTriggered: map['last_alarm_triggered'] != null
          ? DateTime.parse(map['last_alarm_triggered'] as String)
          : null,
      sessionStartTime: map['session_start_time'] != null
          ? DateTime.parse(map['session_start_time'] as String)
          : null,
      lastSessionStarted: map['last_session_started'] != null
          ? DateTime.parse(map['last_session_started'] as String)
          : null,
      sessionCompletedToday: (map['session_completed_today'] as int? ?? 0) == 1,
      dailyCompletionCount: map['daily_completion_count'] as int? ?? 0,
      lastCompletionCountReset: map['last_completion_count_reset'] != null
          ? DateTime.parse(map['last_completion_count_reset'] as String)
          : null,
      dailyFailureCount: map['daily_failure_count'] as int? ?? 0,
      lastFailureCountReset: map['last_failure_count_reset'] != null
          ? DateTime.parse(map['last_failure_count_reset'] as String)
          : null,
      avoidanceSuccessToday: (map['avoidance_success_today'] as int? ?? 0) == 1,
      currentStreak: map['current_streak'] as int? ?? 0,
      intervalDays: map['interval_days'] as int?,
      weekdayMask: map['weekday_mask'] as int?,
      lastCompletionDate: map['last_completion_date'] != null
          ? DateTime.parse(map['last_completion_date'] as String)
          : null,
      displayOrder: map['display_order'] as int? ?? 999999,
    );
  }

  // Database management
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = '${documentsDirectory.path}/habits.db';
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    _database = null;
  }
}