import 'package:domain/domain.dart';

/// Service for managing stack habit progress and completion flow
/// Implements the HabitStack behavior per requirements:
/// - Only current child can be completed
/// - Completing child unlocks next one
/// - +1 XP bonus when all children done in same day
/// - Reset currentChildIndex to 0 at daily rollover
class StackProgressService {
  static final StackProgressService _instance =
      StackProgressService._internal();
  factory StackProgressService() => _instance;
  StackProgressService._internal();

  /// Complete the current active child in a stack
  /// Returns result with updated stack and completion info
  Future<StackCompletionResult?> completeStackChild(
    String stackId,
    List<Habit> allHabits,
    Future<String?> Function(String habitId) completeHabitFunction,
  ) async {
    final stack = allHabits.firstWhere((h) => h.id == stackId);
    if (stack.type != HabitType.stack) return null;

    final childIds = stack.stackChildIds ?? [];
    if (childIds.isEmpty) return null;

    // Get current child based on currentChildIndex
    if (stack.currentChildIndex >= childIds.length) return null;

    final currentChildId = childIds[stack.currentChildIndex];
    final currentChild = allHabits.firstWhere(
      (h) => h.id == currentChildId,
      orElse: () => throw Exception('Stack child not found: $currentChildId'),
    );

    // Don't allow completion if child is already completed today
    if (isHabitCompletedToday(currentChild)) {
      return null;
    }

    // Complete the current child
    final completionResult = await completeHabitFunction(currentChildId);
    if (completionResult != null) {
      return null; // Completion failed
    }

    // Update stack's currentChildIndex
    final newIndex = stack.currentChildIndex + 1;
    final isStackComplete = newIndex >= childIds.length;
    final stackBonus = isStackComplete ? 1 : 0;

    final updatedStack = Habit(
      id: stack.id,
      name: stack.name,
      description: stack.description,
      type: stack.type,
      stackedOnHabitId: stack.stackedOnHabitId,
      bundleChildIds: stack.bundleChildIds,
      parentBundleId: stack.parentBundleId,
      stackChildIds: stack.stackChildIds,
      currentChildIndex: newIndex,
      timeoutMinutes: stack.timeoutMinutes,
      availableDays: stack.availableDays,
      createdAt: stack.createdAt,
      lastCompleted: isStackComplete ? DateTime.now() : stack.lastCompleted,
      lastAlarmTriggered: stack.lastAlarmTriggered,
      sessionStartTime: stack.sessionStartTime,
      lastSessionStarted: stack.lastSessionStarted,
      sessionCompletedToday: stack.sessionCompletedToday,
      dailyCompletionCount: stack.dailyCompletionCount,
      lastCompletionCountReset: stack.lastCompletionCountReset,
      dailyFailureCount: stack.dailyFailureCount,
      lastFailureCountReset: stack.lastFailureCountReset,
      avoidanceSuccessToday: stack.avoidanceSuccessToday,
      currentStreak: stack.currentStreak,
    );

    return StackCompletionResult(
      updatedStack: updatedStack,
      completedChildId: currentChildId,
      isStackComplete: isStackComplete,
      stackBonusXP: stackBonus,
      childXP: currentChild.calculateXPReward(),
      position: stack.currentChildIndex + 1,
      total: childIds.length,
    );
  }

  /// Get current stack progress
  StackProgress getStackProgress(Habit stack, List<Habit> allHabits) {
    if (stack.type != HabitType.stack) {
      return StackProgress(completed: 0, total: 0, currentIndex: 0);
    }

    final childIds = stack.stackChildIds ?? [];
    if (childIds.isEmpty) {
      return StackProgress(completed: 0, total: 0, currentIndex: 0);
    }

    // Count completed children today
    int completedToday = 0;
    for (int i = 0; i < childIds.length; i++) {
      final child = allHabits.firstWhere(
        (h) => h.id == childIds[i],
        orElse: () => throw Exception('Stack child not found: ${childIds[i]}'),
      );
      if (isHabitCompletedToday(child)) {
        completedToday++;
      } else {
        break; // Stop at first uncompleted child (sequential requirement)
      }
    }

    return StackProgress(
      completed: completedToday,
      total: childIds.length,
      currentIndex: stack.currentChildIndex,
    );
  }

  /// Get the current active child habit (the one that can be completed)
  Habit? getCurrentChild(Habit stack, List<Habit> allHabits) {
    if (stack.type != HabitType.stack) return null;

    final childIds = stack.stackChildIds ?? [];
    if (childIds.isEmpty || stack.currentChildIndex >= childIds.length) {
      return null;
    }

    final currentChildId = childIds[stack.currentChildIndex];
    return allHabits.firstWhere(
      (h) => h.id == currentChildId,
      orElse: () => throw Exception('Stack child not found: $currentChildId'),
    );
  }

  /// Get all child habits in stack order
  List<Habit> getStackChildren(Habit stack, List<Habit> allHabits) {
    if (stack.type != HabitType.stack) return [];

    final childIds = stack.stackChildIds ?? [];
    return childIds.map((id) {
      return allHabits.firstWhere(
        (h) => h.id == id,
        orElse: () => throw Exception('Stack child not found: $id'),
      );
    }).toList();
  }

