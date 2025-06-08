
import '../services/time_service.dart';
import 'base_habit.dart';
import 'habit_icon.dart';
import 'time_of_day.dart';

/// Time window habit (only available during specific hours/days)
class TimeWindowHabit extends BaseHabit {
  final TimeOfDay windowStartTime;
  final TimeOfDay windowEndTime;
  final List<int> availableDays; // 1=Monday, 2=Tuesday, ..., 7=Sunday

  const TimeWindowHabit({
    required super.id,
    required super.name,
    required super.description,
    required super.createdAt,
    required this.windowStartTime,
    required this.windowEndTime,
    required this.availableDays,
    super.lastCompleted,
    super.currentStreak = 0,
    super.dailyCompletionCount = 0,
    super.lastCompletionCountReset,
  });

  @override
  HabitIcon get icon => HabitIcon.schedule;

  @override
  String get typeName => 'Time Window';

  @override
  String get displayName => '$name 🕐${_formatTimeRange()}';

  String _formatTimeRange() {
    final start = _formatTime(windowStartTime);
    final end = _formatTime(windowEndTime);
    return '$start-$end';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Check if current time is within the available window
  bool isWithinWindow(TimeService timeService) {
    final now = timeService.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final currentDay = now.weekday; // 1=Monday, 7=Sunday
    
    // Check if today is an available day
    if (!availableDays.contains(currentDay)) {
      return false;
    }
    
    // Check if current time is within the window
    final startMinutes = windowStartTime.hour * 60 + windowStartTime.minute;
    final endMinutes = windowEndTime.hour * 60 + windowEndTime.minute;
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    
    if (startMinutes <= endMinutes) {
      // Normal case: start and end on same day
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Overnight case: window crosses midnight
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  @override
  bool canComplete(TimeService timeService) {
    if (isCompletedToday(timeService)) return false;
    return isWithinWindow(timeService);
  }

  @override
  String getStatusText(TimeService timeService) {
    if (isCompletedToday(timeService)) {
      return 'Window completed! 🎉';
    }
    
    final now = timeService.now();
    final currentDay = now.weekday;
    
    // Check if today is an available day
    if (!availableDays.contains(currentDay)) {
      return '🔒 Not available today';
    }
    
    if (isWithinWindow(timeService)) {
      final timeLeft = _getTimeLeftInWindow(timeService);
      return '🟢 Available ($timeLeft left)';
    } else {
      final timeUntilOpen = _getTimeUntilOpen(timeService);
      return '🔒 Opens in $timeUntilOpen';
    }
  }

  /// Get time remaining in current window
  String _getTimeLeftInWindow(TimeService timeService) {
    final now = timeService.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final endMinutes = windowEndTime.hour * 60 + windowEndTime.minute;
    
    int remainingMinutes;
    if (windowStartTime.hour * 60 + windowStartTime.minute <= endMinutes) {
      // Normal case
      remainingMinutes = endMinutes - currentMinutes;
    } else {
      // Overnight case
      if (currentMinutes <= endMinutes) {
        remainingMinutes = endMinutes - currentMinutes;
      } else {
        // After end time, calculate until next day's end
        remainingMinutes = (24 * 60) - currentMinutes + endMinutes;
      }
    }
    
    final hours = remainingMinutes ~/ 60;
    final minutes = remainingMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  /// Get time until window opens
  String _getTimeUntilOpen(TimeService timeService) {
    final now = timeService.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final currentDay = now.weekday;
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = windowStartTime.hour * 60 + windowStartTime.minute;
    
    // If today is available but we're before start time
    if (availableDays.contains(currentDay) && currentMinutes < startMinutes) {
      final minutesUntilStart = startMinutes - currentMinutes;
      final hours = minutesUntilStart ~/ 60;
      final minutes = minutesUntilStart % 60;
      return '${hours}h ${minutes}m';
    }
    
    // Find next available day
    int daysUntilNext = 1;
    int nextDay = (currentDay % 7) + 1;
    
    while (!availableDays.contains(nextDay) && daysUntilNext < 7) {
      daysUntilNext++;
      nextDay = (nextDay % 7) + 1;
    }
    
    if (daysUntilNext == 1) {
      // Tomorrow
      final minutesUntilMidnight = (24 * 60) - currentMinutes;
      final totalMinutes = minutesUntilMidnight + startMinutes;
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return '${hours}h ${minutes}m';
    } else {
      // Multiple days
      return '${daysUntilNext}d';
    }
  }

  /// Get available days as readable string
  String getAvailableDaysString() {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayStrings = availableDays.map((day) => dayNames[day - 1]).toList();
    
    if (dayStrings.length == 7) return 'Every day';
    if (dayStrings.length == 5 && 
        availableDays.contains(1) && availableDays.contains(2) && 
        availableDays.contains(3) && availableDays.contains(4) && 
        availableDays.contains(5)) {
      return 'Weekdays';
    }
    if (dayStrings.length == 2 && 
        availableDays.contains(6) && availableDays.contains(7)) {
      return 'Weekends';
    }
    
    return dayStrings.join(', ');
  }

  @override
  TimeWindowHabit complete() {
    final timeService = TimeService();
    final now = timeService.now();
    
    // Calculate new streak
    int newStreak = currentStreak;
    if (lastCompleted != null) {
      final daysSinceCompletion = timeService.daysBetween(lastCompleted!, now);
      if (daysSinceCompletion == 1) {
        newStreak = currentStreak + 1;
      } else if (daysSinceCompletion == 0) {
        newStreak = currentStreak;
      } else {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    return copyWith(
      lastCompleted: now,
      currentStreak: newStreak,
      dailyCompletionCount: dailyCompletionCount + 1,
    ) as TimeWindowHabit;
  }

  @override
  TimeWindowHabit copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? lastCompleted,
    int? currentStreak,
    int? dailyCompletionCount,
    DateTime? lastCompletionCountReset,
    TimeOfDay? windowStartTime,
    TimeOfDay? windowEndTime,
    List<int>? availableDays,
  }) {
    return TimeWindowHabit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      dailyCompletionCount: dailyCompletionCount ?? this.dailyCompletionCount,
      lastCompletionCountReset: lastCompletionCountReset ?? this.lastCompletionCountReset,
      windowStartTime: windowStartTime ?? this.windowStartTime,
      windowEndTime: windowEndTime ?? this.windowEndTime,
      availableDays: availableDays ?? this.availableDays,
    );
  }

  /// Factory constructor to create a new TimeWindowHabit
  factory TimeWindowHabit.create({
    required String name,
    required String description,
    required TimeOfDay windowStartTime,
    required TimeOfDay windowEndTime,
    required List<int> availableDays,
  }) {
    return TimeWindowHabit(
      id: BaseHabit.generateId(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
      windowStartTime: windowStartTime,
      windowEndTime: windowEndTime,
      availableDays: List.from(availableDays),
    );
  }
}