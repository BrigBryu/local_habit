import 'package:domain/entities/habit.dart';

/// Generic service for managing parent-child relationships between habits
/// Supports bundles, stacks, and future grouping types
class HabitRelationshipService {
  static final HabitRelationshipService _instance = HabitRelationshipService._internal();
  factory HabitRelationshipService() => _instance;
  HabitRelationshipService._internal();

  /// Get all habits that can be added to a group (not already grouped, correct type)
  List<Habit> getAvailableHabitsForGrouping({
    required List<Habit> allHabits,
    required HabitType groupType,
    String? excludeParentId,
  }) {
    return allHabits.where((habit) {
      // Exclude the parent itself
      if (excludeParentId != null && habit.id == excludeParentId) return false;
      
      switch (groupType) {
        case HabitType.bundle:
          // Bundles can contain any habit except other bundles
          return habit.type != HabitType.bundle && habit.parentBundleId == null;
        case HabitType.stack:
          // Stacks can build on any completed habit
          return habit.type != HabitType.stack;
        default:
          return true;
      }
    }).toList();
  }

  /// Validate if a set of habits can be grouped together
  GroupingValidationResult validateGrouping({
    required List<String> childIds,
    required HabitType groupType,
    required List<Habit> allHabits,
    String? parentId,
  }) {
    final children = allHabits.where((h) => childIds.contains(h.id)).toList();
    
    // Check minimum requirements
    switch (groupType) {
      case HabitType.bundle:
        if (childIds.length < 2) {
          return GroupingValidationResult.error('Bundle must have at least 2 habits');
        }
        if (childIds.length > 8) {
          return GroupingValidationResult.error('Bundle cannot have more than 8 habits');
        }
        break;
      case HabitType.stack:
        if (childIds.length != 1) {
          return GroupingValidationResult.error('Stack must build on exactly 1 base habit');
        }
        break;
      default:
        break;
    }

    // Check for conflicts
    for (final child in children) {
      // Prevent nesting
      if (child.type == groupType) {
        return GroupingValidationResult.error('Cannot nest ${groupType.displayName} inside ${groupType.displayName}');
      }
      
      // Check if already grouped
      if (groupType == HabitType.bundle && child.parentBundleId != null && child.parentBundleId != parentId) {
        return GroupingValidationResult.error('${child.name} is already part of another bundle');
      }
    }

    return GroupingValidationResult.success();
  }

  /// Create parent-child relationships between habits
  List<Habit> createRelationships({
    required String parentId,
    required List<String> childIds,
    required HabitType relationshipType,
    required List<Habit> allHabits,
  }) {
    final updatedHabits = <Habit>[];
    
    for (final habit in allHabits) {
      if (childIds.contains(habit.id)) {
        // Update child to reference parent
        final updatedChild = _createChildRelationship(habit, parentId, relationshipType);
        updatedHabits.add(updatedChild);
      } else if (habit.id == parentId) {
        // Update parent to reference children
        final updatedParent = _createParentRelationship(habit, childIds, relationshipType);
        updatedHabits.add(updatedParent);
      }
    }
    
    return updatedHabits;
  }

  /// Remove a child from a parent relationship
  List<Habit> removeChildFromParent({
    required String parentId,
    required String childId,
    required List<Habit> allHabits,
  }) {
    final updatedHabits = <Habit>[];
    
    for (final habit in allHabits) {
      if (habit.id == childId) {
        // Clear parent reference from child
        final updatedChild = _clearParentReference(habit);
        updatedHabits.add(updatedChild);
      } else if (habit.id == parentId) {
        // Remove child from parent's list
        final updatedParent = _removeChildFromParent(habit, childId);
        if (updatedParent != null) {
          updatedHabits.add(updatedParent);
        }
      }
    }
    
    return updatedHabits;
  }

