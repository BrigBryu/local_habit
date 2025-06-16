import 'package:domain/entities/habit.dart';
import 'package:domain/services/time_service.dart';

/// Service to manage habit stacks - sequential habit chains
class StackService {
  static final StackService _instance = StackService._internal();
  factory StackService() => _instance;
  StackService._internal();

  /// Get stack steps for a stack habit (ordered by creation/position)
  List<Habit> getStackSteps(Habit stack, List<Habit> allHabits) {
    if (stack.type != HabitType.stack || stack.stackedOnHabitId == null) {
      return [];
    }

    // Get all habits that stack on this habit
    final stackSteps =
        allHabits.where((habit) => habit.stackedOnHabitId == stack.id).toList();

    // Sort by creation time to maintain order
    stackSteps.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return stackSteps;
  }

  /// Get the next uncompleted step in the stack
  Habit? getNextIncompleteStep(Habit stack, List<Habit> allHabits) {
    final steps = getStackSteps(stack, allHabits);

    for (final step in steps) {
      if (!isHabitCompletedToday(step)) {
        return step;
      }
    }

    return null; // All steps completed
  }

  /// Get stack progress (completed/total steps)
  StackProgress getStackProgress(Habit stack, List<Habit> allHabits) {
    if (stack.type != HabitType.stack) {
      return StackProgress(completed: 0, total: 0, position: 0);
    }

    final steps = getStackSteps(stack, allHabits);
    final completedCount =
        steps.where((step) => isHabitCompletedToday(step)).length;

    // Position is the next step to complete (1-indexed)
    final position = completedCount + 1;

    return StackProgress(
      completed: completedCount,
      total: steps.length,
      position: position <= steps.length ? position : steps.length,
    );
  }

  /// Check if the entire stack is completed for today
  bool isStackCompleted(Habit stack, List<Habit> allHabits) {
    final progress = getStackProgress(stack, allHabits);
    return progress.completed == progress.total && progress.total > 0;
  }

  /// Check if a stack step can be completed (in correct order)
  bool canCompleteStackStep(Habit step, Habit stack, List<Habit> allHabits) {
    if (step.stackedOnHabitId != stack.id) return false;
    if (isHabitCompletedToday(step)) return false;

    final nextStep = getNextIncompleteStep(stack, allHabits);
    return nextStep?.id == step.id;
  }

  /// Complete the next step in the stack
  StackStepCompletionResult? completeNextStep(
      Habit stack, List<Habit> allHabits) {
    final nextStep = getNextIncompleteStep(stack, allHabits);
    if (nextStep == null) return null;

    final completedStep = nextStep.complete();
    final progress = getStackProgress(stack, allHabits);
    final isLastStep = progress.position >= progress.total;

    return StackStepCompletionResult(
      completedStep: completedStep,
      isLastStep: isLastStep,
      position: progress.position,
      total: progress.total,
    );
  }

  /// Get remaining steps count
  int getRemainingStepsCount(Habit stack, List<Habit> allHabits) {
    final progress = getStackProgress(stack, allHabits);
    return progress.total - progress.completed;
  }

  /// Get stack status text for UI
  String getStackStatus(Habit stack, List<Habit> allHabits) {
    final progress = getStackProgress(stack, allHabits);

    if (progress.total == 0) {
      return 'Empty stack';
    }

    if (progress.completed == progress.total) {
      return 'Stack complete! ✅';
    }

    final remaining = progress.total - progress.completed;
    return '$remaining step${remaining == 1 ? '' : 's'} left';
  }

  /// Get progress percentage for UI
  double getStackProgressPercentage(Habit stack, List<Habit> allHabits) {
    final progress = getStackProgress(stack, allHabits);
    if (progress.total == 0) return 0.0;
    return progress.completed / progress.total;
  }

  /// Validate stack creation
  String? validateStackCreation(List<String> stepIds, List<Habit> allHabits) {
    if (stepIds.isEmpty) {
      return 'Stack must have at least 1 step';
    }

    if (stepIds.length > 10) {
      return 'Stack cannot have more than 10 steps';
    }

    final steps = allHabits.where((habit) => stepIds.contains(habit.id));

    for (final step in steps) {
      // No bundles or other stacks as steps
      if (step.type == HabitType.bundle) {
        return 'Cannot add bundles to stacks: ${step.name}';
      }

      if (step.type == HabitType.stack) {
        return 'Cannot nest stacks: ${step.name}';
      }

      // Check if already in another stack or bundle
      if (step.stackedOnHabitId != null) {
        return 'Habit ${step.name} is already part of another stack';
      }

      if (step.parentBundleId != null) {
        return 'Habit ${step.name} is already part of a bundle';
      }
    }

    return null; // Valid
  }

