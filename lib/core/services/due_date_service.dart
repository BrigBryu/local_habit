import 'package:domain/domain.dart';

/// Service for calculating due dates and availability for occasional habits
class DueDateService {
  /// Check if an interval or weekly habit is due for completion
  bool isDue(Habit habit, DateTime today) {
    switch (habit.type) {
      case HabitType.interval:
        return _isIntervalHabitDue(habit, today);
      case HabitType.weekly:
        return _isWeeklyHabitDue(habit, today);
      case HabitType.basic:
      case HabitType.avoidance:
      case HabitType.bundle:
      case HabitType.stack:
        return true; // Always available for non-occasional habits
    }
  }

  /// Calculate the next due date for an occasional habit
  DateTime? nextDue(Habit habit) {
    switch (habit.type) {
      case HabitType.interval:
        return _nextIntervalDue(habit);
      case HabitType.weekly:
        return _nextWeeklyDue(habit);
      case HabitType.basic:
      case HabitType.avoidance:
      case HabitType.bundle:
      case HabitType.stack:
        return null; // No next due date for regular habits
    }
  }

  /// Get a human-readable description of when the habit is next due
  String getNextDueDescription(Habit habit) {
    final nextDueDate = nextDue(habit);
    if (nextDueDate == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day);

    final daysDiff = dueDate.difference(today).inDays;

    if (daysDiff == 0) return 'Due today';
    if (daysDiff == 1) return 'Due tomorrow';
    if (daysDiff < 7) return 'Due in $daysDiff days';
    
    // For weekly habits, show the day name
    if (habit.type == HabitType.weekly) {
      final dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      final dayName = dayNames[nextDueDate.weekday % 7];
      return 'Due $dayName';
    }
    
    return 'Due in $daysDiff days';
  }

  bool _isIntervalHabitDue(Habit habit, DateTime today) {
    if (habit.intervalDays == null) return false;
    
    final lastCompletion = habit.lastCompletionDate;
    if (lastCompletion == null) return true; // First time, always due
    
    final daysSinceLastCompletion = today.difference(lastCompletion).inDays;
    return daysSinceLastCompletion >= habit.intervalDays!;
  }

  bool _isWeeklyHabitDue(Habit habit, DateTime today) {
    if (habit.weekdayMask == null) return false;
    
    // Get today's weekday (0=Sunday, 1=Monday, etc.)
    final todayWeekday = today.weekday % 7;
    
    // Check if today's bit is set in the mask
    return (habit.weekdayMask! & (1 << todayWeekday)) != 0;
  }

  DateTime? _nextIntervalDue(Habit habit) {
    if (habit.intervalDays == null) return null;
    
    final lastCompletion = habit.lastCompletionDate;
    if (lastCompletion == null) {
      // Never completed, due today
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
    
    return lastCompletion.add(Duration(days: habit.intervalDays!));
  }

  DateTime? _nextWeeklyDue(Habit habit) {
    if (habit.weekdayMask == null) return null;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Find the next day that matches the weekday mask
    for (int i = 0; i < 7; i++) {
      final checkDate = today.add(Duration(days: i));
      final weekday = checkDate.weekday % 7;
      
      if ((habit.weekdayMask! & (1 << weekday)) != 0) {
        return checkDate;
      }
    }
    
    return null; // Should never happen if mask is valid
  }

  /// Get weekday names for a weekly habit's mask
  List<String> getWeekdayNames(int weekdayMask) {
    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final result = <String>[];
    
    for (int i = 0; i < 7; i++) {
      if ((weekdayMask & (1 << i)) != 0) {
        result.add(dayNames[i]);
      }
    }
    
    return result;
  }

  /// Create a weekday mask from a list of weekday indices (0=Sunday, 1=Monday, etc.)
  int createWeekdayMask(List<int> weekdays) {
    int mask = 0;
    for (final day in weekdays) {
      if (day >= 0 && day < 7) {
        mask |= (1 << day);
      }
    }
    return mask;
  }

  /// Get weekday indices from a weekday mask
  List<int> getWeekdayIndices(int weekdayMask) {
    final result = <int>[];
    for (int i = 0; i < 7; i++) {
      if ((weekdayMask & (1 << i)) != 0) {
        result.add(i);
      }
    }
    return result;
  }
}