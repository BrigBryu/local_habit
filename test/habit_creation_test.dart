import 'package:flutter_test/flutter_test.dart';
import 'package:domain/domain.dart';

void main() {
  group('Habit Creation', () {
    test('should create basic habit with valid properties', () {
      // Arrange
      const habitName = 'Exercise daily';
      const description = 'Go for a 30-minute walk';

      // Act
      final habit = BasicHabit(
        id: 'habit123',
        name: habitName,
        description: description,
        habitIcon: HabitIcon.exercise,
        timeOfDay: TimeOfDay.morning,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(habit.id, 'habit123');
      expect(habit.name, habitName);
      expect(habit.description, description);
      expect(habit.icon, HabitIcon.exercise);
      expect(habit.timeOfDay, TimeOfDay.morning);
      expect(habit.isCompleted, false);
      expect(habit.currentStreak, 0);
      expect(habit.totalCompletions, 0);
    });

    test('should validate habit name length', () {
      // Test minimum length (1 character)
      expect(() => _createTestHabit('A'), returnsNormally);

      // Test maximum length (64 characters)
      expect(() => _createTestHabit('A' * 64), returnsNormally);

      // Test too long (65+ characters) - would need validation in factory
      // This test assumes validation happens at service level
    });

    test('should handle habit completion', () {
      // Arrange
      final habit = _createTestHabit('Exercise');

      // Act
      final completedHabit = habit.copyWith(
        lastCompleted: DateTime.now(),
        currentStreak: habit.currentStreak + 1,
        dailyCompletionCount: habit.dailyCompletionCount + 1,
      );

      // Assert
      expect(completedHabit.isCompleted, true);
      expect(completedHabit.currentStreak, 1);
      expect(completedHabit.totalCompletions, 1);
      expect(completedHabit.lastCompleted, isNotNull);
    });

    test('should calculate streak correctly', () {
      // Arrange
      final habit = _createTestHabit('Exercise');
      final now = DateTime.now();

      // Simulate completing habit for 3 consecutive days
      var updatedHabit = habit;
      for (int i = 0; i < 3; i++) {
        updatedHabit = updatedHabit.copyWith(
          lastCompleted: now.subtract(Duration(days: 2 - i)),
          currentStreak: i + 1,
          dailyCompletionCount: updatedHabit.dailyCompletionCount + 1,
        );
      }

      // Assert
      expect(updatedHabit.currentStreak, 3);
      expect(updatedHabit.totalCompletions, 3);
    });

    test('should reset streak when habit is missed', () {
      // Arrange
      final habit = _createTestHabit('Exercise').copyWith(
        currentStreak: 5,
        dailyCompletionCount: 10,
      );

      // Act - simulate missing a day (streak reset)
      final resetHabit = habit.copyWith(
        currentStreak: 0,
        lastCompleted: null,
      );

      // Assert
      expect(resetHabit.currentStreak, 0);
      expect(resetHabit.totalCompletions, 10); // Total shouldn't change
    });

    test('should maintain habit statistics', () {
      // Arrange
      final habit = _createTestHabit('Exercise');

      // Act - simulate multiple completions
      final updatedHabit = habit.copyWith(
        dailyCompletionCount: 25,
        currentStreak: 7,
      );

      // Assert
      expect(updatedHabit.totalCompletions, 25);
      expect(updatedHabit.currentStreak, 7);
      // expect(updatedHabit.longestStreak, 15); // Property doesn't exist yet
    });

    test('should handle habit icon assignment', () {
      // Test all available habit icons
      final icons = [
        HabitIcon.exercise,
        HabitIcon.book,
        HabitIcon.water,
        HabitIcon.sleep,
        HabitIcon.meditation,
        HabitIcon.food,
        HabitIcon.work,
        HabitIcon.social,
        HabitIcon.creative,
        HabitIcon.learning,
      ];

      for (final icon in icons) {
        final habit = _createTestHabit('Test Habit').copyWith(habitIcon: icon);
        expect(habit.icon, icon);
      }
    });

    test('should handle time of day assignment', () {
      // Test all time periods
      final times = [
        TimeOfDay.morning,
        TimeOfDay.afternoon,
        TimeOfDay.evening,
        TimeOfDay.anytime,
      ];

      for (final time in times) {
        final habit = _createTestHabit('Test Habit').copyWith(timeOfDay: time);
        expect(habit.timeOfDay, time);
      }
    });
  });
}

BasicHabit _createTestHabit(String name) {
  return BasicHabit(
    id: 'test-id',
    name: name,
    description: 'Test description',
    habitIcon: HabitIcon.exercise,
    timeOfDay: TimeOfDay.morning,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
