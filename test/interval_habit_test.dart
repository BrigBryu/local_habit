import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../lib/features/habits/interval_habit/interval_habit_tile.dart';
import '../lib/features/habits/interval_habit/add_interval_habit_screen.dart';
import '../lib/core/services/due_date_service.dart';

void main() {
  group('Interval Habit Tests', () {
    group('Interval Habit Creation', () {
      testWidgets('should validate interval days input', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: AddIntervalHabitScreen(),
            ),
          ),
        );

        // Find the interval input field
        final intervalField = find.byType(TextFormField).last;
        
        // Test invalid input (empty)
        await tester.enterText(intervalField, '');
        await tester.pump();
        
        // Try to save
        final saveButton = find.text('Add Habit');
        await tester.tap(saveButton);
        await tester.pump();
        
        expect(find.text('Required'), findsOneWidget);
        
        // Test invalid input (zero)
        await tester.enterText(intervalField, '0');
        await tester.pump();
        
        // Try to save
        await tester.tap(saveButton);
        await tester.pump();
        
        expect(find.text('Must be ≥ 1'), findsOneWidget);
        
        // Test invalid input (too large)
        await tester.enterText(intervalField, '999');
        await tester.pump();
        
        // Try to save
        await tester.tap(saveButton);
        await tester.pump();
        
        expect(find.text('Must be ≤ 365'), findsOneWidget);
      });

      testWidgets('should create interval habit with valid input', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: AddIntervalHabitScreen(),
            ),
          ),
        );

        // Fill in the form
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, 'Test Interval Habit');
        
        final intervalField = find.byType(TextFormField).last;
        await tester.enterText(intervalField, '5');
        
        await tester.pump();

        // Verify the form is valid
        expect(find.text('Test Interval Habit'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
      });
    });

    group('Interval Habit Tile', () {
      testWidgets('should show as active when due', (tester) async {
        final dueDateService = DueDateService();
        final today = DateTime.now();
        
        // Create a habit that is due (never completed before)
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test Description',
          type: HabitType.interval,
          intervalDays: 3,
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: IntervalHabitTile(habit: habit),
              ),
            ),
          ),
        );

        await tester.pump();

        // Should show as active
        expect(find.text('Test Interval'), findsOneWidget);
        expect(find.text('Due now'), findsOneWidget);
        
        // Should have active colors and be tappable
        final tile = find.byType(IntervalHabitTile);
        expect(tile, findsOneWidget);
      });

      testWidgets('should show as inactive when not due', (tester) async {
        final today = DateTime.now();
        
        // Create a habit that is not due (completed yesterday, 3-day interval)
        final habit = Habit(
          id: 'test-id',
          name: 'Test Interval',
          description: 'Test Description',
          type: HabitType.interval,
          createdAt: today.subtract(const Duration(days: 10)),
          intervalDays: 3,
          lastCompletionDate: today.subtract(const Duration(days: 1)),
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: IntervalHabitTile(habit: habit),
              ),
            ),
          ),
        );

        await tester.pump();

        // Should show as inactive
        expect(find.text('Test Interval'), findsOneWidget);
        expect(find.textContaining('Due in'), findsOneWidget);
        
        // Should show schedule icon instead of completion button
        expect(find.byIcon(Icons.schedule), findsOneWidget);
      });

      testWidgets('should show corner badge for interval type', (tester) async {
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test Description',
          type: HabitType.interval,
          intervalDays: 7,
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: IntervalHabitTile(habit: habit),
              ),
            ),
          ),
        );

        await tester.pump();

        // Should show the rotation symbol badge
        expect(find.text('⟳'), findsOneWidget);
      });
    });

    group('Interval Habit Logic', () {
      test('should calculate XP reward correctly', () {
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          intervalDays: 5,
        );

        // Interval habits should give same XP as basic habits
        expect(habit.calculateXPReward(), equals(1));
      });

      test('should update lastCompletionDate on completion', () {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          intervalDays: 3,
        );

        final completedHabit = habit.complete();

        expect(completedHabit.lastCompletionDate, equals(todayDate));
        expect(completedHabit.currentStreak, equals(1));
      });

      test('should maintain streak correctly for interval habits', () {
        final baseDate = DateTime(2023, 6, 10);
        
        // Create habit completed 3 days ago with 3-day interval
        final habit = Habit(
          id: 'test-id',
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          createdAt: baseDate.subtract(const Duration(days: 10)),
          intervalDays: 3,
          lastCompletionDate: baseDate,
          lastCompleted: baseDate,
          currentStreak: 1,
        );

        // Complete again exactly 3 days later
        final today = baseDate.add(const Duration(days: 3));
        final completedHabit = habit.complete();

        expect(completedHabit.currentStreak, equals(2));
      });
    });

    group('DueDateService Integration', () {
      test('should correctly identify when interval habit is due', () {
        final service = DueDateService();
        final today = DateTime(2023, 6, 15);
        
        // Habit with 5-day interval, last completed 5 days ago
        final habit = Habit(
          id: 'test-id',
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          createdAt: today.subtract(const Duration(days: 20)),
          intervalDays: 5,
          lastCompletionDate: DateTime(2023, 6, 10),
        );

        expect(service.isDue(habit, today), isTrue);
      });

      test('should correctly identify when interval habit is not due', () {
        final service = DueDateService();
        final today = DateTime(2023, 6, 15);
        
        // Habit with 7-day interval, last completed 5 days ago
        final habit = Habit(
          id: 'test-id',
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          createdAt: today.subtract(const Duration(days: 20)),
          intervalDays: 7,
          lastCompletionDate: DateTime(2023, 6, 10),
        );

        expect(service.isDue(habit, today), isFalse);
      });

      test('should calculate next due date correctly', () {
        final service = DueDateService();
        
        final habit = Habit(
          id: 'test-id',
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          createdAt: DateTime(2023, 6, 1),
          intervalDays: 7,
          lastCompletionDate: DateTime(2023, 6, 10),
        );

        final nextDue = service.nextDue(habit);
        expect(nextDue, equals(DateTime(2023, 6, 17)));
      });
    });
  });
}