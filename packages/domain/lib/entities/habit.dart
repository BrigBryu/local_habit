import '../services/time_service.dart';
// TODO(bridger): TimeOfDay import disabled to resolve conflicts
// import 'time_of_day.dart';

/// Enum for different habit types
enum HabitType {
  basic('Basic Habit'),
  avoidance('Avoidance Habit'),
  stack('Habit Stack'),
  bundle('Bundle Habit'),
  interval('Interval Habit'),
  weekly('Weekly Habit');
  // TODO(bridger): Re-enable when time-based habits are ready
  // alarmHabit('Alarm Habit'),
  // timedSession('Timed Session'),
  // timeWindow('Time Window'),
  // dailyTimeWindow('Daily Time Window');

  const HabitType(this.displayName);
  final String displayName;
}

/// Domain entity for a basic habit following clean architecture
class Habit {
  final String id;
  final String name;
  final String description;
  final HabitType type;
  final String? stackedOnHabitId; // For habit stacks (legacy)
  final List<String>?
      bundleChildIds; // For bundle habits - list of child habit IDs
  final String? parentBundleId; // For habits that belong to a bundle
  final String? parentStackId; // For habits that belong to a stack
  // New stack fields per spec
  final List<String>?
      stackChildIds; // For stack habits - ordered list of child habit IDs
  final int currentChildIndex; // Current child index for stack progress
  // TODO(bridger): Time-based fields disabled temporarily due to TimeOfDay conflicts
  // final TimeOfDay? alarmTime; // For timed stacks (DISABLED)
  final int?
      timeoutMinutes; // For timed stacks/sessions - minutes after alarm/start (DISABLED)
  // final TimeOfDay? windowStartTime; // For time windows - start of availability (DISABLED)
  // final TimeOfDay? windowEndTime; // For time windows - end of availability (DISABLED)
  final List<int>? availableDays; // For time windows - days of week (DISABLED)
  final DateTime createdAt;
  final DateTime? lastCompleted;
  // TODO(bridger): Time-based session fields disabled temporarily
  final DateTime?
      lastAlarmTriggered; // Track when alarm was last triggered (DISABLED)
  final DateTime?
      sessionStartTime; // For timed sessions - when session started (DISABLED)
  final DateTime?
      lastSessionStarted; // For timed sessions - when timer was last started (DISABLED)
  final bool
      sessionCompletedToday; // For timed sessions - if timer completed today (DISABLED)
  final int dailyCompletionCount; // How many times completed today
  final DateTime? lastCompletionCountReset; // When daily count was last reset
  final int
      dailyFailureCount; // For avoidance habits - how many times failed today
  final DateTime?
      lastFailureCountReset; // When daily failure count was last reset
  final bool
      avoidanceSuccessToday; // For avoidance habits - if successfully avoided today
  final int currentStreak;
  
  // Occasional habit fields
  final int? intervalDays; // For interval habits - days between completions
  final int? weekdayMask; // For weekly habits - 7-bit mask (bit 0=Sunday, bit 1=Monday, etc.)
  final DateTime? lastCompletionDate; // For interval/weekly habits - date of last completion
  
  // UI display fields
  final int displayOrder; // For drag-to-reorder functionality

