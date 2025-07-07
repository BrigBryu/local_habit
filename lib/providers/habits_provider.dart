import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../core/repositories/habits_repository.dart';
import 'repository_init_provider.dart';

// Stream provider for own habits
final ownHabitsProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(habitsRepositoryProvider);
  return repository.ownHabits();
});

// Legacy habits provider that combines both streams for backward compatibility
final habitsProvider = Provider<AsyncValue<List<Habit>>>((ref) {
  return ref.watch(ownHabitsProvider);
});

// Notifier for habit operations
class HabitsNotifier extends StateNotifier<AsyncValue<void>> {
  HabitsNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  final HabitsRepository _repository;
  final Ref _ref;

  Future<String?> addHabit(Habit habit) async {
    state = const AsyncValue.loading();
    try {
      final error = await _repository.addHabit(habit);

      // Invalidate providers to refresh UI
      _ref.invalidate(ownHabitsProvider);

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

      // Invalidate providers to refresh UI
      _ref.invalidate(ownHabitsProvider);

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

      // Invalidate providers to refresh UI
      _ref.invalidate(ownHabitsProvider);

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
      // Complete habit without XP
      final error = await _repository.completeHabit(habitId);

      // Invalidate habits provider to ensure UI updates
      _ref.invalidate(ownHabitsProvider);

      state = const AsyncValue.data(null);
      return error;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to complete habit: $e';
    }
  }

  Future<String?> recordFailure(String habitId) async {
    state = const AsyncValue.loading();
    try {
      final error = await _repository.recordFailure(habitId);
      
      // Invalidate providers to refresh UI
      _ref.invalidate(ownHabitsProvider);
      
      state = const AsyncValue.data(null);
      return error;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to record failure: $e';
    }
  }

  Future<String?> completeStackChild(String stackId) async {
    state = const AsyncValue.loading();
    try {
      final error = await _repository.completeStackChild(stackId);
      
      // Invalidate providers to refresh UI
      _ref.invalidate(ownHabitsProvider);
      
      state = const AsyncValue.data(null);
      return error;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to complete stack child: $e';
    }
  }

  Future<String?> addBundle(String name, String description, List<String> childHabitIds) async {
    state = const AsyncValue.loading();
    try {
      final bundle = Habit.createBundle(
        name: name,
        description: description,
        childIds: childHabitIds,
      );
      
      final error = await _repository.addHabit(bundle);
      
      // Invalidate providers to refresh UI
      _ref.invalidate(ownHabitsProvider);
      
      state = const AsyncValue.data(null);
      return error;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to add bundle: $e';
    }
  }

  Future<String?> addStack(String name, String description, List<String> childHabitIds) async {
    state = const AsyncValue.loading();
    try {
      final stack = Habit.create(
        name: name,
        description: description,
        type: HabitType.stack,
        stackChildIds: childHabitIds,
      );
      
      final error = await _repository.addHabit(stack);
      
      // Invalidate providers to refresh UI
      _ref.invalidate(ownHabitsProvider);
      
      state = const AsyncValue.data(null);
      return error;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to add stack: $e';
    }
  }

  Future<String?> completeBundle(String bundleId) async {
    state = const AsyncValue.loading();
    try {
      final error = await _repository.completeBundle(bundleId);
      
      // Invalidate providers to refresh UI
      _ref.invalidate(ownHabitsProvider);
      
      state = const AsyncValue.data(null);
      return error;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to complete bundle: $e';
    }
  }

  Future<String?> addHabitToBundle(String bundleId, String habitId) async {
    state = const AsyncValue.loading();
    try {
      final error = await _repository.addHabitToBundle(bundleId, habitId);
      
      // Invalidate providers to refresh UI
      _ref.invalidate(ownHabitsProvider);
      
      state = const AsyncValue.data(null);
      return error;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to add habit to bundle: $e';
    }
  }

  List<Habit> getAvailableHabitsForBundle() {
    // Get current habits from the provider
    final habitsAsync = _ref.read(ownHabitsProvider);
    return habitsAsync.when(
      data: (habits) => habits.where((h) => 
        h.type != HabitType.bundle && 
        h.parentBundleId == null
      ).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  Future<String?> updateHabitOrder(List<Habit> reorderedHabits) async {
    state = const AsyncValue.loading();
    try {
      // Update each habit with new display order
      for (int i = 0; i < reorderedHabits.length; i++) {
        final habit = reorderedHabits[i];
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
          lastCompleted: habit.lastCompleted,
          lastAlarmTriggered: habit.lastAlarmTriggered,
          sessionStartTime: habit.sessionStartTime,
          lastSessionStarted: habit.lastSessionStarted,
          sessionCompletedToday: habit.sessionCompletedToday,
          dailyCompletionCount: habit.dailyCompletionCount,
          lastCompletionCountReset: habit.lastCompletionCountReset,
          dailyFailureCount: habit.dailyFailureCount,
          lastFailureCountReset: habit.lastFailureCountReset,
          avoidanceSuccessToday: habit.avoidanceSuccessToday,
          currentStreak: habit.currentStreak,
          intervalDays: habit.intervalDays,
          weekdayMask: habit.weekdayMask,
          lastCompletionDate: habit.lastCompletionDate,
          displayOrder: i,
        );
        await _repository.updateHabit(updatedHabit);
      }
      
      // Invalidate providers to refresh UI
      _ref.invalidate(ownHabitsProvider);
      
      state = const AsyncValue.data(null);
      return null; // Success
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to update habit order: $e';
    }
  }
}

final habitsNotifierProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(habitsRepositoryProvider);
  return HabitsNotifier(repository, ref);
});