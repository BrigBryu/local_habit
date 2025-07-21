import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

import '../models/habit.dart';
import '../database/database_service.dart';
import 'time_service.dart';

/// Service for managing habits with per-habit streak logic
class HabitService extends StateNotifier<AsyncValue<List<Habit>>> {
  final Logger _logger = Logger();
  final DatabaseService _db = DatabaseService.instance;
  final TimeService _timeService = TimeService.instance;

  HabitService() : super(const AsyncValue.loading()) {
    _initialize();
  }

  /// Initialize the service and set up date change listening
  Future<void> _initialize() async {
    // Register for date change notifications
    _timeService.setDateChangeCallback(_handleDateChanged);
    
    // Load initial habits
    await _loadHabits();
  }

  /// Handle when the date changes (for testing with time advancement)
  Future<void> _handleDateChanged() async {
    if (!mounted) return; // Prevent access after disposal
    _logger.i('Day rollover: ${_timeService.formatCurrentDate()}');
    await _loadHabits(); // This will trigger _checkForLostStreaks
    
    // Force UI refresh by touching the database
    await _forceUIRefresh();
  }
  
  /// Force UI refresh after date changes
  Future<void> _forceUIRefresh() async {
    final habits = await _db.isar.habits.where().findAll();
    if (habits.isNotEmpty) {
      await _db.isar.writeTxn(() async {
        // Touch each habit to trigger UI refresh
        for (final habit in habits) {
          await _db.isar.habits.put(habit);
        }
      });
    }
  }

  /// Manually refresh habits and check for lost streaks (useful for testing)
  Future<void> refreshHabits() async {
    await _loadHabits();
  }