  const Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.stackedOnHabitId,
    this.bundleChildIds,
    this.parentBundleId,
    this.parentStackId,
    this.stackChildIds,
    this.currentChildIndex = 0,
    // TODO(bridger): TimeOfDay fields disabled
    // this.alarmTime,
    this.timeoutMinutes,
    // this.windowStartTime,
    // this.windowEndTime,
    this.availableDays,
    required this.createdAt,
    this.lastCompleted,
    this.lastAlarmTriggered,
    this.sessionStartTime,
    this.lastSessionStarted,
    this.sessionCompletedToday = false,
    this.dailyCompletionCount = 0,
    this.lastCompletionCountReset,
    this.dailyFailureCount = 0,
    this.lastFailureCountReset,
    this.avoidanceSuccessToday = false,
    this.currentStreak = 0,
    this.intervalDays,
    this.weekdayMask,
    this.lastCompletionDate,
    this.displayOrder = 999999,
  });

  /// Factory for creating new habit
  factory Habit.create({
    required String name,
    required String description,
    required HabitType type,
    String? stackedOnHabitId,
    List<String>? bundleChildIds,
    String? parentBundleId,
    String? parentStackId,
    List<String>? stackChildIds,
    int currentChildIndex = 0,
    // TODO(bridger): TimeOfDay parameters disabled
    // TimeOfDay? alarmTime,
    int? timeoutMinutes,
    // TimeOfDay? windowStartTime,
    // TimeOfDay? windowEndTime,
    List<int>? availableDays,
    int? intervalDays,
    int? weekdayMask,
    int displayOrder = 999999,
  }) {
    return Habit(
      id: _generateId(),
      name: name.trim(),
      description: description.trim(),
      type: type,
      stackedOnHabitId: stackedOnHabitId,
      bundleChildIds: bundleChildIds,
      parentBundleId: parentBundleId,
      parentStackId: parentStackId,
      stackChildIds: stackChildIds,
      currentChildIndex: currentChildIndex,
      // TODO(bridger): TimeOfDay fields disabled in factory
      // alarmTime: alarmTime,
      timeoutMinutes: timeoutMinutes,
      // windowStartTime: windowStartTime,
      // windowEndTime: windowEndTime,
      availableDays: availableDays,
      intervalDays: intervalDays,
      weekdayMask: weekdayMask,
      displayOrder: displayOrder,
      createdAt: TimeService().now(),
    );
  }

  /// Complete this habit (returns new instance with updated streak and completion count)
  Habit complete() {
    final timeService = TimeService();
    final now = timeService.now();

    // For non-basic and non-avoidance habits, keep the original once-per-day logic
    if (type != HabitType.basic &&
        type != HabitType.avoidance &&
        _isCompletedToday()) {
      return this; // Already completed today for non-basic habits
    }

    // TODO(bridger): Timed session logic disabled
    // For timed sessions, can only complete if session was completed today
    // if (type == HabitType.timedSession && !sessionCompletedToday) {
    //   return this; // Cannot complete until timer has finished
    // }

    // Handle different completion logic for different habit types
    int newDailyCount = dailyCompletionCount;
    int newFailureCount = dailyFailureCount;
    bool newAvoidanceSuccess = avoidanceSuccessToday;

    if (type == HabitType.avoidance) {
      // For avoidance habits, "completion" means marking the day as successful
      newAvoidanceSuccess = true;
      // Reset failure count if it's a new day
      newFailureCount = _shouldResetFailureCount(now) ? 0 : dailyFailureCount;
    } else {
      // For other habits, increment completion count
      newDailyCount =
          _shouldResetDailyCount(now) ? 1 : dailyCompletionCount + 1;
    }

    // For basic/avoidance habits, only update streak on first completion of the day
    final shouldUpdateStreak =
        (type == HabitType.basic && newDailyCount == 1) ||
            (type == HabitType.avoidance && !avoidanceSuccessToday) ||
            (type != HabitType.basic && type != HabitType.avoidance);
    final newStreak =
        shouldUpdateStreak ? _calculateNewStreak(now) : currentStreak;

    return Habit(
      id: id,
      name: name,
      description: description,
      type: type,
      stackedOnHabitId: stackedOnHabitId,
      bundleChildIds: bundleChildIds,
      parentBundleId: parentBundleId,
      stackChildIds: stackChildIds,
      currentChildIndex: currentChildIndex,
      // TODO(bridger): TimeOfDay fields disabled in complete()
      // alarmTime: alarmTime,
      timeoutMinutes: timeoutMinutes,
      // windowStartTime: windowStartTime,
      // windowEndTime: windowEndTime,
      availableDays: availableDays,
      createdAt: createdAt,
      lastCompleted: now,
      lastAlarmTriggered: lastAlarmTriggered,
      sessionStartTime: sessionStartTime,
      lastSessionStarted: lastSessionStarted,
      sessionCompletedToday: sessionCompletedToday,
      dailyCompletionCount: newDailyCount,
      lastCompletionCountReset:
          _shouldResetDailyCount(now) ? now : lastCompletionCountReset,
      dailyFailureCount: newFailureCount,
      lastFailureCountReset:
          _shouldResetFailureCount(now) ? now : lastFailureCountReset,
      avoidanceSuccessToday: newAvoidanceSuccess,
      currentStreak: newStreak,
      intervalDays: intervalDays,
      weekdayMask: weekdayMask,
      lastCompletionDate: (type == HabitType.interval || type == HabitType.weekly) 
          ? DateTime(now.year, now.month, now.day) : lastCompletionDate,
      displayOrder: displayOrder,
    );
  }

  /// Check if daily completion count should be reset
  bool _shouldResetDailyCount(DateTime now) {
    if (lastCompletionCountReset == null) return true;

    final timeService = TimeService();
    return !timeService.isSameDay(lastCompletionCountReset!, now);
  }

  /// Check if daily failure count should be reset
  bool _shouldResetFailureCount(DateTime now) {
    if (lastFailureCountReset == null) return true;

    final timeService = TimeService();
    return !timeService.isSameDay(lastFailureCountReset!, now);
  }

  /// Record a failure for avoidance habits
  Habit recordFailure() {
    if (type != HabitType.avoidance) return this;

    final timeService = TimeService();
    final now = timeService.now();

    // Reset failure count if it's a new day
    final newFailureCount =
        _shouldResetFailureCount(now) ? 1 : dailyFailureCount + 1;

    // Break streak on first failure of the day, but never go below 0
    final newStreak = dailyFailureCount == 0 ? 0 : currentStreak;

    return Habit(
      id: id,
      name: name,
      description: description,
      type: type,
      stackedOnHabitId: stackedOnHabitId,
      bundleChildIds: bundleChildIds,
      parentBundleId: parentBundleId,
      stackChildIds: stackChildIds,
      currentChildIndex: currentChildIndex,
      // TODO(bridger): TimeOfDay fields disabled in recordFailure()
      // alarmTime: alarmTime,
      timeoutMinutes: timeoutMinutes,
      // windowStartTime: windowStartTime,
      // windowEndTime: windowEndTime,
      availableDays: availableDays,
      createdAt: createdAt,
      lastCompleted: lastCompleted,
      lastAlarmTriggered: lastAlarmTriggered,
      sessionStartTime: sessionStartTime,
      lastSessionStarted: lastSessionStarted,
      sessionCompletedToday: sessionCompletedToday,
      dailyCompletionCount: dailyCompletionCount,
      lastCompletionCountReset: lastCompletionCountReset,
      dailyFailureCount: newFailureCount,
      lastFailureCountReset:
          _shouldResetFailureCount(now) ? now : lastFailureCountReset,
      avoidanceSuccessToday: false, // Failed today
      currentStreak: newStreak,
      intervalDays: intervalDays,
      weekdayMask: weekdayMask,
      lastCompletionDate: lastCompletionDate,
      displayOrder: displayOrder,
    );
  }


  /// Get completion count for today
  int get todayCompletionCount => dailyCompletionCount;

  /// TODO(bridger): Start a timed session (DISABLED - time-based habits temporarily disabled)
  // Habit startTimedSession() {
  //   if (type != HabitType.timedSession) return this;
  //
  //   final timeService = TimeService();
  //   final now = timeService.now();
  //
  //   // Check if already started today
  //   if (lastSessionStarted != null && timeService.isSameDay(lastSessionStarted!, now)) {
  //     return this; // Already started today
  //   }
  //
  //   return Habit(
  //     id: id,
  //     name: name,
  //     description: description,
  //     type: type,
  //     stackedOnHabitId: stackedOnHabitId,
  //     bundleChildIds: bundleChildIds,
  //     parentBundleId: parentBundleId,
  //     alarmTime: alarmTime,
  //     timeoutMinutes: timeoutMinutes,
  //     windowStartTime: windowStartTime,
  //     windowEndTime: windowEndTime,
  //     availableDays: availableDays,
  //     createdAt: createdAt,
  //     lastCompleted: lastCompleted,
  //     lastAlarmTriggered: lastAlarmTriggered,
  //     sessionStartTime: now,
  //     lastSessionStarted: now,
  //     sessionCompletedToday: false, // Reset until timer completes
  //     dailyCompletionCount: dailyCompletionCount,
  //     lastCompletionCountReset: lastCompletionCountReset,
  //     dailyFailureCount: dailyFailureCount,
  //     lastFailureCountReset: lastFailureCountReset,
  //     avoidanceSuccessToday: avoidanceSuccessToday,
  //     currentStreak: currentStreak,
  //   );
  // }

  /// TODO(bridger): Mark timed session as completed (DISABLED - time-based habits temporarily disabled)
  // Habit completeTimedSession() {
  //   if (type != HabitType.timedSession) return this;
  //
  //   return Habit(
  //     id: id,
  //     name: name,
  //     description: description,
  //     type: type,
  //     stackedOnHabitId: stackedOnHabitId,
  //     bundleChildIds: bundleChildIds,
  //     parentBundleId: parentBundleId,
  //     alarmTime: alarmTime,
  //     timeoutMinutes: timeoutMinutes,
  //     windowStartTime: windowStartTime,
  //     windowEndTime: windowEndTime,
  //     availableDays: availableDays,
  //     createdAt: createdAt,
  //     lastCompleted: lastCompleted,
  //     lastAlarmTriggered: lastAlarmTriggered,
  //     sessionStartTime: sessionStartTime,
  //     lastSessionStarted: lastSessionStarted,
  //     sessionCompletedToday: true,
  //     dailyCompletionCount: dailyCompletionCount,
  //     lastCompletionCountReset: lastCompletionCountReset,
  //     dailyFailureCount: dailyFailureCount,
  //     lastFailureCountReset: lastFailureCountReset,
  //     avoidanceSuccessToday: avoidanceSuccessToday,
  //     currentStreak: currentStreak,
  //   );
  // }

  /// TODO(bridger): Check if timed session has been started today (DISABLED - time-based habits temporarily disabled)
  // bool hasStartedSessionToday() {
  //   if (type != HabitType.timedSession || lastSessionStarted == null) return false;
  //
  //   final timeService = TimeService();
  //   return timeService.isSameDay(lastSessionStarted!, timeService.now());
  // }

  /// TODO(bridger): Check if timed session is ready to be checked off (DISABLED - time-based habits temporarily disabled)
  // bool canCompleteTimedSession() {
  //   return type == HabitType.timedSession && sessionCompletedToday && !_isCompletedToday();
  // }

  /// Check if this is a bundle habit
  bool get isBundle => type == HabitType.bundle;

  /// Check if this habit belongs to a bundle
  bool get isInBundle => parentBundleId != null;

  /// Get child habit IDs for bundle habits
  List<String> get childHabitIds => bundleChildIds ?? [];

  /// Create a new bundle habit
  factory Habit.createBundle({
    required String name,
    required String description,
    required List<String> childIds,
  }) {
    if (childIds.length < 2) {
      throw ArgumentError('Bundle must contain at least 2 child habits');
    }

    return Habit.create(
      name: name,
      description: description,
      type: HabitType.bundle,
      bundleChildIds: List.from(childIds),
    );
  }

  /// Check if bundle can be completed (has incomplete children today)
  bool canCompleteBundle() {
    return type == HabitType.bundle && !_isCompletedToday();
  }

  bool _isCompletedToday() {
    if (lastCompleted == null) return false;

    final timeService = TimeService();
    return timeService.isSameDay(lastCompleted!, timeService.now());
  }

  int _calculateNewStreak(DateTime completionTime) {
    if (lastCompleted == null) {
      print('🔥 First completion - streak starts at 1');
      return 1;
    }

    final timeService = TimeService();
    final daysDifference =
        timeService.daysBetween(lastCompleted!, completionTime);
    print(
        '🔥 Days since last completion: $daysDifference, current streak: $currentStreak');

    if (daysDifference == 1) {
      // Consecutive day - extend streak
      final newStreak = currentStreak + 1;
      print('🔥 Consecutive day! Streak: $currentStreak → $newStreak');
      return newStreak;
    } else if (daysDifference == 0) {
      // Same day - this shouldn't happen due to _isCompletedToday check
      print('🔥 Same day completion (shouldn\'t happen)');
      return currentStreak;
    } else {
      // Gap in days - restart streak
      print(
          '🔥 Gap of $daysDifference days - streak resets: $currentStreak → 1');
      return 1;
    }
  }

  /// Get display name with type info
  String get displayName {
    if (type == HabitType.stack && stackedOnHabitId != null) {
      return '$name 📚'; // Stack emoji
    } else if (type == HabitType.bundle) {
      return '$name 📦'; // Bundle emoji
    } else if (type == HabitType.avoidance) {
      return '$name 🚫'; // Avoidance emoji
    } else if (type == HabitType.interval) {
      return '$name ⟳'; // Interval rotation emoji
    } else if (type == HabitType.weekly) {
      return '$name 📅'; // Weekly calendar emoji
    }
    // TODO(bridger): Time-based display names disabled
    // else if (type == HabitType.alarmHabit) {
    //   final timeStr = alarmTime != null ? '${alarmTime!.format24Hour()}' : '??:??';
    //   return '$name ⏰$timeStr'; // Alarm emoji with time
    // } else if (type == HabitType.timedSession) {
    //   final duration = timeoutMinutes ?? 0;
    //   return '$name ⏱️${duration}m'; // Session timer with duration
    // } else if (type == HabitType.timeWindow) {
    //   final startStr = windowStartTime?.format24Hour() ?? '??:??';
    //   final endStr = windowEndTime?.format24Hour() ?? '??:??';
    //   return '$name 🕐$startStr-$endStr'; // Window emoji with time range
    // } else if (type == HabitType.dailyTimeWindow) {
    //   final startStr = windowStartTime?.format24Hour() ?? '??:??';
    //   final endStr = windowEndTime?.format24Hour() ?? '??:??';
    //   return '$name 📅$startStr-$endStr'; // Daily window with calendar emoji
    // }
    return name;
  }

  /// Convert habit to JSON for sync queue
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type.name,
        'stackedOnHabitId': stackedOnHabitId,
        'bundleChildIds': bundleChildIds,
        'parentBundleId': parentBundleId,
        'stackChildIds': stackChildIds,
        'currentChildIndex': currentChildIndex,
        'timeoutMinutes': timeoutMinutes,
        'availableDays': availableDays,
        'createdAt': createdAt.toIso8601String(),
        'lastCompleted': lastCompleted?.toIso8601String(),
        'lastAlarmTriggered': lastAlarmTriggered?.toIso8601String(),
        'sessionStartTime': sessionStartTime?.toIso8601String(),
        'lastSessionStarted': lastSessionStarted?.toIso8601String(),
        'sessionCompletedToday': sessionCompletedToday,
        'dailyCompletionCount': dailyCompletionCount,
        'lastCompletionCountReset': lastCompletionCountReset?.toIso8601String(),
        'dailyFailureCount': dailyFailureCount,
        'lastFailureCountReset': lastFailureCountReset?.toIso8601String(),
        'avoidanceSuccessToday': avoidanceSuccessToday,
        'currentStreak': currentStreak,
        'intervalDays': intervalDays,
        'weekdayMask': weekdayMask,
        'lastCompletionDate': lastCompletionDate?.toIso8601String(),
        'displayOrder': displayOrder,
      };

  /// Create habit from JSON for sync queue
  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        type: HabitType.values.firstWhere((e) => e.name == json['type']),
        stackedOnHabitId: json['stackedOnHabitId'] as String?,
        bundleChildIds:
            (json['bundleChildIds'] as List<dynamic>?)?.cast<String>(),
        parentBundleId: json['parentBundleId'] as String?,
        stackChildIds:
            (json['stackChildIds'] as List<dynamic>?)?.cast<String>(),
        currentChildIndex: json['currentChildIndex'] as int? ?? 0,
        timeoutMinutes: json['timeoutMinutes'] as int?,
        availableDays: (json['availableDays'] as List<dynamic>?)?.cast<int>(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastCompleted: json['lastCompleted'] != null
            ? DateTime.parse(json['lastCompleted'] as String)
            : null,
        lastAlarmTriggered: json['lastAlarmTriggered'] != null
            ? DateTime.parse(json['lastAlarmTriggered'] as String)
            : null,
        sessionStartTime: json['sessionStartTime'] != null
            ? DateTime.parse(json['sessionStartTime'] as String)
            : null,
        lastSessionStarted: json['lastSessionStarted'] != null
            ? DateTime.parse(json['lastSessionStarted'] as String)
            : null,
        sessionCompletedToday: json['sessionCompletedToday'] as bool? ?? false,
        dailyCompletionCount: json['dailyCompletionCount'] as int? ?? 0,
        lastCompletionCountReset: json['lastCompletionCountReset'] != null
            ? DateTime.parse(json['lastCompletionCountReset'] as String)
            : null,
        dailyFailureCount: json['dailyFailureCount'] as int? ?? 0,
        lastFailureCountReset: json['lastFailureCountReset'] != null
            ? DateTime.parse(json['lastFailureCountReset'] as String)
            : null,
        avoidanceSuccessToday: json['avoidanceSuccessToday'] as bool? ?? false,
        currentStreak: json['currentStreak'] as int? ?? 0,
        intervalDays: json['intervalDays'] as int?,
        weekdayMask: json['weekdayMask'] as int?,
        lastCompletionDate: json['lastCompletionDate'] != null
            ? DateTime.parse(json['lastCompletionDate'] as String)
            : null,
        displayOrder: json['displayOrder'] as int? ?? 999999,
      );

  @override
  String toString() =>
      'Habit(id: $id, name: $name, type: ${type.displayName}, streak: $currentStreak)';
}

