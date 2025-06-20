import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../lib/features/habits/common/deletable_habit_tile.dart';
import '../lib/features/habits/basic_habit/basic_habit_tile.dart';
import '../lib/providers/habits_provider.dart';
import '../lib/core/repositories/simple_memory_repository.dart';
import '../lib/core/theme/flexible_theme_system.dart';

void main() {
  group('UI Enhancements', () {
    late SimpleMemoryRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = SimpleMemoryRepository();
      container = ProviderContainer(
        overrides: [
          habitsRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Delete Habit Functionality', () {
      testWidgets('should show delete confirmation dialog on long press', (tester) async {
        final habit = Habit.create(
          name: 'Test Habit',
          description: 'Test Description',
          type: HabitType.basic,
        );

        await repository.addHabit(habit);

        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: MaterialApp(
              home: Scaffold(
                body: DeletableHabitTile(
                  habit: habit,
                  child: Container(
                    height: 100,
                    child: Text('Habit Tile'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Long press to trigger delete confirmation
        await tester.longPress(find.text('Habit Tile'));
        await tester.pumpAndSettle();

        // Should show confirmation dialog
        expect(find.text('Delete Habit'), findsOneWidget);
        expect(find.text('Delete "Test Habit" permanently?'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('should cancel delete when cancel is pressed', (tester) async {
        final habit = Habit.create(
          name: 'Test Habit',
          description: 'Test Description',
          type: HabitType.basic,
        );

        await repository.addHabit(habit);

        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: MaterialApp(
              home: Scaffold(
                body: DeletableHabitTile(
                  habit: habit,
                  child: Container(
                    height: 100,
                    child: Text('Habit Tile'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Long press to trigger delete confirmation
        await tester.longPress(find.text('Habit Tile'));
        await tester.pumpAndSettle();

        // Press cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Dialog should be dismissed
        expect(find.text('Delete Habit'), findsNothing);

        // Habit should still exist
        expect(repository.habits.length, equals(1));
        expect(repository.habits.first.name, equals('Test Habit'));
      });

      testWidgets('should delete habit when delete is confirmed', (tester) async {
        final habit = Habit.create(
          name: 'Test Habit',
          description: 'Test Description',
          type: HabitType.basic,
        );

        await repository.addHabit(habit);
        expect(repository.habits.length, equals(1));

        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: MaterialApp(
              home: Scaffold(
                body: DeletableHabitTile(
                  habit: habit,
                  child: Container(
                    height: 100,
                    child: Text('Habit Tile'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Long press to trigger delete confirmation
        await tester.longPress(find.text('Habit Tile'));
        await tester.pumpAndSettle();

        // Press delete
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        // Habit should be deleted
        expect(repository.habits.length, equals(0));
      });

      testWidgets('should show delete background on swipe', (tester) async {
        final habit = Habit.create(
          name: 'Test Habit',
          description: 'Test Description',
          type: HabitType.basic,
        );

        await repository.addHabit(habit);

        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: MaterialApp(
              home: Scaffold(
                body: DeletableHabitTile(
                  habit: habit,
                  child: Container(
                    height: 100,
                    width: 300,
                    child: Text('Habit Tile'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Start swiping left
        await tester.drag(find.text('Habit Tile'), const Offset(-100, 0));
        await tester.pump();

        // Should show delete background
        expect(find.text('Delete'), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsOneWidget);
      });
    });

    group('Display Order Functionality', () {
      test('should create habits with default display order', () {
        final habit1 = Habit.create(
          name: 'First Habit',
          description: 'Test',
          type: HabitType.basic,
        );

        final habit2 = Habit.create(
          name: 'Second Habit',
          description: 'Test',
          type: HabitType.basic,
        );

        expect(habit1.displayOrder, equals(999999));
        expect(habit2.displayOrder, equals(999999));
      });

      test('should create habits with custom display order', () {
        final habit = Habit.create(
          name: 'Custom Order Habit',
          description: 'Test',
          type: HabitType.basic,
          displayOrder: 5000,
        );

        expect(habit.displayOrder, equals(5000));
      });

      test('should preserve display order in JSON serialization', () {
        final habit = Habit.create(
          name: 'Test Habit',
          description: 'Test',
          type: HabitType.basic,
          displayOrder: 2500,
        );

        final json = habit.toJson();
        expect(json['displayOrder'], equals(2500));

        final reconstructed = Habit.fromJson(json);
        expect(reconstructed.displayOrder, equals(2500));
      });

      test('should handle missing displayOrder in JSON with default', () {
        final json = {
          'id': 'test_id',
          'name': 'Test Habit',
          'description': 'Test',
          'type': 'basic',
          'createdAt': DateTime.now().toIso8601String(),
          'dailyCompletionCount': 0,
          'dailyFailureCount': 0,
          'avoidanceSuccessToday': false,
          'currentStreak': 0,
          'sessionCompletedToday': false,
          // displayOrder deliberately omitted
        };

        final habit = Habit.fromJson(json);
        expect(habit.displayOrder, equals(999999)); // Default value
      });

      test('should update display order for multiple habits', () async {
        final habit1 = Habit.create(
          name: 'First',
          description: 'Test',
          type: HabitType.basic,
          displayOrder: 1000,
        );

        final habit2 = Habit.create(
          name: 'Second',
          description: 'Test',
          type: HabitType.basic,
          displayOrder: 2000,
        );

        final habit3 = Habit.create(
          name: 'Third',
          description: 'Test',
          type: HabitType.basic,
          displayOrder: 3000,
        );

        await repository.addHabit(habit1);
        await repository.addHabit(habit2);
        await repository.addHabit(habit3);

        final habitsNotifier = HabitsNotifier(repository, container);

        // Reorder: move first habit to last position
        final reorderedHabits = [habit2, habit3, habit1];
        final result = await habitsNotifier.updateHabitOrder(reorderedHabits);

        expect(result, isNull); // No error

        // Check that habits were updated with new display orders
        final updatedHabits = repository.habits;
        updatedHabits.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

        expect(updatedHabits[0].name, equals('Second'));
        expect(updatedHabits[0].displayOrder, equals(0));
        expect(updatedHabits[1].name, equals('Third'));
        expect(updatedHabits[1].displayOrder, equals(1000));
        expect(updatedHabits[2].name, equals('First'));
        expect(updatedHabits[2].displayOrder, equals(2000));
      });
    });

    group('Completion State Visual Feedback', () {
      test('should maintain completion date for interval habits', () {
        final today = DateTime(2023, 6, 15);
        final habit = Habit.create(
          name: 'Test Interval',
          description: 'Test',
          type: HabitType.interval,
          intervalDays: 3,
        );

        // Complete the habit
        final completedHabit = habit.complete();
        
        // Check that lastCompletionDate was set for interval habit
        expect(completedHabit.lastCompletionDate, isNotNull);
        expect(completedHabit.lastCompletionDate?.year, equals(today.year));
        expect(completedHabit.lastCompletionDate?.month, equals(today.month));
        expect(completedHabit.lastCompletionDate?.day, equals(today.day));
      });

      test('should maintain completion date for weekly habits', () {
        final today = DateTime(2023, 6, 19); // A Monday
        final habit = Habit.create(
          name: 'Test Weekly',
          description: 'Test',
          type: HabitType.weekly,
          weekdayMask: 1 << 1, // Monday
        );

        // Complete the habit
        final completedHabit = habit.complete();
        
        // Check that lastCompletionDate was set for weekly habit
        expect(completedHabit.lastCompletionDate, isNotNull);
        expect(completedHabit.lastCompletionDate?.year, equals(today.year));
        expect(completedHabit.lastCompletionDate?.month, equals(today.month));
        expect(completedHabit.lastCompletionDate?.day, equals(today.day));
      });

      test('should not set completion date for basic habits', () {
        final habit = Habit.create(
          name: 'Test Basic',
          description: 'Test',
          type: HabitType.basic,
        );

        // Complete the habit
        final completedHabit = habit.complete();
        
        // Check that lastCompletionDate was not set for basic habit
        expect(completedHabit.lastCompletionDate, isNull);
      });
    });
  });
}

// Helper extension for testing
extension HabitTestExtensions on Habit {
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