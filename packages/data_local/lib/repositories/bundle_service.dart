import 'package:domain/entities/habit.dart';
import 'package:domain/services/time_service.dart';

/// Service to manage bundle habits and their children
class BundleService {
  static final BundleService _instance = BundleService._internal();
  factory BundleService() => _instance;
  BundleService._internal();

  /// Get bundle progress (completed/total children)
  BundleProgress getBundleProgress(Habit bundle, List<Habit> allHabits) {
    if (bundle.type != HabitType.bundle || bundle.bundleChildIds == null) {
      return BundleProgress(completed: 0, total: 0);
    }

    final children = getChildHabits(bundle, allHabits);
    final completedCount =
        children.where((child) => isHabitCompletedToday(child)).length;

    return BundleProgress(completed: completedCount, total: children.length);
  }

  /// Get child habits for a bundle (preserves order from bundleChildIds)
  List<Habit> getChildHabits(Habit bundle, List<Habit> allHabits) {
    if (bundle.type != HabitType.bundle || bundle.bundleChildIds == null) {
      return [];
    }

    // Create a map for O(1) lookup
    final habitMap = {for (final habit in allHabits) habit.id: habit};

    // Return children in the order specified by bundleChildIds
    return bundle.bundleChildIds!
        .map((id) => habitMap[id])
        .where((habit) => habit != null)
        .cast<Habit>()
        .toList();
  }

  /// Get incomplete child habits for a bundle
  List<Habit> getIncompleteChildHabits(Habit bundle, List<Habit> allHabits) {
    if (bundle.type != HabitType.bundle || bundle.bundleChildIds == null) {
      return [];
    }

    return allHabits
        .where((habit) =>
            bundle.bundleChildIds!.contains(habit.id) &&
            !isHabitCompletedToday(habit))
        .toList();
  }

  /// Check if a bundle is fully completed
  bool isBundleCompleted(Habit bundle, List<Habit> allHabits) {
    final progress = getBundleProgress(bundle, allHabits);
    return progress.completed == progress.total && progress.total > 0;
  }

  /// Complete all remaining children in a bundle
  BundleCompletionResult completeBundle(Habit bundle, List<Habit> allHabits) {
    final incompleteChildren = getIncompleteChildHabits(bundle, allHabits);
    final updatedHabits = <Habit>[];

    for (final child in incompleteChildren) {
      // Only complete children that can be completed
      if (_canCompleteChild(child)) {
        updatedHabits.add(child.complete());
      }
    }

    // Calculate combo bonus: 1 XP for every 2 habits in the bundle
    final comboBonus = (bundle.bundleChildIds?.length ?? 0) ~/ 2;

    return BundleCompletionResult(
      completedHabits: updatedHabits,
      comboBonus: comboBonus,
    );
  }

  /// Check if a child habit can be completed
  bool _canCompleteChild(Habit child) {
    switch (child.type) {
      case HabitType.basic:
      case HabitType.avoidance:
        return true; // Basic and avoidance habits can always be completed

      case HabitType.stack:
        return true; // Habit stacks can be completed

      // TODO(bridger): Disabled time-based habit types
      // case HabitType.timedSession:
      //   return child.sessionCompletedToday; // Only if timer finished
      //
      // case HabitType.timeWindow:
      // case HabitType.dailyTimeWindow:
      //   // Would need access to timed habit service for validation
      //   return true; // For now, allow completion
      //
      // case HabitType.alarmHabit:
      //   // Would need access to timed habit service for validation
      //   return true; // For now, allow completion

      case HabitType.bundle:
        return false; // Cannot nest bundles

      default:
        return true;
    }
  }

  /// Validate bundle creation (no nested bundles, single level depth)
  String? validateBundleCreation(List<String> childIds, List<Habit> allHabits) {
    final children = allHabits.where((habit) => childIds.contains(habit.id));

    for (final child in children) {
      // Enforce single-level depth: no bundles as children
      if (child.type == HabitType.bundle) {
        return 'Cannot nest bundles: ${child.name} is already a bundle. Only one level of depth allowed.';
      }
      if (child.parentBundleId != null) {
        return 'Habit ${child.name} is already part of another bundle';
      }
    }

    if (childIds.length < 2) {
      return 'Bundle must have at least 2 child habits';
    }

    if (childIds.length > 8) {
      return 'Bundle cannot have more than 8 child habits';
    }

    return null; // Valid
  }