/// Simple ID generator for habits
String _generateId() {
  final timestamp = TimeService().now().millisecondsSinceEpoch;
  final random = timestamp % 100000;
  return 'habit_${timestamp}_$random';
}

/// Get the current streak for a habit (considering missed days)
int getCurrentStreak(Habit habit) {
  if (habit.lastCompleted == null) return 0;

  final timeService = TimeService();
  final daysSinceLastCompleted = timeService.daysBetween(
    habit.lastCompleted!,
    timeService.now(),
  );

  // If more than 1 day has passed without completion, streak is broken
  if (daysSinceLastCompleted > 1) {
    print(
        '💔 Streak broken for ${habit.name}: $daysSinceLastCompleted days since last completion');
    return 0;
  }

  // Otherwise, return the stored streak
  return habit.currentStreak;
}

/// Check if a habit should show as completed today
bool isHabitCompletedToday(Habit habit) {
  if (habit.lastCompleted == null) return false;

  final timeService = TimeService();
  return timeService.isSameDay(habit.lastCompleted!, timeService.now());
}

/// TODO(bridger): Extension to format TimeOfDay as 24-hour string (DISABLED - TimeOfDay conflicts)
// extension TimeOfDayExtension on TimeOfDay {
//   String format24Hour() {
//     final h = hour.toString().padLeft(2, '0');
//     final m = minute.toString().padLeft(2, '0');
//     return '$h:$m';
//   }
// }