  /// Load all habits from database
  Future<void> _loadHabits() async {
    try {
      if (!mounted) return; // Prevent access after disposal
      state = const AsyncValue.loading();
      final habits = await _db.isar.habits.where().findAll();
      
      // Check for lost streaks (habits that should have been completed but weren't)
      await _checkForLostStreaks(habits);
      
      if (!mounted) return; // Check again after async operations
      state = AsyncValue.data(habits);
    } catch (error, stackTrace) {
      _logger.e('Failed to load habits', error: error, stackTrace: stackTrace);
      if (mounted) state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Check for habits that have lost their streaks due to missed days
  Future<void> _checkForLostStreaks(List<Habit> habits) async {
    bool hasChanges = false;
    final yesterday = _timeService.yesterday;
    final today = _timeService.today;
    
    for (final habit in habits) {
      if (habit.streak > 0 && habit.lastCompletedAt != null) {
        final lastCompleted = DateTime(
          habit.lastCompletedAt!.year,
          habit.lastCompletedAt!.month,
          habit.lastCompletedAt!.day,
        );
        
        _logger.d('${habit.name}: lastCompleted=${lastCompleted.day}/${lastCompleted.month}, yesterday=${yesterday.day}/${yesterday.month}, today=${today.day}/${today.month}');
        
        // If lastCompletedDate is NOT yesterday AND NOT today, reset streak to 0
        if (!lastCompleted.isAtSameMomentAs(yesterday) && !lastCompleted.isAtSameMomentAs(today)) {
          _logger.i('💔 ${habit.name}: streak lost (was ${habit.streak})');
          habit.streak = 0;
          hasChanges = true;
        }
      }
    }
    
    // Save changes if any streaks were reset
    if (hasChanges) {
      await _db.isar.writeTxn(() async {
        for (final habit in habits) {
          await _db.isar.habits.put(habit);
        }
      });
    }
  }

  /// Get current list of habits
  Future<List<Habit>> loadHabits() async {
    final habits = await _db.isar.habits.where().findAll();
    return habits;
  }

  /// Add a new habit
  Future<void> addHabit(
    String name, 
    HabitType type, {
    Map<String, dynamic>? config,
  }) async {
    try {
      final habit = Habit.create(
        name: name,
        type: type,
        configData: config,
      );

      await _db.isar.writeTxn(() async {
        await _db.isar.habits.put(habit);
      });

      _logger.i('Added habit: ${habit.name} (${habit.type.displayName})');
      await _loadHabits();
    } catch (error, stackTrace) {
      _logger.e('Failed to add habit', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Toggle completion status of a habit
  Future<void> toggleComplete(Habit habit) async {
    try {
      final now = _timeService.now;
      
      if (habit.isCompletedToday) {
        // For basic habits, don't allow unchecking - they can only be completed once per day
        if (habit.type == HabitType.basic) {
          _logger.d('Basic habit ${habit.name} already completed today - no action taken');
          return;
        }
        
        // For non-basic habits, allow unchecking
        habit.lastCompletedAt = null;
        _logger.d('Unchecked ${habit.name}, streak: ${habit.streak}');
      } else {
        // Completing habit - increment streak and set lastCompletedDate = today
        if (!habit.isCompletedToday) {
          habit.streak = habit.streak + 1;
          habit.lastCompletedAt = now;
          _logger.d('Completed ${habit.name}, streak: ${habit.streak}');
        }
      }

      await _db.isar.writeTxn(() async {
        await _db.isar.habits.put(habit);
      });

      await _loadHabits();
    } catch (error, stackTrace) {
      _logger.e('Failed to toggle habit completion', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Reset daily flags (call at app start or midnight)
  Future<void> resetDailyFlags() async {
    try {
      // For now, this is a no-op since we're using simple date comparison
      // In the future, this could reset any daily counters if needed
      _logger.d('Daily flags reset completed');
    } catch (error, stackTrace) {
      _logger.e('Failed to reset daily flags', error: error, stackTrace: stackTrace);
    }
  }

  /// Delete a habit
  Future<void> deleteHabit(Habit habit) async {
    try {
      await _db.isar.writeTxn(() async {
        await _db.isar.habits.delete(habit.id);
      });

      _logger.i('Deleted habit: ${habit.name}');
      await _loadHabits();
    } catch (error, stackTrace) {
      _logger.e('Failed to delete habit', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update habit configuration
  Future<void> updateHabit(Habit habit) async {
    try {
      await _db.isar.writeTxn(() async {
        await _db.isar.habits.put(habit);
      });

      _logger.i('Updated habit: ${habit.name}');
      await _loadHabits();
    } catch (error, stackTrace) {
      _logger.e('Failed to update habit', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get habit by ID
  Future<Habit?> getHabitById(int id) async {
    return await _db.isar.habits.get(id);
  }

  /// Stream of all habits
  Stream<List<Habit>> watchHabits() {
    return _db.isar.habits.where().watch(fireImmediately: true);
  }

  /// Check if a habit is due based on its type
  bool isHabitDue(Habit habit) {
    final now = _timeService.now;
    
    switch (habit.type) {
      case HabitType.basic:
      case HabitType.avoidance:
        // Due every day
        return !habit.isCompletedToday;
        
      case HabitType.weekly:
        if (habit.weekdayMask == null) return !habit.isCompletedToday;
        
        // Check if today's weekday bit is set (0=Sunday, 1=Monday, etc.)
        final weekday = now.weekday % 7; // Convert to 0-6 where 0=Sunday
        final isDayEnabled = (habit.weekdayMask! & (1 << weekday)) != 0;
        return isDayEnabled && !habit.isCompletedToday;
        
      case HabitType.interval:
        if (habit.intervalDays == null || habit.lastCompletedAt == null) {
          return !habit.isCompletedToday;
        }
        
        final daysSinceLastCompletion = now.difference(habit.lastCompletedAt!).inDays;
        return daysSinceLastCompletion >= habit.intervalDays!;
        
      case HabitType.bundle:
      case HabitType.stack:
        // Simplified - just check if completed today
        return !habit.isCompletedToday;
    }
  }
}

/// Provider for HabitService
final habitServiceProvider = StateNotifierProvider<HabitService, AsyncValue<List<Habit>>>(
  (ref) => HabitService(),
);

/// Provider for habit list stream
final habitListProvider = StreamProvider<List<Habit>>((ref) {
  final db = DatabaseService.instance;
  return db.isar.habits.where().watch(fireImmediately: true);
});

