import 'package:test/test.dart';
import 'package:domain/entities/habit.dart';
import 'package:domain/use_cases/complete_bundle_use_case.dart';

void main() {
  group('CompleteBundleUseCase', () {
    late List<Habit> testHabits;
    late Habit bundleHabit;
    late Habit childHabit1;
    late Habit childHabit2;
    late Habit childHabit3;

    setUp(() {
      // Create test child habits
      childHabit1 = Habit.create(
        name: 'Make Bed',
        description: 'Make your bed each morning',
        type: HabitType.basic,
      );

      childHabit2 = Habit.create(
        name: 'Drink Water',
        description: 'Drink a glass of water',
        type: HabitType.basic,
      );

      childHabit3 = Habit.create(
        name: 'Stretch',
        description: '5 minute stretch',
        type: HabitType.basic,
      );

      // Create bundle habit
      bundleHabit = Habit.createBundle(
        name: 'Morning Routine',
        description: 'Complete your morning routine',
        childIds: [childHabit1.id, childHabit2.id, childHabit3.id],
      );

      testHabits = [childHabit1, childHabit2, childHabit3, bundleHabit];
    });

    test('should complete all incomplete child habits when bundle is completed', () {
      // Arrange - one child already completed
      final completedChild1 = childHabit1.complete();
      final allHabits = [completedChild1, childHabit2, childHabit3, bundleHabit];

      // Act
      final updatedHabits = CompleteBundleUseCase.execute(
        bundleHabit: bundleHabit,
        allHabits: allHabits,
      );

      // Assert
      expect(updatedHabits.length, equals(3)); // 2 incomplete children + bundle
      
      // Find the updated habits
      final updatedBundle = updatedHabits.firstWhere((h) => h.id == bundleHabit.id);
      final updatedChild2 = updatedHabits.firstWhere((h) => h.id == childHabit2.id);
      final updatedChild3 = updatedHabits.firstWhere((h) => h.id == childHabit3.id);

      // Check that all are now completed
      expect(isHabitCompletedToday(updatedBundle), isTrue);
      expect(isHabitCompletedToday(updatedChild2), isTrue);
      expect(isHabitCompletedToday(updatedChild3), isTrue);
    });

    test('should complete bundle when all children are already completed', () {
      // Arrange - all children already completed
      final completedChild1 = childHabit1.complete();
      final completedChild2 = childHabit2.complete();
      final completedChild3 = childHabit3.complete();
      final allHabits = [completedChild1, completedChild2, completedChild3, bundleHabit];

      // Act
      final updatedHabits = CompleteBundleUseCase.execute(
        bundleHabit: bundleHabit,
        allHabits: allHabits,
      );

      // Assert
      expect(updatedHabits.length, equals(1)); // Only bundle updated
      
      final updatedBundle = updatedHabits.first;
      expect(updatedBundle.id, equals(bundleHabit.id));
      expect(isHabitCompletedToday(updatedBundle), isTrue);
    });

    test('should throw error when habit is not a bundle', () {
      // Act & Assert
      expect(
        () => CompleteBundleUseCase.execute(
          bundleHabit: childHabit1, // Not a bundle
          allHabits: testHabits,
        ),
        throwsArgumentError,
      );
    });

    test('should throw error when bundle is already completed', () {
      // Arrange - bundle already completed
      final completedBundle = bundleHabit.complete();

      // Act & Assert
      expect(
        () => CompleteBundleUseCase.execute(
          bundleHabit: completedBundle,
          allHabits: testHabits,
        ),
        throwsStateError,
      );
    });

    test('should throw error when child habit is not found', () {
      // Arrange - bundle with non-existent child
      final invalidBundle = Habit.createBundle(
        name: 'Invalid Bundle',
        description: 'Has invalid child',
        childIds: ['nonexistent_id'],
      );

      // Act & Assert
      expect(
        () => CompleteBundleUseCase.execute(
          bundleHabit: invalidBundle,
          allHabits: testHabits,
        ),
        throwsStateError,
      );
    });

    test('getBundleProgress should return correct progress', () {
      // Arrange - one child completed
      final completedChild1 = childHabit1.complete();
      final allHabits = [completedChild1, childHabit2, childHabit3, bundleHabit];

      // Act
      final progress = CompleteBundleUseCase.getBundleProgress(
        bundleHabit: bundleHabit,
        allHabits: allHabits,
      );

      // Assert
      expect(progress.completed, equals(1));
      expect(progress.total, equals(3));
      expect(progress.percentage, closeTo(0.333, 0.01));
      expect(progress.isComplete, isFalse);
    });

    test('areAllChildrenCompleted should return correct status', () {
      // Arrange - all children completed
      final completedChild1 = childHabit1.complete();
      final completedChild2 = childHabit2.complete();
      final completedChild3 = childHabit3.complete();
      final allHabits = [completedChild1, completedChild2, completedChild3, bundleHabit];

      // Act
      final allCompleted = CompleteBundleUseCase.areAllChildrenCompleted(
        bundleHabit: bundleHabit,
        allHabits: allHabits,
      );

      // Assert
      expect(allCompleted, isTrue);
    });

    test('areAllChildrenCompleted should return false when some children incomplete', () {
      // Arrange - only one child completed
      final completedChild1 = childHabit1.complete();
      final allHabits = [completedChild1, childHabit2, childHabit3, bundleHabit];

      // Act
      final allCompleted = CompleteBundleUseCase.areAllChildrenCompleted(
        bundleHabit: bundleHabit,
        allHabits: allHabits,
      );

      // Assert
      expect(allCompleted, isFalse);
    });
  });

  group('BundleProgress', () {
    test('should calculate percentage correctly', () {
      final progress = BundleProgress(completed: 2, total: 5);
      expect(progress.percentage, equals(0.4));
    });

    test('should handle zero total', () {
      final progress = BundleProgress(completed: 0, total: 0);
      expect(progress.percentage, equals(0.0));
    });

    test('should detect complete status', () {
      final completeProgress = BundleProgress(completed: 3, total: 3);
      final incompleteProgress = BundleProgress(completed: 2, total: 3);
      final emptyProgress = BundleProgress(completed: 0, total: 0);

      expect(completeProgress.isComplete, isTrue);
      expect(incompleteProgress.isComplete, isFalse);
      expect(emptyProgress.isComplete, isFalse);
    });

    test('toString should return correct format', () {
      final progress = BundleProgress(completed: 2, total: 5);
      expect(progress.toString(), equals('2/5'));
    });
  });
}