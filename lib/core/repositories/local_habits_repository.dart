import 'dart:async';
import 'package:domain/domain.dart';
import 'package:rxdart/rxdart.dart';
import '../local/local_database.dart';
import 'habits_repository.dart';

class LocalHabitsRepository implements HabitsRepository {
  final LocalDatabase _database;
  final BehaviorSubject<List<Habit>> _ownHabitsSubject = BehaviorSubject<List<Habit>>.seeded([]);
  String _currentUserId = 'local_user';

  LocalHabitsRepository({LocalDatabase? database}) 
      : _database = database ?? LocalDatabase();

  @override
  Stream<List<Habit>> ownHabits() {
    return _ownHabitsSubject.stream;
  }

  @override
  Future<String?> addHabit(Habit habit) async {
    try {
      await _database.insertHabit(habit);
      await _refreshOwnHabits();
      return null; // Success
    } catch (e) {
      return 'Failed to add habit: $e';
    }
  }

  @override
  Future<String?> updateHabit(Habit habit) async {
    try {
      await _database.updateHabit(habit);
      await _refreshOwnHabits();
      return null; // Success
    } catch (e) {
      return 'Failed to update habit: $e';
    }
  }

  @override
  Future<String?> removeHabit(String habitId) async {
    try {
      await _database.deleteHabit(habitId);
      await _refreshOwnHabits();
      return null; // Success
    } catch (e) {
      return 'Failed to remove habit: $e';
    }
  }

  @override
  Future<String?> completeHabit(String habitId, {int xpAwarded = 0}) async {
    try {
      final habit = await _database.getHabitById(habitId);
      if (habit == null) {
        return 'Habit not found';
      }

      // Complete the habit (this updates streak, completion count, etc.)
      final completedHabit = habit.complete();
      
      // Update the habit in the database
      await _database.updateHabit(completedHabit);
      
      // Record the completion
      await _database.insertCompletion(
        habitId: habitId,
        completedAt: DateTime.now(),
        userId: _currentUserId,
      );
      
      await _refreshOwnHabits();
      return null; // Success
    } catch (e) {
      return 'Failed to complete habit: $e';
    }
  }

  @override
  Future<String?> completeStackChild(String stackId) async {
    try {
      final stackHabit = await _database.getHabitById(stackId);
      if (stackHabit == null) {
        return 'Stack habit not found';
      }

      if (stackHabit.type != HabitType.stack) {
        return 'Habit is not a stack type';
      }

      final stackChildIds = stackHabit.stackChildIds ?? [];
      if (stackChildIds.isEmpty) {
        return 'Stack has no children';
      }

      // Get current child index
      final currentIndex = stackHabit.currentChildIndex;
      if (currentIndex >= stackChildIds.length) {
        return 'Invalid stack child index';
      }

      final currentChildId = stackChildIds[currentIndex];
      
      // Complete the current child habit
      final childResult = await completeHabit(currentChildId);
      if (childResult != null) {
        return childResult;
      }

      // If this was the last child, complete the stack and reset to first child
      if (currentIndex == stackChildIds.length - 1) {
        final completedStack = stackHabit.complete();
        final resetStack = Habit(
          id: completedStack.id,
          name: completedStack.name,
          description: completedStack.description,
          type: completedStack.type,
          stackedOnHabitId: completedStack.stackedOnHabitId,
          bundleChildIds: completedStack.bundleChildIds,
          parentBundleId: completedStack.parentBundleId,
          parentStackId: completedStack.parentStackId,
          stackChildIds: completedStack.stackChildIds,
          currentChildIndex: 0, // Reset to first child
          timeoutMinutes: completedStack.timeoutMinutes,
          availableDays: completedStack.availableDays,
          createdAt: completedStack.createdAt,
          lastCompleted: completedStack.lastCompleted,
          lastAlarmTriggered: completedStack.lastAlarmTriggered,
          sessionStartTime: completedStack.sessionStartTime,
          lastSessionStarted: completedStack.lastSessionStarted,
          sessionCompletedToday: completedStack.sessionCompletedToday,
          dailyCompletionCount: completedStack.dailyCompletionCount,
          lastCompletionCountReset: completedStack.lastCompletionCountReset,
          dailyFailureCount: completedStack.dailyFailureCount,
          lastFailureCountReset: completedStack.lastFailureCountReset,
          avoidanceSuccessToday: completedStack.avoidanceSuccessToday,
          currentStreak: completedStack.currentStreak,
          intervalDays: completedStack.intervalDays,
          weekdayMask: completedStack.weekdayMask,
          lastCompletionDate: completedStack.lastCompletionDate,
          displayOrder: completedStack.displayOrder,
        );
        await _database.updateHabit(resetStack);
      } else {
        // Move to next child
        final nextChildStack = Habit(
          id: stackHabit.id,
          name: stackHabit.name,
          description: stackHabit.description,
          type: stackHabit.type,
          stackedOnHabitId: stackHabit.stackedOnHabitId,
          bundleChildIds: stackHabit.bundleChildIds,
          parentBundleId: stackHabit.parentBundleId,
          parentStackId: stackHabit.parentStackId,
          stackChildIds: stackHabit.stackChildIds,
          currentChildIndex: currentIndex + 1,
          timeoutMinutes: stackHabit.timeoutMinutes,
          availableDays: stackHabit.availableDays,
          createdAt: stackHabit.createdAt,
          lastCompleted: stackHabit.lastCompleted,
          lastAlarmTriggered: stackHabit.lastAlarmTriggered,
          sessionStartTime: stackHabit.sessionStartTime,
          lastSessionStarted: stackHabit.lastSessionStarted,
          sessionCompletedToday: stackHabit.sessionCompletedToday,
          dailyCompletionCount: stackHabit.dailyCompletionCount,
          lastCompletionCountReset: stackHabit.lastCompletionCountReset,
          dailyFailureCount: stackHabit.dailyFailureCount,
          lastFailureCountReset: stackHabit.lastFailureCountReset,
          avoidanceSuccessToday: stackHabit.avoidanceSuccessToday,
          currentStreak: stackHabit.currentStreak,
          intervalDays: stackHabit.intervalDays,
          weekdayMask: stackHabit.weekdayMask,
          lastCompletionDate: stackHabit.lastCompletionDate,
          displayOrder: stackHabit.displayOrder,
        );
        await _database.updateHabit(nextChildStack);
      }

      await _refreshOwnHabits();
      return null; // Success
    } catch (e) {
      return 'Failed to complete stack child: $e';
    }
  }

