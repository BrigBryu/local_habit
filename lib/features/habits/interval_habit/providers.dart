import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../core/services/due_date_service.dart';

/// Provider for DueDateService used by interval habits
final dueDateServiceProvider = Provider<DueDateService>((ref) {
  return DueDateService();
});

/// Provider for checking if interval habits should be shown based on due date
final intervalHabitsFilterProvider = Provider<bool Function(Habit)>((ref) {
  final dueDateService = ref.watch(dueDateServiceProvider);
  final today = DateTime.now();
  
  return (habit) {
    // Only show interval habits when they are due
    if (habit.type == HabitType.interval) {
      return dueDateService.isDue(habit, today);
    }
    // Show all other habit types
    return true;
  };
});