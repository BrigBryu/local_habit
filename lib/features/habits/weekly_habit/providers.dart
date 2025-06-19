import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../interval_habit/providers.dart'; // Import dueDateServiceProvider

/// Provider for checking if weekly habits should be shown based on due date
final weeklyHabitsFilterProvider = Provider<bool Function(Habit)>((ref) {
  final dueDateService = ref.watch(dueDateServiceProvider);
  final today = DateTime.now();
  
  return (habit) {
    // Only show weekly habits when they are due
    if (habit.type == HabitType.weekly) {
      return dueDateService.isDue(habit, today);
    }
    // Show all other habit types
    return true;
  };
});

/// Provider for getting formatted weekday names from a habit's weekday mask
final weekdayNamesProvider = Provider.family<List<String>, int?>((ref, weekdayMask) {
  final dueDateService = ref.watch(dueDateServiceProvider);
  if (weekdayMask == null) return [];
  return dueDateService.getWeekdayNames(weekdayMask);
});