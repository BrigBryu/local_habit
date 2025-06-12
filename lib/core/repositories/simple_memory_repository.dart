import 'dart:async';
import 'package:domain/domain.dart';
import 'package:logger/logger.dart';

import 'habits_repository.dart';

/// Ultra-simple in-memory repository that initializes immediately
class SimpleMemoryRepository implements HabitsRepository {
  final Logger _logger = Logger();
  
  String _currentUserId = 'dev_user';
  
  // Pre-populated test data - no async initialization needed
  List<Habit> get habits => List.from(_habits);
  final List<Habit> _habits = [
    Habit(
      id: 'test_habit_1',
      name: 'Morning Exercise',
      description: 'Daily workout routine',
      type: HabitType.basic,
      createdAt: DateTime(2025, 6, 1),
      currentStreak: 3,
      sessionCompletedToday: false,
    ),
    Habit(
      id: 'test_habit_2',
      name: 'Read Books',
      description: 'Read for at least 30 minutes',
      type: HabitType.basic,
      createdAt: DateTime(2025, 6, 2),
      currentStreak: 2,
      sessionCompletedToday: true,
    ),
    Habit(
      id: 'test_habit_3',
      name: 'Avoid Social Media',
      description: 'Stay off social media during work hours',
      type: HabitType.avoidance,
      createdAt: DateTime(2025, 6, 3),
      avoidanceSuccessToday: true,
    ),
  ];
  
  final List<Habit> _partnerHabits = [
    Habit(
      id: 'partner_habit_1',
      name: 'Partner\'s Morning Walk',
      description: 'Daily 30-minute walk',
      type: HabitType.basic,
      createdAt: DateTime(2025, 6, 1),
      currentStreak: 3,
      dailyCompletionCount: 1,
      sessionCompletedToday: true,
    ),
    Habit(
      id: 'partner_habit_2', 
      name: 'Partner\'s Reading',
      description: 'Read for 20 minutes',
      type: HabitType.basic,
      createdAt: DateTime(2025, 5, 25),
      currentStreak: 7,
      dailyCompletionCount: 1,
      sessionCompletedToday: false,
    ),
  ];
  
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
    _logger.i('SimpleMemoryRepository initialized instantly for user: $_currentUserId');
  }
  
  @override
  Stream<List<Habit>> ownHabits() {
    // Create a stream that immediately emits current data, then listens for updates
    return Stream<List<Habit>>.multi((controller) {
      // Immediately emit current data
      controller.add(List.from(_habits));
      
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
      // Immediately emit current data
      controller.add(List.from(_partnerHabits));
      
      // Listen for future updates
      final subscription = _partnerHabitsController.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
      
      controller.onCancel = () => subscription.cancel();
    });
  }
  
  @override
  Future<String?> addHabit(Habit habit) async {
    try {
      _habits.add(habit);
      _refreshStreams();
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
        _refreshStreams();
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
      _refreshStreams();
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
      _logger.d('Completed habit: $habitId (XP: $xpAwarded)');
      return null; // Success
    } catch (e) {
      _logger.e('Failed to complete habit', error: e);
      return 'Failed to complete habit: $e';
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
    _ownHabitsController.add(List.from(_habits));
    _partnerHabitsController.add(List.from(_partnerHabits));
  }
}