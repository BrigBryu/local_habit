
import '../services/time_service.dart';
import 'base_habit.dart';

/// Alarm-based habit with completion window
class AlarmHabit extends BaseHabit {
  final String stackedOnHabitId;
  final TimeOfDay alarmTime;
  final int windowMinutes; // Minutes after alarm to complete
  final DateTime? lastAlarmTriggered;

  const AlarmHabit({
    required super.id,
    required super.name,
    required super.description,
    required super.createdAt,
    required this.stackedOnHabitId,
    required this.alarmTime,
    required this.windowMinutes,
    this.lastAlarmTriggered,
    super.lastCompleted,
    super.currentStreak = 0,
    super.dailyCompletionCount = 0,
    super.lastCompletionCountReset,
  });

  @override
  IconData get icon => Icons.alarm;

  @override
  String get typeName => 'Alarm Habit';

  @override
  String get displayName => '$name ⏰${_formatTime(alarmTime)}';

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  bool canComplete(TimeService timeService) {
    if (isCompletedToday(timeService)) return false;
    
    final now = timeService.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    
    // Check if we're after the alarm time
    final alarmMinutes = alarmTime.hour * 60 + alarmTime.minute;
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    
    if (currentMinutes < alarmMinutes) {
      return false; // Before alarm time
    }
    
    // Check if we're within the completion window
    final minutesSinceAlarm = currentMinutes - alarmMinutes;
    return minutesSinceAlarm <= windowMinutes;
  }

  @override
  String getStatusText(TimeService timeService) {
    if (isCompletedToday(timeService)) {
      return 'Alarm completed! 🎉';
    }
    
    final now = timeService.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final alarmMinutes = alarmTime.hour * 60 + alarmTime.minute;
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    
    if (currentMinutes < alarmMinutes) {
      final minutesUntilAlarm = alarmMinutes - currentMinutes;
      final hours = minutesUntilAlarm ~/ 60;
      final minutes = minutesUntilAlarm % 60;
      return '⏰ Alarm at ${_formatTime(alarmTime)}';
    }
    
    final minutesSinceAlarm = currentMinutes - alarmMinutes;
    if (minutesSinceAlarm <= windowMinutes) {
      final remainingMinutes = windowMinutes - minutesSinceAlarm;
      final hours = remainingMinutes ~/ 60;
      final minutes = remainingMinutes % 60;
      return '⏳ ${hours}h ${minutes}m remaining';
    }
    
    return '❌ Window expired';
  }

  /// Get time until alarm or time remaining in window
  String getTimeInfo(TimeService timeService) {
    final now = timeService.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final alarmMinutes = alarmTime.hour * 60 + alarmTime.minute;
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    
    if (currentMinutes < alarmMinutes) {
      // Before alarm
      final minutesUntilAlarm = alarmMinutes - currentMinutes;
      final hours = minutesUntilAlarm ~/ 60;
      final minutes = minutesUntilAlarm % 60;
      return 'Alarm in ${hours}h ${minutes}m';
    } else {
      // After alarm
      final minutesSinceAlarm = currentMinutes - alarmMinutes;
      if (minutesSinceAlarm <= windowMinutes) {
        final remainingMinutes = windowMinutes - minutesSinceAlarm;
        final hours = remainingMinutes ~/ 60;
        final minutes = remainingMinutes % 60;
        return '${hours}h ${minutes}m remaining';
      } else {
        return 'Window expired';
      }
    }
  }

  @override
  AlarmHabit complete() {
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
    ) as AlarmHabit;
  }

  @override
  AlarmHabit copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? lastCompleted,
    int? currentStreak,
    int? dailyCompletionCount,
    DateTime? lastCompletionCountReset,
    String? stackedOnHabitId,
    TimeOfDay? alarmTime,
    int? windowMinutes,
    DateTime? lastAlarmTriggered,
  }) {
    return AlarmHabit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      dailyCompletionCount: dailyCompletionCount ?? this.dailyCompletionCount,
      lastCompletionCountReset: lastCompletionCountReset ?? this.lastCompletionCountReset,
      stackedOnHabitId: stackedOnHabitId ?? this.stackedOnHabitId,
      alarmTime: alarmTime ?? this.alarmTime,
      windowMinutes: windowMinutes ?? this.windowMinutes,
      lastAlarmTriggered: lastAlarmTriggered ?? this.lastAlarmTriggered,
    );
  }

  /// Factory constructor to create a new AlarmHabit
  factory AlarmHabit.create({
    required String name,
    required String description,
    required String stackedOnHabitId,
    required TimeOfDay alarmTime,
    required int windowMinutes,
  }) {
    return AlarmHabit(
      id: BaseHabit.generateId(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
      stackedOnHabitId: stackedOnHabitId,
      alarmTime: alarmTime,
      windowMinutes: windowMinutes,
    );
  }
}