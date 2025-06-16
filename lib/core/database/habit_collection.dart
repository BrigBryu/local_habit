import 'package:isar/isar.dart';
import 'package:domain/domain.dart';

part 'habit_collection.g.dart';

@Collection()
class HabitCollection {
  Id isarId = Isar.autoIncrement;

  late String id;
  late String name;
  late String description;
  late String userId; // Owner of this habit

  @Enumerated(EnumType.name)
  late HabitType type;

  // Stack/Bundle relationships
  String? stackedOnHabitId;
  List<String>? bundleChildIds;
  String? parentBundleId;

  // Timing
  int? timeoutMinutes;
  List<int>? availableDays;

  // Timestamps
  late DateTime createdAt;
  DateTime? lastCompleted;
  DateTime? lastAlarmTriggered;
  DateTime? sessionStartTime;
  DateTime? lastSessionStarted;

  // Daily counters
  bool sessionCompletedToday = false;
  int dailyCompletionCount = 0;
  DateTime? lastCompletionCountReset;
  int dailyFailureCount = 0;
  DateTime? lastFailureCountReset;

  // Avoidance specific
  bool avoidanceSuccessToday = false;

  // Streaks
  int currentStreak = 0;

  HabitCollection();

  factory HabitCollection.fromDomain(Habit habit, String userId) {
    return HabitCollection()
      ..id = habit.id
      ..name = habit.name
      ..description = habit.description
      ..userId = userId
      ..type = habit.type
      ..stackedOnHabitId = habit.stackedOnHabitId
      ..bundleChildIds = habit.bundleChildIds
      ..parentBundleId = habit.parentBundleId
      ..timeoutMinutes = habit.timeoutMinutes
      ..availableDays = habit.availableDays
      ..createdAt = habit.createdAt
      ..lastCompleted = habit.lastCompleted
      ..lastAlarmTriggered = habit.lastAlarmTriggered
      ..sessionStartTime = habit.sessionStartTime
      ..lastSessionStarted = habit.lastSessionStarted
      ..sessionCompletedToday = habit.sessionCompletedToday
      ..dailyCompletionCount = habit.dailyCompletionCount
      ..lastCompletionCountReset = habit.lastCompletionCountReset
      ..dailyFailureCount = habit.dailyFailureCount
      ..lastFailureCountReset = habit.lastFailureCountReset
      ..avoidanceSuccessToday = habit.avoidanceSuccessToday
      ..currentStreak = habit.currentStreak;
  }

  Habit toDomain() {
    return Habit(
      id: id,
      name: name,
      description: description,
      type: type,
      stackedOnHabitId: stackedOnHabitId,
      bundleChildIds: bundleChildIds,
      parentBundleId: parentBundleId,
      timeoutMinutes: timeoutMinutes,
      availableDays: availableDays,
      createdAt: createdAt,
      lastCompleted: lastCompleted,
      lastAlarmTriggered: lastAlarmTriggered,
      sessionStartTime: sessionStartTime,
      lastSessionStarted: lastSessionStarted,
      sessionCompletedToday: sessionCompletedToday,
      dailyCompletionCount: dailyCompletionCount,
      lastCompletionCountReset: lastCompletionCountReset,
      dailyFailureCount: dailyFailureCount,
      lastFailureCountReset: lastFailureCountReset,
      avoidanceSuccessToday: avoidanceSuccessToday,
      currentStreak: currentStreak,
    );
  }
}

// TODO: Add proper indexes when needed
