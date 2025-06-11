import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/bundle_service.dart';
import 'package:data_local/repositories/stack_service.dart';
import 'package:logger/logger.dart';

import '../core/repositories/habits_repository.dart';
import 'repository_init_provider.dart';

// Stream provider for own habits
final ownHabitsProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(habitsRepositoryProvider);
  return repository.ownHabits();
});

// Stream provider for partner habits (hardcoded partner for now)
final partnerHabitsProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(habitsRepositoryProvider);
  // TODO: Get actual partner ID from relationship data
  return repository.partnerHabits('dummy_partner_id');
});

// Legacy habits provider that combines both streams for backward compatibility
final habitsProvider = Provider<AsyncValue<List<Habit>>>((ref) {
  return ref.watch(ownHabitsProvider);
});

// Notifier for habit operations
class HabitsNotifier extends StateNotifier<AsyncValue<void>> {
  HabitsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));
  
  final HabitsRepository _repository;
  final Ref _ref;
  final _logger = Logger();
  
  // Business logic services (kept from original)
  final _levelService = LevelService();
  final _bundleService = BundleService();
  final _stackService = StackService();

  Future<String?> addHabit(Habit habit) async {
    state = const AsyncValue.loading();
    try {
      final error = await _repository.addHabit(habit);
      state = const AsyncValue.data(null);
      return error;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to add habit: $e';
    }
  }

  Future<String?> updateHabit(Habit habit) async {
    state = const AsyncValue.loading();
    try {
      final error = await _repository.updateHabit(habit);
      state = const AsyncValue.data(null);
      return error;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to update habit: $e';
    }
  }

  Future<String?> removeHabit(String habitId) async {
    state = const AsyncValue.loading();
    try {
      final error = await _repository.removeHabit(habitId);
      state = const AsyncValue.data(null);
      return error;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to remove habit: $e';
    }
  }

  Future<String?> completeHabit(String habitId) async {
    state = const AsyncValue.loading();
    try {
      // Get current habits to calculate XP
      final habitsAsync = _ref.read(ownHabitsProvider);
      if (habitsAsync.value == null) {
        return 'Failed to load habits for XP calculation';
      }
      
      final habits = habitsAsync.value!;
      final habit = habits.firstWhere(
        (h) => h.id == habitId,
        orElse: () => throw Exception('Habit not found'),
      );

      // Calculate XP using existing logic
      final baseXp = _calculateBaseXp(habit);
      final bonusXp = _calculateBonusXp(habit, habits);
      final totalXp = baseXp + bonusXp;
      
      // TODO: Implement awardXp method in LevelService
      // _levelService.awardXp(totalXp);
      
      // Mark habit as completed
      final updatedHabit = _markHabitCompleted(habit);
      await updateHabit(updatedHabit);
      
      // Record completion in database
      final error = await _repository.completeHabit(habitId, xpAwarded: totalXp);
      
      state = const AsyncValue.data(null);
      _logger.i('Completed habit ${habit.name} for ${totalXp}XP');
      return error;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to complete habit: $e';
    }
  }

  // Bundle-related methods (adapted from original)
  Future<String?> addBundle(String name, String description, List<String> childIds) async {
    try {
      final habitsAsync = _ref.read(ownHabitsProvider);
      if (habitsAsync.value == null) return 'Failed to load habits';
      
      final bundle = _bundleService.createBundle(
        name: name,
        description: description,
        childIds: childIds,
        allHabits: habitsAsync.value!,
      );
      
      await addHabit(bundle);
      
      // Update child habits to reference the bundle
      final updatedChildren = _bundleService.assignChildrenToBundle(bundle.id, childIds, habitsAsync.value!);
      for (final child in updatedChildren) {
        await updateHabit(child);
      }
      
      return null; // Success
    } catch (e) {
      return 'Failed to create bundle: $e';
    }
  }

  // Stack-related methods (adapted from original)
  Future<String?> addStack(String name, String description, List<String> stepIds) async {
    try {
      final habitsAsync = _ref.read(ownHabitsProvider);
      if (habitsAsync.value == null) return 'Failed to load habits';
      
      final stack = _stackService.createStack(
        name: name,
        description: description,
        stepIds: stepIds,
        allHabits: habitsAsync.value!,
      );
      
      await addHabit(stack);
      
      // Update step habits to reference the stack
      final updatedSteps = _stackService.assignStepsToStack(stack.id, stepIds, habitsAsync.value!);
      for (final step in updatedSteps) {
        await updateHabit(step);
      }
      
      return null; // Success
    } catch (e) {
      return 'Failed to create stack: $e';
    }
  }

  List<Habit> getAvailableHabitsForBundle() {
    final habitsAsync = _ref.read(ownHabitsProvider);
    if (habitsAsync.value == null) return [];
    return _bundleService.getAvailableHabitsForBundle(habitsAsync.value!);
  }

  List<Habit> getAvailableHabitsForStack() {
    final habitsAsync = _ref.read(ownHabitsProvider);
    if (habitsAsync.value == null) return [];
    return _stackService.getAvailableHabitsForStack(habitsAsync.value!);
  }

  // XP calculation helpers (from original implementation)
  int _calculateBaseXp(Habit habit) {
    switch (habit.type) {
      case HabitType.basic:
        return 10;
      case HabitType.avoidance:
        return 15;
      case HabitType.bundle:
        return 25;
      case HabitType.stack:
        return 20;
      default:
        return 10;
    }
  }

  int _calculateBonusXp(Habit habit, List<Habit> allHabits) {
    int bonus = 0;
    
    // Streak bonus
    final streakBonus = (habit.currentStreak / 7).floor() * 5;
    bonus += streakBonus;
    
    // Bundle combo bonus
    if (habit.parentBundleId != null) {
      final bundle = allHabits.firstWhere(
        (h) => h.id == habit.parentBundleId,
        orElse: () => habit,
      );
      
      if (bundle.type == HabitType.bundle) {
        // TODO: Implement getBundleChildrenCompletedToday method in BundleService
        final todayCompletions = <String>[]; // _bundleService.getBundleChildrenCompletedToday(bundle, allHabits);
        if (todayCompletions.length >= 2) {
          bonus += 10; // Combo bonus
        }
      }
    }
    
    return bonus;
  }

  Habit _markHabitCompleted(Habit habit) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Update completion tracking
    int newDailyCount = habit.dailyCompletionCount;
    DateTime? newLastReset = habit.lastCompletionCountReset;
    
    if (habit.lastCompletionCountReset == null || 
        DateTime(habit.lastCompletionCountReset!.year, 
                habit.lastCompletionCountReset!.month, 
                habit.lastCompletionCountReset!.day) != today) {
      newDailyCount = 1;
      newLastReset = now;
    } else {
      newDailyCount++;
    }
    
    // Update streak
    int newStreak = habit.currentStreak;
    if (habit.lastCompleted == null ||
        DateTime(habit.lastCompleted!.year, habit.lastCompleted!.month, habit.lastCompleted!.day) != today) {
      newStreak++;
    }
    
    return Habit(
      id: habit.id,
      name: habit.name,
      description: habit.description,
      type: habit.type,
      stackedOnHabitId: habit.stackedOnHabitId,
      bundleChildIds: habit.bundleChildIds,
      parentBundleId: habit.parentBundleId,
      timeoutMinutes: habit.timeoutMinutes,
      availableDays: habit.availableDays,
      createdAt: habit.createdAt,
      lastCompleted: now,
      lastAlarmTriggered: habit.lastAlarmTriggered,
      sessionStartTime: habit.sessionStartTime,
      lastSessionStarted: habit.lastSessionStarted,
      sessionCompletedToday: true,
      dailyCompletionCount: newDailyCount,
      lastCompletionCountReset: newLastReset,
      dailyFailureCount: habit.dailyFailureCount,
      lastFailureCountReset: habit.lastFailureCountReset,
      avoidanceSuccessToday: habit.avoidanceSuccessToday,
      currentStreak: newStreak,
    );
  }

  // Stub methods for missing functionality
  Future<String?> recordFailure(String habitId) async {
    // TODO: Implement avoidance habit failure recording
    _logger.d('Record failure called for habit: $habitId');
    return null; // Success
  }

  Future<String?> completeBundle(String bundleId) async {
    // TODO: Implement bundle completion logic
    _logger.d('Complete bundle called for bundle: $bundleId');
    return null; // Success
  }

  Future<String?> addHabitToBundle(String bundleId, String habitId) async {
    // TODO: Implement adding habit to bundle
    _logger.d('Add habit $habitId to bundle $bundleId');
    return null; // Success
  }
}

final habitsNotifierProvider = StateNotifierProvider<HabitsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(habitsRepositoryProvider);
  return HabitsNotifier(repository, ref);
});

// Repository initialization is now handled by repository_init_provider.dart