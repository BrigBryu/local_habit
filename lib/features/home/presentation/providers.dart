import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';

/// Provider for getting today's visible habits as a stream
final homeHabitsProvider = Provider<List<Habit>>((ref) {
  final habits = ref.watch(habitsProvider);
  final timeService = TimeService();
  final today = timeService.today();
  
  // Return all habits that are visible for today
  return habits.where((habit) {
    // Filter out habits that shouldn't be shown today
    if (habit.availableDays != null && habit.availableDays!.isNotEmpty) {
      final dayOfWeek = today.weekday; // 1 = Monday, 7 = Sunday
      if (!habit.availableDays!.contains(dayOfWeek)) {
        return false;
      }
    }
    return true;
  }).toList();
});

/// Provider for level state
final levelStateProvider = Provider<Map<String, dynamic>>((ref) {
  final levelService = LevelService();
  return {
    'currentLevel': levelService.currentLevel,
    'currentXP': levelService.currentXP,
    'nextLevelXP': levelService.xpForNextLevel,
    'progress': levelService.currentXP / levelService.xpForNextLevel,
  };
});

/// Provider for checking if any routes are available
final routeAvailabilityProvider = Provider<Map<String, bool>>((ref) {
  return {
    'addHabit': true, // AddHabitScreen exists
    'levels': true,   // LevelPage exists
    'viewHabit': false, // Will be placeholder
  };
});