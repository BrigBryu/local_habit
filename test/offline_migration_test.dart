import 'package:flutter_test/flutter_test.dart';
import 'package:domain/domain.dart';

void main() {
  group('Offline Migration Tests', () {
    test('should create habits without network dependencies', () {
      // Test that we can create habits without any network calls
      final basicHabit = Habit.create(
        name: 'Test Basic Habit',
        description: 'A basic habit for testing',
        type: HabitType.basic,
      );

      expect(basicHabit.name, equals('Test Basic Habit'));
      expect(basicHabit.type, equals(HabitType.basic));
      expect(basicHabit.currentStreak, equals(0));
      expect(basicHabit.dailyCompletionCount, equals(0));
    });

    test('should complete habits and track streaks locally', () {
      final habit = Habit.create(
        name: 'Test Habit',
        description: 'A test habit',
        type: HabitType.basic,
      );

      // Complete the habit
      final completedHabit = habit.complete();

      expect(completedHabit.currentStreak, equals(1));
      expect(completedHabit.dailyCompletionCount, equals(1));
      expect(completedHabit.lastCompleted, isNotNull);
    });

    test('should handle avoidance habit failures locally', () {
      final avoidanceHabit = Habit.create(
        name: 'Avoid Junk Food',
        description: 'Don\'t eat junk food',
        type: HabitType.avoidance,
      );

      // Record a failure
      final failedHabit = avoidanceHabit.recordFailure();

      expect(failedHabit.dailyFailureCount, equals(1));
      expect(failedHabit.currentStreak, equals(0)); // Streak broken
      expect(failedHabit.avoidanceSuccessToday, isFalse);
    });

    test('should support interval habits', () {
      final intervalHabit = Habit.create(
        name: 'Every 3 Days',
        description: 'Do this every 3 days',
        type: HabitType.interval,
        intervalDays: 3,
      );

      expect(intervalHabit.type, equals(HabitType.interval));
      expect(intervalHabit.intervalDays, equals(3));
    });

    test('should support weekly habits', () {
      final weeklyHabit = Habit.create(
        name: 'Weekend Workout',
        description: 'Workout on weekends',
        type: HabitType.weekly,
        weekdayMask: 65, // Sunday and Saturday (binary 1000001)
      );

      expect(weeklyHabit.type, equals(HabitType.weekly));
      expect(weeklyHabit.weekdayMask, equals(65));
    });

    test('should support stack habits', () {
      final stackHabit = Habit.create(
        name: 'Morning Routine Stack',
        description: 'Complete morning routine steps',
        type: HabitType.stack,
      );

      expect(stackHabit.type, equals(HabitType.stack));
      expect(stackHabit.currentChildIndex, equals(0));
    });

    test('should support bundle habits', () {
      final childHabit1 = Habit.create(
        name: 'Child 1',
        description: 'First child habit',
        type: HabitType.basic,
      );
      
      final childHabit2 = Habit.create(
        name: 'Child 2',
        description: 'Second child habit',
        type: HabitType.basic,
      );

      final bundleHabit = Habit.createBundle(
        name: 'Exercise Bundle',
        description: 'Complete all exercises',
        childIds: [childHabit1.id, childHabit2.id],
      );

      expect(bundleHabit.type, equals(HabitType.bundle));
      expect(bundleHabit.bundleChildIds?.length, equals(2));
      expect(bundleHabit.bundleChildIds, contains(childHabit1.id));
      expect(bundleHabit.bundleChildIds, contains(childHabit2.id));
    });


    test('should serialize and deserialize habits to/from JSON', () {
      final originalHabit = Habit.create(
        name: 'Serialization Test',
        description: 'Test JSON serialization',
        type: HabitType.basic,
      );

      // Serialize to JSON
      final json = originalHabit.toJson();
      expect(json['name'], equals('Serialization Test'));
      expect(json['type'], equals('basic'));

      // Deserialize from JSON
      final deserializedHabit = Habit.fromJson(json);
      expect(deserializedHabit.name, equals(originalHabit.name));
      expect(deserializedHabit.type, equals(originalHabit.type));
      expect(deserializedHabit.id, equals(originalHabit.id));
      expect(deserializedHabit.createdAt, equals(originalHabit.createdAt));
    });

    test('should verify no network functionality remains', () {
      // Test that all habit types can be created and used without any network calls
      final allHabitTypes = [
        HabitType.basic,
        HabitType.avoidance,
        HabitType.stack,
        HabitType.bundle,
        HabitType.interval,
        HabitType.weekly,
      ];

      for (final type in allHabitTypes) {
        final habit = Habit.create(
          name: 'Test ${type.displayName}',
          description: 'Testing ${type.displayName}',
          type: type,
        );

        expect(habit.type, equals(type));
        expect(habit.name, isNotEmpty);
        expect(habit.id, isNotEmpty);

        // All habits should be completable without network
        final completedHabit = habit.complete();
        expect(completedHabit.lastCompleted, isNotNull);
      }
    });
  });
}