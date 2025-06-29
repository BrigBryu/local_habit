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
}

final habitsNotifierProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(habitsRepositoryProvider);
  return HabitsNotifier(repository, ref);
});