  /// Create a stack with steps
  Habit createStack({
    required String name,
    required String description,
    required List<String> stepIds,
    required List<Habit> allHabits,
  }) {
    final validationError = validateStackCreation(stepIds, allHabits);
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    return Habit.create(
      name: name,
      description: description,
      type: HabitType.stack,
    );
  }

  /// Update step habits to reference their parent stack
  List<Habit> assignStepsToStack(
      String stackId, List<String> stepIds, List<Habit> allHabits) {
    final updatedHabits = <Habit>[];

    for (final habit in allHabits) {
      if (stepIds.contains(habit.id)) {
        updatedHabits.add(Habit(
          id: habit.id,
          name: habit.name,
          description: habit.description,
          type: habit.type,
          stackedOnHabitId: stackId,
          bundleChildIds: habit.bundleChildIds,
          parentBundleId: habit.parentBundleId,
          timeoutMinutes: habit.timeoutMinutes,
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

  /// Get available habits that can be added to a stack
  List<Habit> getAvailableHabitsForStack(List<Habit> allHabits) {
    return allHabits
        .where((habit) =>
            habit.type != HabitType.bundle &&
            habit.type != HabitType.stack &&
            habit.parentBundleId == null &&
            habit.stackedOnHabitId == null)
        .toList();
  }

  /// Reorder stack steps
  List<Habit> reorderStackSteps(
    List<Habit> steps,
    int oldIndex,
    int newIndex,
  ) {
    final reorderedSteps = List<Habit>.from(steps);
    final item = reorderedSteps.removeAt(oldIndex);
    reorderedSteps.insert(newIndex, item);

    // Update creation times to maintain new order
    final now = TimeService().now();
    for (int i = 0; i < reorderedSteps.length; i++) {
      final step = reorderedSteps[i];
      final newCreatedAt = now.add(Duration(milliseconds: i));

      reorderedSteps[i] = Habit(
        id: step.id,
        name: step.name,
        description: step.description,
        type: step.type,
        stackedOnHabitId: step.stackedOnHabitId,
        bundleChildIds: step.bundleChildIds,
        parentBundleId: step.parentBundleId,
        timeoutMinutes: step.timeoutMinutes,
        availableDays: step.availableDays,
        createdAt: newCreatedAt,
        lastCompleted: step.lastCompleted,
        lastAlarmTriggered: step.lastAlarmTriggered,
        sessionStartTime: step.sessionStartTime,
        lastSessionStarted: step.lastSessionStarted,
        sessionCompletedToday: step.sessionCompletedToday,
        dailyCompletionCount: step.dailyCompletionCount,
        lastCompletionCountReset: step.lastCompletionCountReset,
        dailyFailureCount: step.dailyFailureCount,
        lastFailureCountReset: step.lastFailureCountReset,
        avoidanceSuccessToday: step.avoidanceSuccessToday,
        currentStreak: step.currentStreak,
      );
    }

    return reorderedSteps;
  }
}

/// Stack progress data class
class StackProgress {
  final int completed;
  final int total;
  final int position; // Current position (1-indexed)

  const StackProgress({
    required this.completed,
    required this.total,
    required this.position,
  });

  @override
  String toString() => '$completed/$total (step $position)';
}

/// Check if a habit should show as completed today
bool isHabitCompletedToday(Habit habit) {
  if (habit.lastCompleted == null) return false;

  final timeService = TimeService();
  return timeService.isSameDay(habit.lastCompleted!, timeService.now());
}

/// Result of completing a stack step
class StackStepCompletionResult {
  final Habit completedStep;
  final bool isLastStep;
  final int position;
  final int total;

  const StackStepCompletionResult({
    required this.completedStep,
    required this.isLastStep,
    required this.position,
    required this.total,
  });

  int get xpReward => completedStep.calculateXPReward();

  /// Additional bonus for completing the entire stack
  int get stackCompleteBonus => isLastStep ? 2 : 0;

  int get totalXP => xpReward + stackCompleteBonus;
}
