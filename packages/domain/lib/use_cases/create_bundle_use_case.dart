import '../entities/habit.dart';

/// Use case for creating bundle habits
class CreateBundleUseCase {
  /// Validates and creates a new bundle habit
  ///
  /// Validates that:
  /// - Bundle name is not empty and within limits
  /// - At least 2 unique child habits are provided
  /// - Child habits exist and are valid for bundling
  ///
  /// Returns the created bundle habit
  static Habit execute({
    required String name,
    required String description,
    required List<String> childHabitIds,
    required List<Habit> existingHabits,
  }) {
    // Validate bundle name and description
    _validateBundleFields(name, description);

    // Validate child habits
    _validateChildHabits(childHabitIds, existingHabits);

    // Create the bundle habit
    return Habit.createBundle(
      name: name.trim(),
      description: description.trim(),
      childIds: childHabitIds,
    );
  }

  static void _validateBundleFields(String name, String description) {
    final trimmedName = name.trim();
    final trimmedDescription = description.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Bundle name cannot be empty');
    }

    if (trimmedName.length < 2) {
      throw ArgumentError('Bundle name must be at least 2 characters');
    }

    if (trimmedName.length > 50) {
      throw ArgumentError('Bundle name cannot exceed 50 characters');
    }

    if (trimmedDescription.length > 200) {
      throw ArgumentError('Bundle description cannot exceed 200 characters');
    }
  }

  static void _validateChildHabits(
      List<String> childHabitIds, List<Habit> existingHabits) {
    if (childHabitIds.length < 2) {
      throw ArgumentError('Bundle must contain at least 2 child habits');
    }

    // Check for duplicates
    final uniqueIds = childHabitIds.toSet();
    if (uniqueIds.length != childHabitIds.length) {
      throw ArgumentError('Bundle cannot contain duplicate habits');
    }

    // Validate each child habit exists and is valid for bundling
    for (final childId in childHabitIds) {
      final childHabit =
          existingHabits.where((h) => h.id == childId).firstOrNull;

      if (childHabit == null) {
        throw ArgumentError('Child habit with ID $childId not found');
      }

      // Bundles cannot contain other bundles
      if (childHabit.isBundle) {
        throw ArgumentError('Bundles cannot contain other bundles');
      }

      // Habits already in a bundle cannot be added to another bundle
      if (childHabit.isInBundle) {
        throw ArgumentError(
            'Habit "${childHabit.name}" is already in a bundle');
      }
    }
  }
}
