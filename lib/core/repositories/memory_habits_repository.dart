import 'dart:async';
import 'package:domain/domain.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'habits_repository.dart';

/// In-memory repository for web development - bypasses Isar database issues
class MemoryHabitsRepository implements HabitsRepository {
  final Logger _logger = Logger();

  String _currentUserId = 'dev_user';

  // In-memory storage
  final List<Habit> _habits = [];
  final List<CompletionRecord> _completions = [];

  // Stream controllers for reactive updates
  final _ownHabitsController = StreamController<List<Habit>>.broadcast();
  final _partnerHabitsController = StreamController<List<Habit>>.broadcast();

  @override
  String getCurrentUserId() => _currentUserId;

  @override
  Future<void> setCurrentUserId(String userId) async {
    _currentUserId = userId;

    // Try to save user ID, but don't block if it fails
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', userId);
    } catch (e) {
      _logger.w('Failed to save user ID: $e');
    }

    // Refresh streams with new user context
    await _refreshOwnHabits();
    await _refreshPartnerHabits();
  }

  @override
  Future<void> initialize() async {
    try {
      // Try to load saved user ID, but don't block if it fails
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedUserId = prefs.getString('current_user_id');
        if (savedUserId != null) {
          _currentUserId = savedUserId;
        }
      } catch (e) {
        _logger.w('Failed to load saved user ID, using default: $e');
        // Continue with default user ID
      }

      // Create some test habits for development
      await _createTestHabits();

      // Start streaming data
      await _refreshOwnHabits();
      await _refreshPartnerHabits();

      _logger.i('MemoryHabitsRepository initialized for user: $_currentUserId');
    } catch (e) {
      _logger.e('Failed to initialize MemoryHabitsRepository: $e');
      rethrow;
    }
  }

  @override
  Stream<List<Habit>> ownHabits() {
    return _ownHabitsController.stream;
  }

  @override
  Stream<List<Habit>> partnerHabits(String partnerId) {
    return _partnerHabitsController.stream;
  }

  @override
  Future<String?> addHabit(Habit habit) async {
    try {
      _habits.add(habit);
      await _refreshOwnHabits();
      _logger.d('Added habit: ${habit.name}');
      return null; // Success
    } catch (e) {
      _logger.e('Failed to add habit', error: e);
      return 'Failed to add habit: $e';
    }
  }

  @override
  Future<String?> updateHabit(Habit habit) async {
    try {
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
        await _refreshOwnHabits();
        _logger.d('Updated habit: ${habit.name}');
        return null; // Success
      }
      return 'Habit not found';
    } catch (e) {
      _logger.e('Failed to update habit', error: e);
      return 'Failed to update habit: $e';
    }
  }

  @override
  Future<String?> removeHabit(String habitId) async {
    try {
      _habits.removeWhere((h) => h.id == habitId);
      _completions.removeWhere((c) => c.habitId == habitId);

      await _refreshOwnHabits();
      _logger.d('Removed habit: $habitId');
      return null; // Success
    } catch (e) {
      _logger.e('Failed to remove habit', error: e);
      return 'Failed to remove habit: $e';
    }
  }

  @override
  Future<String?> completeHabit(String habitId, {int xpAwarded = 0}) async {
    try {
      final completion = CompletionRecord(
        habitId: habitId,
        userId: _currentUserId,
        completedAt: DateTime.now(),
        xpAwarded: xpAwarded,
      );

      _completions.add(completion);

      _logger.d('Completed habit: $habitId (XP: $xpAwarded)');
      return null; // Success
    } catch (e) {
      _logger.e('Failed to complete habit', error: e);
      return 'Failed to complete habit: $e';
    }
  }

  @override
  Future<String?> completeStackChild(String stackId) async {
    try {
      // For memory repository, this is a simplified implementation
      // In a real app, this would integrate with the stack progress service
      _logger.d('Stack child completed for stack: $stackId');
      return null; // Success
    } catch (e) {
      _logger.e('Failed to complete stack child', error: e);
      return 'Failed to complete stack child: $e';
    }
  }

  @override
  Future<String?> recordFailure(String habitId) async {
    try {
      final completion = CompletionRecord(
        habitId: habitId,
        userId: _currentUserId,
        completedAt: DateTime.now(),
        xpAwarded: -5, // Penalty for avoidance failure
      );

      _completions.add(completion);

      _logger.d('Recorded failure for habit: $habitId');
      return null; // Success
    } catch (e) {
      _logger.e('Failed to record failure', error: e);
      return 'Failed to record failure: $e';
    }
  }

  @override
  Future<String?> completeBundle(String bundleId) async {
    return 'Bundle completion not implemented in memory repository';
  }

  @override
  Future<String?> addHabitToBundle(String bundleId, String habitId) async {
    return 'Add habit to bundle not implemented in memory repository';
  }

  @override
  Future<void> dispose() async {
    await _ownHabitsController.close();
    await _partnerHabitsController.close();
    _logger.i('MemoryHabitsRepository disposed');
  }

  Future<void> _refreshOwnHabits() async {
    try {
      // Since this is in-memory, just return all habits
      _ownHabitsController.add(List.from(_habits));
    } catch (e) {
      _logger.e('Failed to refresh own habits', error: e);
      _ownHabitsController
          .addError(RepositoryException('Failed to load habits', e));
    }
  }

  Future<void> _refreshPartnerHabits() async {
    try {
      // Create some dummy partner data for development
      final dummyPartnerHabits = await _createDummyPartnerHabits();
      _partnerHabitsController.add(dummyPartnerHabits);
    } catch (e) {
      _logger.e('Failed to refresh partner habits', error: e);
      _partnerHabitsController
          .addError(RepositoryException('Failed to load partner habits', e));
    }
  }

  Future<List<Habit>> _createDummyPartnerHabits() async {
    return [
      Habit(
        id: 'partner_habit_1',
        name: 'Partner\'s Morning Walk',
        description: 'Daily 30-minute walk',
        type: HabitType.basic,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        currentStreak: 3,
        dailyCompletionCount: 1,
      ),
      Habit(
        id: 'partner_habit_2',
        name: 'Partner\'s Reading',
        description: 'Read for 20 minutes',
        type: HabitType.basic,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        currentStreak: 7,
        dailyCompletionCount: 1,
      ),
    ];
  }

  Future<void> _createTestHabits() async {
    if (_habits.isNotEmpty) {
      _logger.d('Memory already has habits, skipping test data creation');
      return;
    }

    _logger.i('Creating test habits in memory...');

    // Create some initial test habits
    final testHabits = [
      Habit(
        id: 'test_habit_1',
        name: 'Morning Exercise',
        description: 'Daily workout routine',
        type: HabitType.basic,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        currentStreak: 3,
      ),
      Habit(
        id: 'test_habit_2',
        name: 'Read Books',
        description: 'Read for at least 30 minutes',
        type: HabitType.basic,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        currentStreak: 2,
      ),
      Habit(
        id: 'test_habit_3',
        name: 'Avoid Social Media',
        description: 'Stay off social media during work hours',
        type: HabitType.avoidance,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        avoidanceSuccessToday: true,
      ),
    ];

    _habits.addAll(testHabits);

    _logger.i('Test habits created in memory');
  }
}

/// Simple completion record for in-memory storage
class CompletionRecord {
  final String habitId;
  final String userId;
  final DateTime completedAt;
  final int xpAwarded;

  CompletionRecord({
    required this.habitId,
    required this.userId,
    required this.completedAt,
    required this.xpAwarded,
  });
}