  @override
  Future<String?> recordFailure(String habitId) async {
    try {
      final habit = await _database.getHabitById(habitId);
      if (habit == null) {
        return 'Habit not found';
      }

      if (habit.type != HabitType.avoidance) {
        return 'Habit is not an avoidance type';
      }

      // Record the failure (this updates failure count and breaks streak)
      final failedHabit = habit.recordFailure();
      
      // Update the habit in the database
      await _database.updateHabit(failedHabit);
      
      await _refreshOwnHabits();
      return null; // Success
    } catch (e) {
      return 'Failed to record failure: $e';
    }
  }

  @override
  String getCurrentUserId() {
    return _currentUserId;
  }

  @override
  Future<void> setCurrentUserId(String userId) async {
    _currentUserId = userId;
    await _refreshOwnHabits();
  }

  @override
  Future<void> initialize() async {
    // Initialize the database and load initial data
    await _refreshOwnHabits();
  }

  @override
  Future<void> dispose() async {
    await _ownHabitsSubject.close();
  }

  // Private helper methods
  Future<void> _refreshOwnHabits() async {
    try {
      final habits = await _database.getAllHabits(userId: _currentUserId);
      _ownHabitsSubject.add(habits);
    } catch (e) {
      // Log error but don't break the stream
      print('Error refreshing habits: $e');
    }
  }

  // Additional utility methods for offline functionality
  
  /// Get completions for a specific habit within a date range
  Future<List<Map<String, dynamic>>> getCompletionsForHabit(
    String habitId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _database.getCompletionsForHabit(
      habitId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get all completions within a date range
  Future<List<Map<String, dynamic>>> getAllCompletions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _database.getAllCompletions(
      startDate: startDate,
      endDate: endDate,
      userId: _currentUserId,
    );
  }

  /// Export all data (habits and completions) as JSON for backup
  Future<Map<String, dynamic>> exportData() async {
    final habits = await _database.getAllHabits(userId: _currentUserId);
    final completions = await _database.getAllCompletions(userId: _currentUserId);
    
    return {
      'habits': habits.map((h) => h.toJson()).toList(),
      'completions': completions,
      'exportedAt': DateTime.now().toIso8601String(),
      'userId': _currentUserId,
    };
  }

  /// Import data from JSON backup
  Future<String?> importData(Map<String, dynamic> data) async {
    try {
      final habitsData = data['habits'] as List<dynamic>?;
      final completionsData = data['completions'] as List<dynamic>?;
      
      if (habitsData != null) {
        for (final habitData in habitsData) {
          final habit = Habit.fromJson(habitData as Map<String, dynamic>);
          await _database.insertHabit(habit);
        }
      }
      
      if (completionsData != null) {
        for (final completionData in completionsData) {
          final completion = completionData as Map<String, dynamic>;
          await _database.insertCompletion(
            habitId: completion['habit_id'] as String,
            completedAt: DateTime.parse(completion['completed_at'] as String),
            completionCount: completion['completion_count'] as int? ?? 1,
            notes: completion['notes'] as String?,
            userId: completion['user_id'] as String? ?? _currentUserId,
          );
        }
      }
      
      await _refreshOwnHabits();
      return null; // Success
    } catch (e) {
      return 'Failed to import data: $e';
    }
  }

  /// Clear all data (for testing or reset purposes)
  Future<String?> clearAllData() async {
    try {
      await _database.deleteDatabase();
      await _refreshOwnHabits();
      return null; // Success
    } catch (e) {
      return 'Failed to clear data: $e';
    }
  }
}