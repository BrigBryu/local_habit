import 'dart:async';
import 'package:domain/domain.dart';
import 'package:logger/logger.dart';

import 'habits_repository.dart';

/// Ultra-simple in-memory repository that initializes immediately
class SimpleMemoryRepository implements HabitsRepository {
  final Logger _logger = Logger();

  String _currentUserId = 'dev_user';

  // User-specific habits storage - simulates different users having different habits
  final Map<String, List<Habit>> _userHabits = {
    'alice_dev_user': [
      Habit(
        id: 'alice_habit_1',
        name: 'Alice\'s Morning Yoga',
        description: 'Daily 20-minute yoga session',
        type: HabitType.basic,
        createdAt: DateTime(2025, 6, 1),
        currentStreak: 5,
        sessionCompletedToday: true,
      ),
      Habit(
        id: 'alice_habit_2',
        name: 'Alice\'s Journaling',
        description: 'Write in journal for 10 minutes',
        type: HabitType.basic,
        createdAt: DateTime(2025, 6, 2),
        currentStreak: 3,
        sessionCompletedToday: false,
      ),
      Habit(
        id: 'alice_habit_3',
        name: 'Alice Avoids Caffeine',
        description: 'No caffeine after 2 PM',
        type: HabitType.avoidance,
        createdAt: DateTime(2025, 6, 3),
        avoidanceSuccessToday: true,
      ),
    ],
    'bob_dev_user': [
      Habit(
        id: 'bob_habit_1',
        name: 'Bob\'s Morning Run',
        description: 'Daily 30-minute run',
        type: HabitType.basic,
        createdAt: DateTime(2025, 6, 1),
        currentStreak: 4,
        sessionCompletedToday: false,
      ),
      Habit(
        id: 'bob_habit_2',
        name: 'Bob\'s Reading',
        description: 'Read technical books for 25 minutes',
        type: HabitType.basic,
        createdAt: DateTime(2025, 5, 28),
        currentStreak: 8,
        sessionCompletedToday: true,
      ),
    ],
    'charlie_dev_user': [
      Habit(
        id: 'charlie_habit_1',
        name: 'Charlie\'s Guitar Practice',
        description: 'Practice guitar for 30 minutes',
        type: HabitType.basic,
        createdAt: DateTime(2025, 6, 1),
        currentStreak: 2,
        sessionCompletedToday: true,
      ),
    ],
    'frank_dev_user': [
      Habit(
        id: 'frank_habit_1',
        name: 'Frank\'s Swimming',
        description: 'Swim 20 laps at the pool',
        type: HabitType.basic,
        createdAt: DateTime(2025, 6, 1),
        currentStreak: 6,
        sessionCompletedToday: true,
      ),
      Habit(
        id: 'frank_habit_2',
        name: 'Frank\'s Meditation',
        description: 'Meditate for 15 minutes',
        type: HabitType.basic,
        createdAt: DateTime(2025, 5, 20),
        currentStreak: 12,
        sessionCompletedToday: false,
      ),
      Habit(
        id: 'frank_habit_3',
        name: 'Frank Avoids Sugar',
        description: 'No added sugar in diet',
        type: HabitType.avoidance,
        createdAt: DateTime(2025, 6, 5),
        avoidanceSuccessToday: true,
      ),
    ],
  };

  // Get habits for current user
  List<Habit> get habits => List.from(_userHabits[_currentUserId] ?? []);

  // Stream controllers for reactive updates
  final _ownHabitsController = StreamController<List<Habit>>.broadcast();
  final _partnerHabitsController = StreamController<List<Habit>>.broadcast();

  @override
  String getCurrentUserId() => _currentUserId;

  @override
  Future<void> setCurrentUserId(String userId) async {
    _currentUserId = userId;
    _refreshStreams();
  }

  @override
  Future<void> initialize() async {
    // No async operations - just start streaming
    _refreshStreams();
    _logger.i(
        'SimpleMemoryRepository initialized instantly for user: $_currentUserId');
  }

