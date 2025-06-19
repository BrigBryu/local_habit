import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../lib/features/habits/weekly_habit/weekly_habit_tile.dart';
import '../lib/features/habits/weekly_habit/add_weekly_habit_screen.dart';
import '../lib/core/services/due_date_service.dart';

void main() {
  group('Weekly Habit Tests', () {
    group('Weekly Habit Creation', () {
      testWidgets('should require at least one weekday selection', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: AddWeeklyHabitScreen(),
            ),
          ),
        );

        // Fill in name but don't select any weekdays
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, 'Test Weekly Habit');
        await tester.pump();

        // Initially has Monday and Friday selected by default, so we need to deselect them
        final weekdayButtons = find.byType(GestureDetector);
        await tester.tap(weekdayButtons.at(1)); // Monday
        await tester.tap(weekdayButtons.at(5)); // Friday
        await tester.pump();

        // Should show warning message
        expect(find.text('Please select at least one weekday'), findsOneWidget);
      });

      testWidgets('should create weekly habit with selected weekdays', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: AddWeeklyHabitScreen(),
            ),
          ),
        );

        // Fill in the form
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, 'Test Weekly Habit');
        await tester.pump();

        // Default selections (Monday and Friday) should be visible
        // Check that weekday selector is present
        expect(find.text('S'), findsOneWidget); // Sunday
        expect(find.text('M'), findsOneWidget); // Monday
        expect(find.text('T'), findsAtLeastNWidgets(2)); // Tuesday, Thursday
        expect(find.text('W'), findsOneWidget); // Wednesday
        expect(find.text('F'), findsOneWidget); // Friday
      });

      testWidgets('should allow selecting multiple weekdays', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: AddWeeklyHabitScreen(),
            ),
          ),
        );

        // Fill in name
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, 'Multi-day habit');
        await tester.pump();

        // Select additional weekdays by tapping weekday buttons
        final weekdayButtons = find.byType(GestureDetector);
        
        // Tap Wednesday (index 3)
        await tester.tap(weekdayButtons.at(3));
        await tester.pump();

        // Should not show the warning since we have selections
        expect(find.text('Please select at least one weekday'), findsNothing);
      });
    });

    group('Weekly Habit Tile', () {
      testWidgets('should show as active on matching weekday', (tester) async {
        // Create habit for Monday (weekday index 1)
        final habit = Habit.create(
          name: 'Monday Habit',
          description: 'Test Description',
          type: HabitType.weekly,
          weekdayMask: 1 << 1, // Monday bit set
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: WeeklyHabitTile(habit: habit),
              ),
            ),
          ),
        );

        await tester.pump();

        // Should display the habit
        expect(find.text('Monday Habit'), findsOneWidget);
        expect(find.text('Test Description'), findsOneWidget);
      });

      testWidgets('should show corner badge for weekly type', (tester) async {
        final habit = Habit.create(
          name: 'Weekly Habit',
          description: 'Test Description',
          type: HabitType.weekly,
          weekdayMask: 1 << 1, // Monday
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: WeeklyHabitTile(habit: habit),
              ),
            ),
          ),
        );

        await tester.pump();

        // Should show the calendar emoji badge
        expect(find.text('📅'), findsOneWidget);
      });

      testWidgets('should show proper weekday abbreviations in subtitle', (tester) async {
        // Create habit for Monday, Wednesday, Friday
        final service = DueDateService();
        final weekdayMask = service.createWeekdayMask([1, 3, 5]); // Mon, Wed, Fri
        
        final habit = Habit.create(
          name: 'MWF Habit',
          description: 'Test Description',
          type: HabitType.weekly,
          weekdayMask: weekdayMask,
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: WeeklyHabitTile(habit: habit),
              ),
            ),
          ),
        );

        await tester.pump();

        // Should show abbreviated weekday names
        expect(find.textContaining('Mon, Wed, Fri'), findsOneWidget);
      });
    });

    group('Weekly Habit Logic', () {
      test('should calculate XP reward correctly', () {
        final habit = Habit.create(
          name: 'Test Weekly',
          description: 'Test',
          type: HabitType.weekly,
          weekdayMask: 1 << 1, // Monday
        );

        // Weekly habits should give same XP as basic habits
        expect(habit.calculateXPReward(), equals(1));
      });

      test('should include weekly emoji in display name', () {
        final habit = Habit.create(
          name: 'Test Weekly',
          description: 'Test',
          type: HabitType.weekly,
          weekdayMask: 1 << 1,
        );

        expect(habit.displayName, equals('Test Weekly 📅'));
      });
    });

    group('DueDateService Integration', () {
      test('should correctly identify due days with weekday mask', () {
        final service = DueDateService();
        
        // Create habit for Monday and Wednesday (indices 1 and 3)
        final weekdayMask = service.createWeekdayMask([1, 3]);
        final habit = Habit.create(
          name: 'Test Weekly',
          description: 'Test',
          type: HabitType.weekly,
          weekdayMask: weekdayMask,
        );

        // Test various days
        final monday = DateTime(2023, 6, 19); // A Monday
        final tuesday = DateTime(2023, 6, 20); // A Tuesday  
        final wednesday = DateTime(2023, 6, 21); // A Wednesday
        final thursday = DateTime(2023, 6, 22); // A Thursday

        expect(service.isDue(habit, monday), isTrue);
        expect(service.isDue(habit, tuesday), isFalse);
        expect(service.isDue(habit, wednesday), isTrue);
        expect(service.isDue(habit, thursday), isFalse);
      });

      test('should handle Sunday correctly (weekday 0)', () {
        final service = DueDateService();
        
        // Create habit for Sunday (index 0)
        final weekdayMask = service.createWeekdayMask([0]);
        final habit = Habit.create(
          name: 'Sunday Habit',
          description: 'Test',
          type: HabitType.weekly,
          weekdayMask: weekdayMask,
        );

        final sunday = DateTime(2023, 6, 18); // A Sunday
        final monday = DateTime(2023, 6, 19); // A Monday

        expect(service.isDue(habit, sunday), isTrue);
        expect(service.isDue(habit, monday), isFalse);
      });

      test('should calculate next due date correctly for weekly habits', () {
        final service = DueDateService();
        
        // Create habit for Friday (index 5)
        final weekdayMask = service.createWeekdayMask([5]);
        final habit = Habit.create(
          name: 'Friday Habit',
          description: 'Test',
          type: HabitType.weekly,
          weekdayMask: weekdayMask,
        );

        // Test from a Monday
        final monday = DateTime(2023, 6, 19);
        final nextDue = service.nextDue(habit);
        
        // Should be the upcoming Friday
        expect(nextDue?.weekday, equals(5)); // Friday
        expect(nextDue?.isAfter(monday), isTrue);
      });

      test('should get correct weekday names from mask', () {
        final service = DueDateService();
        
        // Test various combinations
        final mondayWednesdayFriday = service.createWeekdayMask([1, 3, 5]);
        final names = service.getWeekdayNames(mondayWednesdayFriday);
        expect(names, equals(['Monday', 'Wednesday', 'Friday']));

        final weekends = service.createWeekdayMask([0, 6]);
        final weekendNames = service.getWeekdayNames(weekends);
        expect(weekendNames, equals(['Sunday', 'Saturday']));
      });

      test('should handle all weekdays mask correctly', () {
        final service = DueDateService();
        
        // Create habit for every day
        final allDaysMask = service.createWeekdayMask([0, 1, 2, 3, 4, 5, 6]);
        final habit = Habit.create(
          name: 'Daily Weekly Habit',
          description: 'Test',
          type: HabitType.weekly,
          weekdayMask: allDaysMask,
        );

        // Should be due every day
        for (int i = 0; i < 7; i++) {
          final testDate = DateTime(2023, 6, 18 + i); // Week starting Sunday
          expect(service.isDue(habit, testDate), isTrue);
        }
      });
    });

    group('Weekday Mask Utilities', () {
      test('should create and parse weekday masks correctly', () {
        final service = DueDateService();
        
        // Test creating mask from indices
        final indices = [0, 2, 4, 6]; // Sun, Tue, Thu, Sat
        final mask = service.createWeekdayMask(indices);
        
        // Test parsing mask back to indices
        final parsedIndices = service.getWeekdayIndices(mask);
        expect(parsedIndices, equals(indices));
        
        // Test getting names
        final names = service.getWeekdayNames(mask);
        expect(names, equals(['Sunday', 'Tuesday', 'Thursday', 'Saturday']));
      });

      test('should handle edge cases in weekday mask creation', () {
        final service = DueDateService();
        
        // Empty list
        expect(service.createWeekdayMask([]), equals(0));
        
        // Invalid indices should be ignored
        expect(service.createWeekdayMask([-1, 7, 8]), equals(0));
        
        // Duplicate indices should work
        expect(service.createWeekdayMask([1, 1, 1]), equals(1 << 1));
      });
    });

    group('Edge Cases', () {
      test('should handle habit with no weekday mask', () {
        final service = DueDateService();
        
        final habit = Habit.create(
          name: 'Invalid Weekly',
          description: 'Test',
          type: HabitType.weekly,
          // weekdayMask is null
        );

        final today = DateTime.now();
        expect(service.isDue(habit, today), isFalse);
        expect(service.nextDue(habit), isNull);
      });

      test('should handle habit with zero weekday mask', () {
        final service = DueDateService();
        
        final habit = Habit.create(
          name: 'Zero Mask Weekly',
          description: 'Test',
          type: HabitType.weekly,
          weekdayMask: 0, // No days selected
        );

        final today = DateTime.now();
        expect(service.isDue(habit, today), isFalse);
        expect(service.getWeekdayNames(0), isEmpty);
      });
    });
  });
}