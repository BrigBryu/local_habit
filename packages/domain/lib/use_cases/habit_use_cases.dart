import '../entities/base_habit.dart';
import '../entities/basic_habit.dart';
import '../entities/habit_stack.dart';
import '../entities/alarm_habit.dart';
import '../entities/timed_session_habit.dart';
import '../entities/time_window_habit.dart';
import '../entities/habit_factory.dart';
import '../entities/time_of_day.dart' as domain;
import '../services/time_service.dart';

/// Habit use cases for the new inheritance-based habit system
class HabitUseCases {
  static final HabitUseCases _instance = HabitUseCases._internal();
  factory HabitUseCases() => _instance;
  HabitUseCases._internal();

  final List<BaseHabit> _habits = [];
  final TimeService _timeService = TimeService();

  /// Get all habits
  List<BaseHabit> getAllHabits() {
    return List.unmodifiable(_habits);
  }

  /// Add a new basic habit
  Future<String> addBasicHabit({
    required String name,
    required String description,
  }) async {
    _validateCommonFields(name, description);
    
    final habit = HabitFactory.createBasic(
      name: name.trim(),
      description: description.trim(),
    );
    
    _habits.add(habit);
    return habit.id;
  }

  /// Add a new habit stack
  Future<String> addHabitStack({
    required String name,
    required String description,
    required String stackedOnHabitId,
  }) async {
    _validateCommonFields(name, description);
    
    // Validate base habit exists
    final baseHabit = getHabitById(stackedOnHabitId);
    if (baseHabit == null) {
      throw ArgumentError('Base habit not found');
    }
    
    final habit = HabitFactory.createStack(
      name: name.trim(),
      description: description.trim(),
      stackedOnHabitId: stackedOnHabitId,
    );
    
    _habits.add(habit);
    return habit.id;
  }

  /// Add a new alarm habit
  Future<String> addAlarmHabit({
    required String name,
    required String description,
    required String stackedOnHabitId,
    required domain.TimeOfDay alarmTime,
    required int windowMinutes,
  }) async {
    _validateCommonFields(name, description);
    
    if (windowMinutes <= 0) {
      throw ArgumentError('Window minutes must be positive');
    }
    
    // Validate base habit exists
    final baseHabit = getHabitById(stackedOnHabitId);
    if (baseHabit == null) {
      throw ArgumentError('Base habit not found');
    }
    
    final habit = HabitFactory.createAlarm(
      name: name.trim(),
      description: description.trim(),
      stackedOnHabitId: stackedOnHabitId,
      alarmTime: alarmTime,
      windowMinutes: windowMinutes,
    );
    
    _habits.add(habit);
    return habit.id;
  }

  /// Add a new timed session habit
  Future<String> addTimedSessionHabit({
    required String name,
    required String description,
    required int sessionMinutes,
    int graceMinutes = 15,
  }) async {
    _validateCommonFields(name, description);
    
    if (sessionMinutes <= 0) {
      throw ArgumentError('Session minutes must be positive');
    }
    
    if (graceMinutes < 0) {
      throw ArgumentError('Grace minutes cannot be negative');
    }
    
    final habit = HabitFactory.createTimedSession(
      name: name.trim(),
      description: description.trim(),
      sessionMinutes: sessionMinutes,
      graceMinutes: graceMinutes,
    );
    
    _habits.add(habit);
    return habit.id;
  }

  /// Add a new time window habit
  Future<String> addTimeWindowHabit({
    required String name,
    required String description,
    required domain.TimeOfDay windowStartTime,
    required domain.TimeOfDay windowEndTime,
    required List<int> availableDays,
  }) async {
    _validateCommonFields(name, description);
    
    if (availableDays.isEmpty) {
      throw ArgumentError('Must have at least one available day');
    }
    
    if (availableDays.any((day) => day < 1 || day > 7)) {
      throw ArgumentError('Available days must be between 1 (Monday) and 7 (Sunday)');
    }
    
    final habit = HabitFactory.createTimeWindow(
      name: name.trim(),
      description: description.trim(),
      windowStartTime: windowStartTime,
      windowEndTime: windowEndTime,
      availableDays: List.from(availableDays),
    );
    
    _habits.add(habit);
    return habit.id;
  }

  /// Common field validation
  void _validateCommonFields(String name, String description) {
    final trimmedName = name.trim();
    final trimmedDescription = description.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Habit name cannot be empty');
    }

    if (trimmedName.length < 2) {
      throw ArgumentError('Habit name must be at least 2 characters');
    }

    if (trimmedName.length > 50) {
      throw ArgumentError('Habit name cannot exceed 50 characters');
    }

    if (trimmedDescription.length > 200) {
      throw ArgumentError('Description cannot exceed 200 characters');
    }

    // Check for duplicates
    final duplicateExists = _habits.any(
      (habit) => habit.name.toLowerCase() == trimmedName.toLowerCase(),
    );