  /// Get children of a parent habit in their defined order
  List<Habit> getOrderedChildren({
    required Habit parent,
    required List<Habit> allHabits,
  }) {
    List<String>? childIds;
    
    switch (parent.type) {
      case HabitType.bundle:
        childIds = parent.bundleChildIds;
        break;
      case HabitType.stack:
        childIds = parent.stackedOnHabitId != null ? [parent.stackedOnHabitId!] : null;
        break;
      default:
        return [];
    }
    
    if (childIds == null || childIds.isEmpty) return [];
    
    // Create lookup map for O(1) access
    final habitMap = {for (final habit in allHabits) habit.id: habit};
    
    // Return in order specified by parent
    return childIds
        .map((id) => habitMap[id])
        .where((habit) => habit != null)
        .cast<Habit>()
        .toList();
  }

  /// Private helper methods
  
  Habit _createChildRelationship(Habit child, String parentId, HabitType relationshipType) {
    switch (relationshipType) {
      case HabitType.bundle:
        return _copyHabitWithChanges(child, parentBundleId: parentId);
      case HabitType.stack:
        // For stacks, the relationship is inverted - parent references child
        return child;
      default:
        return child;
    }
  }

  Habit _createParentRelationship(Habit parent, List<String> childIds, HabitType relationshipType) {
    switch (relationshipType) {
      case HabitType.bundle:
        return _copyHabitWithChanges(parent, bundleChildIds: childIds);
      case HabitType.stack:
        return _copyHabitWithChanges(parent, stackedOnHabitId: childIds.first);
      default:
        return parent;
    }
  }

  Habit _clearParentReference(Habit child) {
    return _copyHabitWithChanges(child, parentBundleId: null);
  }

  Habit? _removeChildFromParent(Habit parent, String childId) {
    switch (parent.type) {
      case HabitType.bundle:
        final updatedChildIds = parent.bundleChildIds?.where((id) => id != childId).toList();
        if (updatedChildIds == null || updatedChildIds.length < 2) {
          return null; // Bundle becomes invalid
        }
        return _copyHabitWithChanges(parent, bundleChildIds: updatedChildIds);
      case HabitType.stack:
        if (parent.stackedOnHabitId == childId) {
          return _copyHabitWithChanges(parent, stackedOnHabitId: null);
        }
        return parent;
      default:
        return parent;
    }
  }

  /// Generic habit copying with selective field updates
  Habit _copyHabitWithChanges(
    Habit original, {
    String? parentBundleId,
    List<String>? bundleChildIds,
    String? stackedOnHabitId,
  }) {
    return Habit(
      id: original.id,
      name: original.name,
      description: original.description,
      type: original.type,
      stackedOnHabitId: stackedOnHabitId ?? original.stackedOnHabitId,
      bundleChildIds: bundleChildIds ?? original.bundleChildIds,
      parentBundleId: parentBundleId ?? original.parentBundleId,
      timeoutMinutes: original.timeoutMinutes,
      availableDays: original.availableDays,
      createdAt: original.createdAt,
      lastCompleted: original.lastCompleted,
      lastAlarmTriggered: original.lastAlarmTriggered,
      sessionStartTime: original.sessionStartTime,
      lastSessionStarted: original.lastSessionStarted,
      sessionCompletedToday: original.sessionCompletedToday,
      dailyCompletionCount: original.dailyCompletionCount,
      lastCompletionCountReset: original.lastCompletionCountReset,
      dailyFailureCount: original.dailyFailureCount,
      lastFailureCountReset: original.lastFailureCountReset,
      avoidanceSuccessToday: original.avoidanceSuccessToday,
      currentStreak: original.currentStreak,
    );
  }
}

/// Result of validating a grouping operation
class GroupingValidationResult {
  final bool isValid;
  final String? errorMessage;

  const GroupingValidationResult._({required this.isValid, this.errorMessage});

  factory GroupingValidationResult.success() => const GroupingValidationResult._(isValid: true);
  factory GroupingValidationResult.error(String message) => GroupingValidationResult._(isValid: false, errorMessage: message);

  @override
  String toString() => isValid ? 'Valid' : 'Error: $errorMessage';
}