  /// Check if stack is complete for today
  bool isStackComplete(Habit stack, List<Habit> allHabits) {
    final progress = getStackProgress(stack, allHabits);
    return progress.completed == progress.total && progress.total > 0;
  }

  /// Reset stack progress for daily rollover
  /// This should be called by the nightly job
  Habit resetStackForNewDay(Habit stack) {
    if (stack.type != HabitType.stack) return stack;

    return Habit(
      id: stack.id,
      name: stack.name,
      description: stack.description,
      type: stack.type,
      stackedOnHabitId: stack.stackedOnHabitId,
      bundleChildIds: stack.bundleChildIds,
      parentBundleId: stack.parentBundleId,
      stackChildIds: stack.stackChildIds,
      currentChildIndex: 0, // Reset to start of stack
      timeoutMinutes: stack.timeoutMinutes,
      availableDays: stack.availableDays,
      createdAt: stack.createdAt,
      lastCompleted: stack.lastCompleted,
      lastAlarmTriggered: stack.lastAlarmTriggered,
      sessionStartTime: stack.sessionStartTime,
      lastSessionStarted: stack.lastSessionStarted,
      sessionCompletedToday: stack.sessionCompletedToday,
      dailyCompletionCount: stack.dailyCompletionCount,
      lastCompletionCountReset: stack.lastCompletionCountReset,
      dailyFailureCount: stack.dailyFailureCount,
      lastFailureCountReset: stack.lastFailureCountReset,
      avoidanceSuccessToday: stack.avoidanceSuccessToday,
      currentStreak: stack.currentStreak,
    );
  }

  /// Get stack status text for UI
  String getStackStatus(Habit stack, List<Habit> allHabits) {
    if (stack.type != HabitType.stack) return 'Not a stack';

    final childIds = stack.stackChildIds ?? [];
    if (childIds.isEmpty) return 'Empty stack';

    final progress = getStackProgress(stack, allHabits);

    if (isStackComplete(stack, allHabits)) {
      return 'Stack Complete! ✅ +1 XP Bonus';
    }

    final currentChild = getCurrentChild(stack, allHabits);
    if (currentChild != null) {
      return 'Next: ${currentChild.name}';
    }

    return '${progress.completed}/${progress.total} completed';
  }

  /// Validate stack creation
  String? validateStackCreation(List<String> childIds, List<Habit> allHabits) {
    if (childIds.isEmpty) {
      return 'Stack must have at least 1 child';
    }

    if (childIds.length > 10) {
      return 'Stack cannot have more than 10 children';
    }

    // Check that all child IDs exist
    for (final childId in childIds) {
      final child = allHabits.firstWhere(
        (h) => h.id == childId,
        orElse: () => throw Exception('Child habit not found: $childId'),
      );

      // Don't allow bundles, stacks, or habits already in other relationships
      if (child.type == HabitType.bundle) {
        return 'Cannot add bundles to stacks: ${child.name}';
      }

      if (child.type == HabitType.stack) {
        return 'Cannot nest stacks: ${child.name}';
      }

      if (child.parentBundleId != null) {
        return 'Habit ${child.name} is already in a bundle';
      }

      if (child.stackedOnHabitId != null) {
        return 'Habit ${child.name} is already in another stack (legacy)';
      }

      // Check if already in another stack (new architecture)
      final existingStack = allHabits
          .where((h) =>
              h.type == HabitType.stack &&
              (h.stackChildIds?.contains(childId) ?? false))
          .firstOrNull;
      if (existingStack != null) {
        return 'Habit ${child.name} is already in stack: ${existingStack.name}';
      }
    }

    return null; // Valid
  }

  /// Create a new stack habit
  Habit createStack({
    required String name,
    required String description,
    required List<String> childIds,
    required List<Habit> allHabits,
  }) {
    final validationError = validateStackCreation(childIds, allHabits);
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    return Habit.create(
      name: name,
      description: description,
      type: HabitType.stack,
      stackChildIds: List.from(childIds),
      currentChildIndex: 0,
    );
  }
}

/// Progress data for a stack
class StackProgress {
  final int completed;
  final int total;
  final int currentIndex;

  const StackProgress({
    required this.completed,
    required this.total,
    required this.currentIndex,
  });

  @override
  String toString() => '$completed/$total (current: $currentIndex)';
}

/// Result of completing a stack child
class StackCompletionResult {
  final Habit updatedStack;
  final String completedChildId;
  final bool isStackComplete;
  final int stackBonusXP;
  final int childXP;
  final int position;
  final int total;

  const StackCompletionResult({
    required this.updatedStack,
    required this.completedChildId,
    required this.isStackComplete,
    required this.stackBonusXP,
    required this.childXP,
    required this.position,
    required this.total,
  });

  int get totalXP => childXP + stackBonusXP;
}


/// Extension to get first matching element or null
extension FirstWhereOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}