  /// Add a habit to an existing bundle
  Habit addHabitToBundle(Habit bundle, String habitId, List<Habit> allHabits) {
    if (bundle.type != HabitType.bundle) {
      throw ArgumentError('Not a bundle habit');
    }

    final newChildIds = <String>[...(bundle.bundleChildIds ?? []), habitId];
    final validationError = validateBundleCreation(newChildIds, allHabits);

    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    return Habit(
      id: bundle.id,
      name: bundle.name,
      description: bundle.description,
      type: bundle.type,
      stackedOnHabitId: bundle.stackedOnHabitId,
      bundleChildIds: newChildIds,
      parentBundleId: bundle.parentBundleId,
      // TODO(bridger): TimeOfDay fields disabled
      // alarmTime: bundle.alarmTime,
      timeoutMinutes: bundle.timeoutMinutes,
      // windowStartTime: bundle.windowStartTime,
      // windowEndTime: bundle.windowEndTime,
      availableDays: bundle.availableDays,
      createdAt: bundle.createdAt,
      lastCompleted: bundle.lastCompleted,
      lastAlarmTriggered: bundle.lastAlarmTriggered,
      sessionStartTime: bundle.sessionStartTime,
      lastSessionStarted: bundle.lastSessionStarted,
      sessionCompletedToday: bundle.sessionCompletedToday,
      dailyCompletionCount: bundle.dailyCompletionCount,
      lastCompletionCountReset: bundle.lastCompletionCountReset,
      dailyFailureCount: bundle.dailyFailureCount,
      lastFailureCountReset: bundle.lastFailureCountReset,
      avoidanceSuccessToday: bundle.avoidanceSuccessToday,
      currentStreak: bundle.currentStreak,
    );
  }

  /// Get available habits that can be added to a bundle
  List<Habit> getAvailableHabitsForBundle(List<Habit> allHabits) {
    return allHabits
        .where((habit) =>
            habit.type != HabitType.bundle && habit.parentBundleId == null)
        .toList();
  }

  /// Create a bundle with child habits
  Habit createBundle({
    required String name,
    required String description,
    required List<String> childIds,
    required List<Habit> allHabits,
  }) {
    final validationError = validateBundleCreation(childIds, allHabits);
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    return Habit.create(
      name: name,
      description: description,
      type: HabitType.bundle,
      bundleChildIds: childIds,
    );
  }

  /// Update child habits to reference their parent bundle
  List<Habit> assignChildrenToBundle(
      String bundleId, List<String> childIds, List<Habit> allHabits) {
    final updatedHabits = <Habit>[];

    for (final habit in allHabits) {
      if (childIds.contains(habit.id)) {
        updatedHabits.add(Habit(
          id: habit.id,
          name: habit.name,
          description: habit.description,
          type: habit.type,
          stackedOnHabitId: habit.stackedOnHabitId,
          bundleChildIds: habit.bundleChildIds,
          parentBundleId: bundleId,
          // TODO(bridger): TimeOfDay fields disabled
          // alarmTime: habit.alarmTime,
          timeoutMinutes: habit.timeoutMinutes,
          // windowStartTime: habit.windowStartTime,
          // windowEndTime: habit.windowEndTime,
          availableDays: habit.availableDays,
          createdAt: habit.createdAt,
          lastCompleted: habit.lastCompleted,
          lastAlarmTriggered: habit.lastAlarmTriggered,
          sessionStartTime: habit.sessionStartTime,
          lastSessionStarted: habit.lastSessionStarted,
          sessionCompletedToday: habit.sessionCompletedToday,
          dailyCompletionCount: habit.dailyCompletionCount,
          lastCompletionCountReset: habit.lastCompletionCountReset,
          dailyFailureCount: habit.dailyFailureCount,
          lastFailureCountReset: habit.lastFailureCountReset,
          avoidanceSuccessToday: habit.avoidanceSuccessToday,
          currentStreak: habit.currentStreak,
        ));
      }
    }

    return updatedHabits;
  }

  /// Get bundle status text
  String getBundleStatus(Habit bundle, List<Habit> allHabits) {
    final progress = getBundleProgress(bundle, allHabits);

    if (progress.total == 0) {
      return 'Empty bundle';
    }

    if (progress.completed == progress.total) {
      return 'All complete! ✅';
    }

    return '${progress.completed}/${progress.total} complete';
  }

  /// Get progress percentage for UI
  double getBundleProgressPercentage(Habit bundle, List<Habit> allHabits) {
    final progress = getBundleProgress(bundle, allHabits);
    if (progress.total == 0) return 0.0;
    return progress.completed / progress.total;
  }
}

/// Bundle progress data class
class BundleProgress {
  final int completed;
  final int total;

  const BundleProgress({required this.completed, required this.total});

  @override
  String toString() => '$completed/$total';
}

/// Check if a habit should show as completed today

/// Result of completing a bundle with combo bonus
class BundleCompletionResult {
  final List<Habit> completedHabits;
  final int comboBonus;

  const BundleCompletionResult({
    required this.completedHabits,
    required this.comboBonus,
  });

  int get totalXP =>
      completedHabits.fold<int>(
          0, (sum, habit) => sum + habit.calculateXPReward()) +
      comboBonus;
}
