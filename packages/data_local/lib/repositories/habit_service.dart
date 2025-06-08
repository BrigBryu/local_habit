import 'package:flutter/material.dart';
import '../models/habit.dart';
import 'time_service.dart';

/// Simple in-memory habit repository for MVP
/// Following repository pattern from clean architecture
class HabitService {
  static final HabitService _instance = HabitService._internal();
  factory HabitService() => _instance;
  HabitService._internal();

  final List<Habit> _habits = [];

  /// Get all habits
  List<Habit> getAllHabits() {
    return List.unmodifiable(_habits);
  }

  /// Add a new habit with validation
  Future<String> addHabit({
    required String name,
    required String description,
    required HabitType type,
    String? stackedOnHabitId,
    TimeOfDay? alarmTime,
    int? timeoutMinutes,
    TimeOfDay? windowStartTime,
    TimeOfDay? windowEndTime,
    List<int>? availableDays,
  }) async {
    // Validation
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

    // Validate stacking
    if (type == HabitType.stack) {
      if (stackedOnHabitId == null || stackedOnHabitId.isEmpty) {
        throw ArgumentError('Habit stack must specify a base habit');
      }
      
      final baseHabitExists = _habits.any((h) => h.id == stackedOnHabitId);
      if (!baseHabitExists) {
        throw ArgumentError('Base habit not found');
      }
    }

    // Validate alarm habit
    if (type == HabitType.alarmHabit) {
      if (alarmTime == null) {
        throw ArgumentError('Alarm habit must have an alarm time');
      }
      
      if (timeoutMinutes == null || timeoutMinutes <= 0) {
        throw ArgumentError('Alarm habit must have a positive completion window duration');
      }
    }

    // Validate timed session
    if (type == HabitType.timedSession) {
      if (timeoutMinutes == null || timeoutMinutes <= 0) {
        throw ArgumentError('Timed session must have a positive duration');
      }
    }

    // Validate time window
    if (type == HabitType.timeWindow) {
      if (windowStartTime == null || windowEndTime == null) {
        throw ArgumentError('Time window must have start and end times');
      }
      
      if (availableDays == null || availableDays.isEmpty) {
        throw ArgumentError('Time window must have at least one available day');
      }
    }

    // Create and add habit
    final habit = Habit.create(
      name: trimmedName,
      description: trimmedDescription,
      type: type,
      stackedOnHabitId: stackedOnHabitId,
      alarmTime: alarmTime,
      timeoutMinutes: timeoutMinutes,
      windowStartTime: windowStartTime,
      windowEndTime: windowEndTime,
      availableDays: availableDays,
    );

    _habits.add(habit);
    return habit.id;
  }

  /// Add a habit directly (for internal use, bypasses validation)
  Future<void> addHabitDirect(Habit habit) async {
    _habits.add(habit);
  }

  /// Get a habit by ID
  Habit? getHabitById(String habitId) {
    try {
      return _habits.firstWhere((h) => h.id == habitId);
    } catch (e) {
      return null;
    }
  }

  /// Update a habit directly (for internal use)
  Future<void> updateHabitDirect(Habit updatedHabit) async {
    final index = _habits.indexWhere((habit) => habit.id == updatedHabit.id);
    if (index != -1) {
      _habits[index] = updatedHabit;
    }
  }

  /// Complete a habit by ID
  Future<void> completeHabit(String habitId) async {
    final index = _habits.indexWhere((habit) => habit.id == habitId);
    if (index == -1) {
      throw ArgumentError('Habit not found');
    }

    _habits[index] = _habits[index].complete();
  }

  /// Check if habit is completed today
  bool isCompletedToday(String habitId) {
    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => throw ArgumentError('Habit not found'),
    );

    if (habit.lastCompleted == null) return false;

    final timeService = TimeService();
    return timeService.isSameDay(habit.lastCompleted!, timeService.now());
  }

  /// Get current streak for a habit (accounting for missed days)
  int getHabitCurrentStreak(String habitId) {
    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => throw ArgumentError('Habit not found'),
    );
    return getCurrentStreak(habit);
  }

  /// Get base habit name for stacked habits
  String? getBaseHabitName(String habitId) {
    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => throw ArgumentError('Habit not found'),
    );
    
    if (habit.stackedOnHabitId == null) return null;
    
    final baseHabit = _habits.firstWhere(
      (h) => h.id == habit.stackedOnHabitId,
      orElse: () => throw ArgumentError('Base habit not found'),
    );
    
    return baseHabit.name;
  }

  /// Check if a stacked habit should be visible (base habit completed today)
  bool isStackedHabitVisible(String habitId) {
    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => throw ArgumentError('Habit not found'),
    );
    
    // If it's not a stacked habit, it's always visible
    if (habit.type != HabitType.stack || habit.stackedOnHabitId == null) {
      return true;
    }
    
    // Check if base habit is completed today
    return isCompletedToday(habit.stackedOnHabitId!);
  }

  /// Get all visible habits (base habits + unlocked stacked habits)
  List<Habit> getVisibleHabits() {
    return _habits.where((habit) => isStackedHabitVisible(habit.id)).toList();
  }

  /// Get habit chain depth (how many levels deep in the stack)
  int getHabitChainDepth(String habitId) {
    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => throw ArgumentError('Habit not found'),
    );
    
    if (habit.stackedOnHabitId == null) return 1;
    return 1 + getHabitChainDepth(habit.stackedOnHabitId!);
  }

  /// Get combined display name for completed habit chains
  String getHabitDisplayName(String habitId) {
    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => throw ArgumentError('Habit not found'),
    );
    
    // If not a stack or not completed, return normal display name
    if (habit.type != HabitType.stack || !isCompletedToday(habitId)) {
      return habit.displayName;
    }
    
    // If both base and stack are completed, show combined name
    if (habit.stackedOnHabitId != null && isCompletedToday(habit.stackedOnHabitId!)) {
      final baseHabitName = getBaseHabitName(habitId) ?? 'Unknown';
      final chainDepth = getHabitChainDepth(habitId);
      return '$baseHabitName → ${habit.name} 📚$chainDepth';
    }
    
    return habit.displayName;
  }

  /// Get detailed habit stats for debugging
  Map<String, dynamic> getHabitStats(String habitId) {
    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => throw ArgumentError('Habit not found'),
    );

    final timeService = TimeService();
    final daysSinceCreated = habit.createdAt != null 
        ? timeService.daysBetween(habit.createdAt, timeService.now())
        : 0;
    
    final daysSinceLastCompleted = habit.lastCompleted != null
        ? timeService.daysBetween(habit.lastCompleted!, timeService.now())
        : null;

    return {
      'name': habit.name,
      'storedStreak': habit.currentStreak,
      'currentStreak': getCurrentStreak(habit),
      'lastCompleted': habit.lastCompleted?.toString(),
      'daysSinceCreated': daysSinceCreated,
      'daysSinceLastCompleted': daysSinceLastCompleted,
      'completedToday': isCompletedToday(habitId),
    };
  }

  /// Reset all habits (for testing)
  void resetAllHabits() {
    _habits.clear();
    print('🗑️ All habits cleared');
  }

  /// Get current date info
  String getCurrentDateInfo() {
    final timeService = TimeService();
    final now = timeService.now();
    return 'Current date: ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}