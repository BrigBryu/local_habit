import 'package:flutter_test/flutter_test.dart';
import 'package:domain/domain.dart';
import '../lib/core/services/due_date_service.dart';

void main() {
  group('DueDateService', () {
    late DueDateService service;

    setUp(() {
      service = DueDateService();
    });

    group('Interval Habits', () {
      test('should be due on first completion when lastCompletionDate is null', () {
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          intervalDays: 3,
        );

        final today = DateTime(2023, 6, 15);
        expect(service.isDue(habit, today), isTrue);
      });

      test('should be due when enough days have passed', () {
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          intervalDays: 3,
        ).copyWith(
          lastCompletionDate: DateTime(2023, 6, 12), // 3 days ago
        );

        final today = DateTime(2023, 6, 15);
        expect(service.isDue(habit, today), isTrue);
      });

      test('should not be due when not enough days have passed', () {
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          intervalDays: 5,
        ).copyWith(
          lastCompletionDate: DateTime(2023, 6, 12), // 3 days ago
        );

        final today = DateTime(2023, 6, 15);
        expect(service.isDue(habit, today), isFalse);
      });

      test('should calculate correct next due date', () {
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          intervalDays: 7,
        ).copyWith(
          lastCompletionDate: DateTime(2023, 6, 10),
        );

        final nextDue = service.nextDue(habit);
        expect(nextDue, equals(DateTime(2023, 6, 17)));
      });

      test('should return today for next due when never completed', () {
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          intervalDays: 3,
        );

        final today = DateTime.now();
        final nextDue = service.nextDue(habit);
        final expectedToday = DateTime(today.year, today.month, today.day);
        expect(nextDue, equals(expectedToday));
      });
    });

    group('Weekly Habits', () {
      test('should be due on matching weekday', () {
        // Monday = 1, create habit for Mondays
        final habit = Habit.create(
          name: 'Test Weekly',
          description: 'Test',
          type: HabitType.weekly,
          weekdayMask: 1 << 1, // Monday bit set
        );

        final monday = DateTime(2023, 6, 19); // A Monday
        expect(service.isDue(habit, monday), isTrue);
      });

      test('should not be due on non-matching weekday', () {
        // Create habit for Mondays only
        final habit = Habit.create(
          name: 'Test Weekly',
          description: 'Test',
          type: HabitType.weekly,
          weekdayMask: 1 << 1, // Monday bit set
        );

        final tuesday = DateTime(2023, 6, 20); // A Tuesday
        expect(service.isDue(habit, tuesday), isFalse);
      });

      test('should be due on multiple selected weekdays', () {
        // Create habit for Monday (1) and Friday (5)
        final habit = Habit.create(
          name: 'Test Weekly',
          description: 'Test',
          type: HabitType.weekly,
          weekdayMask: (1 << 1) | (1 << 5), // Monday and Friday bits set
        );

        final monday = DateTime(2023, 6, 19); // A Monday
        final friday = DateTime(2023, 6, 23); // A Friday
        final wednesday = DateTime(2023, 6, 21); // A Wednesday

        expect(service.isDue(habit, monday), isTrue);
        expect(service.isDue(habit, friday), isTrue);
        expect(service.isDue(habit, wednesday), isFalse);
      });

      test('should calculate correct next due date for weekly habit', () {
        // Create habit for Friday (5)
        final habit = Habit.create(
          name: 'Test Weekly',
          description: 'Test',
          type: HabitType.weekly,
          weekdayMask: 1 << 5, // Friday bit set
        );

        final today = DateTime(2023, 6, 19); // A Monday
        final nextDue = service.nextDue(habit);
        
        // nextDue should be a Friday after the given date
        expect(nextDue?.weekday, equals(5)); // Should be Friday
        expect(nextDue?.isAfter(today), isTrue); // Should be after Monday
      });
    });

    group('Weekday Mask Utilities', () {
      test('should create correct weekday mask from indices', () {
        final mask = service.createWeekdayMask([1, 3, 5]); // Mon, Wed, Fri
        expect(mask, equals((1 << 1) | (1 << 3) | (1 << 5)));
      });

      test('should get correct weekday indices from mask', () {
        final mask = (1 << 1) | (1 << 3) | (1 << 5); // Mon, Wed, Fri
        final indices = service.getWeekdayIndices(mask);
        expect(indices, equals([1, 3, 5]));
      });

      test('should get correct weekday names from mask', () {
        final mask = (1 << 1) | (1 << 5); // Monday and Friday
        final names = service.getWeekdayNames(mask);
        expect(names, equals(['Monday', 'Friday']));
      });

      test('should handle all weekdays', () {
        final mask = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3) | (1 << 4) | (1 << 5) | (1 << 6);
        final names = service.getWeekdayNames(mask);
        expect(names, equals([
          'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
        ]));
      });
    });

    group('Non-occasional Habits', () {
      test('should always be due for basic habits', () {
        final habit = Habit.create(
          name: 'Test Basic',
          description: 'Test',
          type: HabitType.basic,
        );

        final today = DateTime.now();
        expect(service.isDue(habit, today), isTrue);
      });

      test('should always be due for avoidance habits', () {
        final habit = Habit.create(
          name: 'Test Avoidance',
          description: 'Test',
          type: HabitType.avoidance,
        );

        final today = DateTime.now();
        expect(service.isDue(habit, today), isTrue);
      });

      test('should return null next due date for non-occasional habits', () {
        final basicHabit = Habit.create(
          name: 'Test Basic',
          description: 'Test',
          type: HabitType.basic,
        );

        expect(service.nextDue(basicHabit), isNull);
      });
    });

    group('Due Date Descriptions', () {
      test('should return "Due today" for today', () {
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          intervalDays: 3,
        ).copyWith(
          lastCompletionDate: DateTime(2023, 6, 12),
        );

        // Mock the next due to be today
        final description = service.getNextDueDescription(habit);
        expect(description, isNotEmpty);
      });

      test('should return empty string for non-occasional habits', () {
        final habit = Habit.create(
          name: 'Test Basic',
          description: 'Test',
          type: HabitType.basic,
        );

        final description = service.getNextDueDescription(habit);
        expect(description, equals(''));
      });
    });

    group('Edge Cases', () {
      test('should handle DST transitions correctly for interval habits', () {
        // Test around DST transition (this is a simplified test)
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          intervalDays: 1,
        ).copyWith(
          lastCompletionDate: DateTime(2023, 3, 11), // Day before DST
        );

        final dayAfterDST = DateTime(2023, 3, 12);
        expect(service.isDue(habit, dayAfterDST), isTrue);
      });

      test('should handle leap year correctly', () {
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          intervalDays: 1,
        ).copyWith(
          lastCompletionDate: DateTime(2024, 2, 28), // Day before leap day
        );

        final leapDay = DateTime(2024, 2, 29);
        expect(service.isDue(habit, leapDay), isTrue);
      });

      test('should handle Sunday weekday correctly', () {
        // Sunday = 0, create habit for Sundays
        final habit = Habit.create(
          name: 'Test Weekly',
          description: 'Test',
          type: HabitType.weekly,
          weekdayMask: 1 << 0, // Sunday bit set
        );

        final sunday = DateTime(2023, 6, 18); // A Sunday
        expect(service.isDue(habit, sunday), isTrue);
      });
    });

    group('isCompletedToday', () {
      test('should return false for basic habits', () {
        final habit = Habit.create(
          name: 'Test Basic',
          description: 'Test',
          type: HabitType.basic,
        );

        final today = DateTime(2023, 6, 15);
        expect(service.isCompletedToday(habit, today), isFalse);
      });

      test('should return false for interval habit with no completion date', () {
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          intervalDays: 3,
        );

        final today = DateTime(2023, 6, 15);
        expect(service.isCompletedToday(habit, today), isFalse);
      });

      test('should return true for interval habit completed today', () {
        final today = DateTime(2023, 6, 15);
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          intervalDays: 3,
        ).copyWith(
          lastCompletionDate: today, // Completed today
        );

        expect(service.isCompletedToday(habit, today), isTrue);
      });

      test('should return false for interval habit completed yesterday', () {
        final today = DateTime(2023, 6, 15);
        final yesterday = DateTime(2023, 6, 14);
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          intervalDays: 3,
        ).copyWith(
          lastCompletionDate: yesterday, // Completed yesterday
        );

        expect(service.isCompletedToday(habit, today), isFalse);
      });

      test('should return true for weekly habit completed today', () {
        final today = DateTime(2023, 6, 19); // A Monday
        final habit = Habit.create(
          name: 'Test Weekly',
          description: 'Test',
          type: HabitType.weekly,
          weekdayMask: 1 << 1, // Monday bit set
        ).copyWith(
          lastCompletionDate: today, // Completed today
        );

        expect(service.isCompletedToday(habit, today), isTrue);
      });

      test('should return false for weekly habit completed on different day', () {
        final today = DateTime(2023, 6, 19); // A Monday
        final lastWeek = DateTime(2023, 6, 12); // Previous Monday
        final habit = Habit.create(
          name: 'Test Weekly',
          description: 'Test',
          type: HabitType.weekly,
          weekdayMask: 1 << 1, // Monday bit set
        ).copyWith(
          lastCompletionDate: lastWeek, // Completed last week
        );

        expect(service.isCompletedToday(habit, today), isFalse);
      });

      test('should handle time-only differences correctly', () {
        final today = DateTime(2023, 6, 15, 14, 30); // 2:30 PM
        final todayMorning = DateTime(2023, 6, 15, 8, 0); // 8:00 AM same day
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          intervalDays: 1,
        ).copyWith(
          lastCompletionDate: todayMorning, // Completed this morning
        );

        expect(service.isCompletedToday(habit, today), isTrue);
      });
    });
  });
}

// Helper extension for testing (mimics what would be in the domain)
extension HabitTestHelpers on Habit {
  Habit copyWith({
    DateTime? lastCompletionDate,
    int? displayOrder,
  }) {
    return Habit(
      id: id,
      name: name,
      description: description,
      type: type,
      stackedOnHabitId: stackedOnHabitId,
      bundleChildIds: bundleChildIds,
      parentBundleId: parentBundleId,
      parentStackId: parentStackId,
      stackChildIds: stackChildIds,
      currentChildIndex: currentChildIndex,
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
      intervalDays: intervalDays,
      weekdayMask: weekdayMask,
      lastCompletionDate: lastCompletionDate ?? this.lastCompletionDate,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}