    if (duplicateExists) {
      throw ArgumentError('A habit with this name already exists');
    }
  }

  /// Get a habit by ID
  BaseHabit? getHabitById(String habitId) {
    try {
      return _habits.firstWhere((h) => h.id == habitId);
    } catch (e) {
      return null;
    }
  }

  /// Complete a habit
  Future<void> completeHabit(String habitId) async {
    final index = _habits.indexWhere((habit) => habit.id == habitId);
    if (index == -1) {
      throw ArgumentError('Habit not found');
    }

    final habit = _habits[index];
    
    // Check if habit can be completed
    if (!habit.canComplete(_timeService)) {
      throw StateError('Habit cannot be completed at this time');
    }
    
    _habits[index] = habit.complete();
  }

  /// Start a timed session (for TimedSessionHabit only)
  Future<void> startTimedSession(String habitId) async {
    final habit = getHabitById(habitId);
    if (habit == null) {
      throw ArgumentError('Habit not found');
    }
    
    if (habit is! TimedSessionHabit) {
      throw ArgumentError('Not a timed session habit');
    }
    
    final index = _habits.indexWhere((h) => h.id == habitId);
    _habits[index] = habit.startSession(_timeService);
  }

  /// Check if habit is completed today
  bool isCompletedToday(String habitId) {
    final habit = getHabitById(habitId);
    if (habit == null) return false;
    return habit.isCompletedToday(_timeService);
  }

  /// Get visible habits (handles habit stack visibility)
  List<BaseHabit> getVisibleHabits() {
    final visibleHabits = <BaseHabit>[];
    
    for (final habit in _habits) {
      if (habit is HabitStack) {
        // Only show stacks if their base habit is completed today
        if (isCompletedToday(habit.stackedOnHabitId)) {
          visibleHabits.add(habit);
        }
      } else if (habit is AlarmHabit) {
        // Only show alarm habits if their base habit is completed today
        if (isCompletedToday(habit.stackedOnHabitId)) {
          visibleHabits.add(habit);
        }
      } else {
        // Always show basic habits, timed sessions, and time windows
        visibleHabits.add(habit);
      }
    }
    
    return visibleHabits;
  }

  /// Get display name for habit (handles combined names for completed stacks)
  String getHabitDisplayName(String habitId) {
    final habit = getHabitById(habitId);
    if (habit == null) return 'Unknown';
    
    if (habit is HabitStack) {
      // If both base and stack are completed, show combined name
      if (isCompletedToday(habitId) && isCompletedToday(habit.stackedOnHabitId)) {
        final baseHabit = getHabitById(habit.stackedOnHabitId);
        final baseHabitName = baseHabit?.name ?? 'Unknown';
        final chainDepth = getHabitChainDepth(habitId);
        return habit.getCombinedDisplayName(baseHabitName, chainDepth);
      }
    }
    
    return habit.displayName;
  }

  /// Get habit chain depth
  int getHabitChainDepth(String habitId) {
    final habit = getHabitById(habitId);
    if (habit == null) return 1;
    
    if (habit is HabitStack) {
      return 1 + getHabitChainDepth(habit.stackedOnHabitId);
    } else if (habit is AlarmHabit) {
      return 1 + getHabitChainDepth(habit.stackedOnHabitId);
    }
    
    return 1;
  }

  /// Get base habits (for creating stacks)
  List<BaseHabit> getBaseHabits() {
    return _habits.where((habit) => 
      habit is BasicHabit || 
      habit is TimedSessionHabit || 
      habit is TimeWindowHabit
    ).toList();
  }

  /// Reset all habits (for testing)
  void resetAllHabits() {
    _habits.clear();
    print('🗑️ All habits cleared');
  }

  /// Get current date info
  String getCurrentDateInfo() {
    final now = _timeService.now();
    return 'Current date: ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get habit stats for debugging
  Map<String, dynamic> getHabitStats(String habitId) {
    final habit = getHabitById(habitId);
    if (habit == null) return {};

    final daysSinceCreated = _timeService.daysBetween(habit.createdAt, _timeService.now());
    
    final daysSinceLastCompleted = habit.lastCompleted != null
        ? _timeService.daysBetween(habit.lastCompleted!, _timeService.now())
        : null;

    return {
      'name': habit.name,
      'type': habit.typeName,
      'storedStreak': habit.currentStreak,
      'currentStreak': habit.calculateCurrentStreak(_timeService),
      'lastCompleted': habit.lastCompleted?.toString(),
      'daysSinceCreated': daysSinceCreated,
      'daysSinceLastCompleted': daysSinceLastCompleted,
      'completedToday': habit.isCompletedToday(_timeService),
      'canComplete': habit.canComplete(_timeService),
      'statusText': habit.getStatusText(_timeService),
    };
  }
}