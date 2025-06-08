import '../entities/habit.dart';

/// Use case for completing bundle habits
/// 
/// When a bundle is completed:
/// 1. All incomplete child habits for today are marked complete
/// 2. The bundle itself is marked complete
/// 3. Bundle maintains its own streak separately from children
class CompleteBundleUseCase {
  /// Completes a bundle habit and all its incomplete child habits for today
  /// 
  /// Returns a list of updated habits:
  /// - Updated child habits that were marked complete
  /// - Updated bundle habit marked as complete
  static List<Habit> execute({
    required Habit bundleHabit,
    required List<Habit> allHabits,
  }) {
    if (!bundleHabit.isBundle) {
      throw ArgumentError('Provided habit is not a bundle');
    }
    
    if (!bundleHabit.canCompleteBundle()) {
      throw StateError('Bundle cannot be completed (may already be completed today)');
    }
    
    final updatedHabits = <Habit>[];
    
    // Complete all incomplete child habits for today
    for (final childId in bundleHabit.childHabitIds) {
      final childHabit = allHabits.where((h) => h.id == childId).firstOrNull;
      
      if (childHabit == null) {
        throw StateError('Child habit with ID $childId not found');
      }
      
      // Only complete if not already completed today
      if (!isHabitCompletedToday(childHabit)) {
        final completedChild = childHabit.complete();
        updatedHabits.add(completedChild);
      }
    }
    
    // Complete the bundle itself
    final completedBundle = bundleHabit.complete();
    updatedHabits.add(completedBundle);
    
    return updatedHabits;
  }
  
  /// Check if all child habits in a bundle are completed today
  static bool areAllChildrenCompleted({
    required Habit bundleHabit,
    required List<Habit> allHabits,
  }) {
    if (!bundleHabit.isBundle) {
      return false;
    }
    
    for (final childId in bundleHabit.childHabitIds) {
      final childHabit = allHabits.where((h) => h.id == childId).firstOrNull;
      
      if (childHabit == null || !isHabitCompletedToday(childHabit)) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Get completion progress for a bundle (completed children / total children)
  static BundleProgress getBundleProgress({
    required Habit bundleHabit,
    required List<Habit> allHabits,
  }) {
    if (!bundleHabit.isBundle) {
      return BundleProgress(completed: 0, total: 0);
    }
    
    int completedCount = 0;
    int totalCount = bundleHabit.childHabitIds.length;
    
    for (final childId in bundleHabit.childHabitIds) {
      final childHabit = allHabits.where((h) => h.id == childId).firstOrNull;
      
      if (childHabit != null && isHabitCompletedToday(childHabit)) {
        completedCount++;
      }
    }
    
    return BundleProgress(completed: completedCount, total: totalCount);
  }
}

/// Data class representing bundle completion progress
class BundleProgress {
  final int completed;
  final int total;
  
  const BundleProgress({
    required this.completed,
    required this.total,
  });
  
  /// Get completion percentage (0.0 to 1.0)
  double get percentage => total > 0 ? completed / total : 0.0;
  
  /// Check if bundle is fully completed
  bool get isComplete => completed == total && total > 0;
  
  @override
  String toString() => '$completed/$total';
}

/// Helper class to group bundle data with its children
class BundleHabitWithChildren {
  final Habit bundleHabit;
  final List<Habit> childHabits;
  final BundleProgress progress;
  
  const BundleHabitWithChildren({
    required this.bundleHabit,
    required this.childHabits,
    required this.progress,
  });
}