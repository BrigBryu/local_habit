import 'base_habit.dart';
import 'basic_habit.dart';
import 'habit_stack.dart';
// TODO(bridger): Re-enable when time-based habits are ready
// import 'alarm_habit.dart';
// import 'timed_session_habit.dart';
// import 'time_window_habit.dart';
// TODO(bridger): TimeOfDay import disabled to resolve conflicts
// import 'time_of_day.dart';

/// Enum for different habit types
enum HabitType {
  basic('Basic Habit'),
  stack('Habit Stack');
  // TODO(bridger): Re-enable when time-based habits are ready
  // alarmHabit('Alarm Habit'),
  // timedSession('Timed Session'),
  // timeWindow('Time Window');

  const HabitType(this.displayName);
  final String displayName;
}

/// Factory for creating different types of habits
class HabitFactory {
  /// Create a basic habit
  static BasicHabit createBasic({
    required String name,
    required String description,
  }) {
    return BasicHabit.create(
      name: name,
      description: description,
    );
  }

  /// Create a habit stack
  static HabitStack createStack({
    required String name,
    required String description,
    required String stackedOnHabitId,
  }) {
    return HabitStack.create(
      name: name,
      description: description,
      stackedOnHabitId: stackedOnHabitId,
    );
  }

  /// TODO(bridger): Create an alarm habit (DISABLED - time-based habits temporarily disabled)
  static Never createAlarm({
    required String name,
    required String description,
    required String stackedOnHabitId,
    // required TimeOfDay alarmTime,
    required int windowMinutes,
  }) {
    throw UnimplementedError('AlarmHabit is temporarily disabled');
  }

  /// TODO(bridger): Create a timed session habit (DISABLED - time-based habits temporarily disabled)
  static Never createTimedSession({
    required String name,
    required String description,
    required int sessionMinutes,
    int graceMinutes = 15,
  }) {
    throw UnimplementedError('TimedSessionHabit is temporarily disabled');
  }

  /// TODO(bridger): Create a time window habit (DISABLED - time-based habits temporarily disabled)
  static Never createTimeWindow({
    required String name,
    required String description,
    // required TimeOfDay windowStartTime,
    // required TimeOfDay windowEndTime,
    required List<int> availableDays,
  }) {
    throw UnimplementedError('TimeWindowHabit is temporarily disabled');
  }

  /// Create a habit from parameters (for backward compatibility)
  static BaseHabit createFromType({
    required HabitType type,
    required String name,
    required String description,
    String? stackedOnHabitId,
    // TimeOfDay? alarmTime,
    int? windowMinutes,
    int? sessionMinutes,
    int? graceMinutes,
    // TimeOfDay? windowStartTime,
    // TimeOfDay? windowEndTime,
    List<int>? availableDays,
  }) {
    switch (type) {
      case HabitType.basic:
        return createBasic(name: name, description: description);

      case HabitType.stack:
        if (stackedOnHabitId == null) {
          throw ArgumentError('Habit stack requires stackedOnHabitId');
        }
        return createStack(
          name: name,
          description: description,
          stackedOnHabitId: stackedOnHabitId,
        );

      // TODO(bridger): Disabled time-based habit types
      // case HabitType.alarmHabit:
      //   if (stackedOnHabitId == null || alarmTime == null || windowMinutes == null) {
      //     throw ArgumentError('Alarm habit requires stackedOnHabitId, alarmTime, and windowMinutes');
      //   }
      //   return createAlarm(
      //     name: name,
      //     description: description,
      //     stackedOnHabitId: stackedOnHabitId,
      //     alarmTime: alarmTime,
      //     windowMinutes: windowMinutes,
      //   );
      //
      // case HabitType.timedSession:
      //   if (sessionMinutes == null) {
      //     throw ArgumentError('Timed session requires sessionMinutes');
      //   }
      //   return createTimedSession(
      //     name: name,
      //     description: description,
      //     sessionMinutes: sessionMinutes,
      //     graceMinutes: graceMinutes ?? 15,
      //   );
      //
      // case HabitType.timeWindow:
      //   if (windowStartTime == null || windowEndTime == null || availableDays == null) {
      //     throw ArgumentError('Time window requires windowStartTime, windowEndTime, and availableDays');
      //   }
      //   return createTimeWindow(
      //     name: name,
      //     description: description,
      //     windowStartTime: windowStartTime,
      //     windowEndTime: windowEndTime,
      //     availableDays: availableDays,
      //   );
    }
  }
}
