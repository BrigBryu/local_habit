import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/habit.dart';
import '../core/services/habit_service.dart';

// Export the main providers from habit service
export '../core/services/habit_service.dart' show habitServiceProvider, habitListProvider;

// Main habits provider (just use habitListProvider directly)
final habitsProvider = Provider<AsyncValue<List<Habit>>>((ref) {
  return ref.watch(habitListProvider);
});

// Notifier for habit operations
class HabitsNotifier extends StateNotifier<AsyncValue<void>> {
  HabitsNotifier(this._ref)
      : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<String?> addHabit(Habit habit) async {
    state = const AsyncValue.loading();
    try {
      final habitService = _ref.read(habitServiceProvider.notifier);
      await habitService.updateHabit(habit);
      state = const AsyncValue.data(null);
      return null;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to add habit: $e';
    }
  }

  Future<String?> updateHabit(Habit habit) async {
    state = const AsyncValue.loading();
    try {
      final habitService = _ref.read(habitServiceProvider.notifier);
      await habitService.updateHabit(habit);
      state = const AsyncValue.data(null);
      return null;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to update habit: $e';
    }
  }

  Future<String?> removeHabit(Habit habit) async {
    state = const AsyncValue.loading();
    try {
      final habitService = _ref.read(habitServiceProvider.notifier);
      await habitService.deleteHabit(habit);
      state = const AsyncValue.data(null);
      return null;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to remove habit: $e';
    }
  }

  Future<String?> toggleComplete(Habit habit) async {
    state = const AsyncValue.loading();
    try {
      final habitService = _ref.read(habitServiceProvider.notifier);
      await habitService.toggleComplete(habit);
      state = const AsyncValue.data(null);
      return null;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to complete habit: $e';
    }
  }

}

final habitsNotifierProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<void>>((ref) {
  return HabitsNotifier(ref);
});