  @override
  Stream<List<Habit>> ownHabits() {
    // Create a stream that immediately emits current data, then listens for updates
    return Stream<List<Habit>>.multi((controller) {
      // Immediately emit current data for current user
      final currentUserHabits = _userHabits[_currentUserId] ?? [];
      controller.add(List.from(currentUserHabits));

      // Listen for future updates
      final subscription = _ownHabitsController.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );

      controller.onCancel = () => subscription.cancel();
    });
  }

  @override
  Stream<List<Habit>> partnerHabits(String partnerId) {
    // Create a stream that immediately emits current data, then listens for updates
    return Stream<List<Habit>>.multi((controller) {
      // Get habits for specific partner ID
      final partnerHabitsData = _userHabits[partnerId] ?? [];
      _logger.d(
          '🎯 Getting habits for partner: $partnerId, found ${partnerHabitsData.length} habits');

      // Immediately emit current data
      controller.add(List.from(partnerHabitsData));

      // Listen for future updates
      final subscription = _partnerHabitsController.stream.listen(
        (allPartnerHabits) {
          // When partner habits update, re-filter for this specific partner
          final updatedPartnerHabits = _userHabits[partnerId] ?? [];
          controller.add(List.from(updatedPartnerHabits));
        },
        onError: controller.addError,
        onDone: controller.close,
      );

      controller.onCancel = () => subscription.cancel();
    });
  }

  @override
  Future<String?> addHabit(Habit habit) async {
    try {
      final userHabits = _userHabits[_currentUserId] ??= [];
      userHabits.add(habit);
      _refreshStreams();
      _logger.d('Added habit: ${habit.name} for user: $_currentUserId');
      return null; // Success
    } catch (e) {
      _logger.e('Failed to add habit', error: e);
      return 'Failed to add habit: $e';
    }
  }

  @override
  Future<String?> updateHabit(Habit habit) async {
    try {
      final userHabits = _userHabits[_currentUserId] ?? [];
      final index = userHabits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        userHabits[index] = habit;
        _refreshStreams();
        _logger.d('Updated habit: ${habit.name} for user: $_currentUserId');
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
      final userHabits = _userHabits[_currentUserId] ?? [];
      userHabits.removeWhere((h) => h.id == habitId);
      _refreshStreams();
      _logger.d('Removed habit: $habitId for user: $_currentUserId');
      return null; // Success
    } catch (e) {
      _logger.e('Failed to remove habit', error: e);
      return 'Failed to remove habit: $e';
    }
  }

  @override
  Future<String?> completeHabit(String habitId, {int xpAwarded = 0}) async {
    try {
      final userHabits = _userHabits[_currentUserId] ?? [];
      final habitIndex = userHabits.indexWhere((h) => h.id == habitId);

      if (habitIndex != -1) {
        final habit = userHabits[habitIndex];

        // Update habit completion status - create new instance with updated values
        final updatedHabit = Habit(
          id: habit.id,
          name: habit.name,
          description: habit.description,
          type: habit.type,
          stackedOnHabitId: habit.stackedOnHabitId,
          bundleChildIds: habit.bundleChildIds,
          parentBundleId: habit.parentBundleId,
          parentStackId: habit.parentStackId,
          stackChildIds: habit.stackChildIds,
          currentChildIndex: habit.currentChildIndex,
          timeoutMinutes: habit.timeoutMinutes,
          availableDays: habit.availableDays,
          createdAt: habit.createdAt,
          lastCompleted: DateTime.now(),
          lastAlarmTriggered: habit.lastAlarmTriggered,
          sessionStartTime: habit.sessionStartTime,
          lastSessionStarted: habit.lastSessionStarted,
          sessionCompletedToday: true,
          dailyCompletionCount: habit.dailyCompletionCount + 1,
          lastCompletionCountReset: habit.lastCompletionCountReset,
          dailyFailureCount: habit.dailyFailureCount,
          lastFailureCountReset: habit.lastFailureCountReset,
          avoidanceSuccessToday: habit.avoidanceSuccessToday,
          currentStreak: habit.currentStreak + 1,
        );

        userHabits[habitIndex] = updatedHabit;

        // Trigger refresh for all streams (own habits and partner habits)
        _refreshStreams();
        _triggerGlobalPartnerHabitsRefresh();

        _logger.d('✅ Completed habit: ${habit.name} for user: $_currentUserId');
        _logger.d('🔄 Triggered global partner habits refresh');
        return null; // Success
      }

      return 'Habit not found';
    } catch (e) {
      _logger.e('Failed to complete habit', error: e);
      return 'Failed to complete habit: $e';
    }
  }

  @override
  Future<String?> completeStackChild(String stackId) async {
    try {
      _logger.d('Completed stack child for habit: $stackId');
      return null; // Success - simplified implementation
    } catch (e) {
      _logger.e('Failed to complete stack child', error: e);
      return 'Failed to complete stack child: $e';
    }
  }

  @override
  Future<String?> recordFailure(String habitId) async {
    try {
      _logger.d('Recorded failure for habit: $habitId');
      return null; // Success
    } catch (e) {
      _logger.e('Failed to record failure', error: e);
      return 'Failed to record failure: $e';
    }
  }

  @override
  Future<void> dispose() async {
    await _ownHabitsController.close();
    await _partnerHabitsController.close();
    _logger.i('SimpleMemoryRepository disposed');
  }

  void _refreshStreams() {
    final currentUserHabits = _userHabits[_currentUserId] ?? [];
    _ownHabitsController.add(List.from(currentUserHabits));
    _partnerHabitsController
        .add(List.from(currentUserHabits)); // Trigger partner habits refresh
  }

  /// Trigger a global refresh for partner habits across all users
  void _triggerGlobalPartnerHabitsRefresh() {
    // Emit an event that will cause all partner habit streams to refresh
    // This simulates real-time sync when habits are completed
    _partnerHabitsController.add(List.from(_userHabits[_currentUserId] ?? []));
  }
}
