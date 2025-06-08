import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:habit_level_up/features/home/presentation/pages/home_page.dart';
import 'package:habit_level_up/features/home/presentation/widgets/level_bar.dart';
import 'package:habit_level_up/features/home/presentation/widgets/habit_tile.dart';
import 'package:habit_level_up/features/home/presentation/providers.dart';

void main() {
  group('HomePage Widget Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          homeHabitsProvider.overrideWith((ref) => [
            _createTestHabit('1', 'Test Habit 1', HabitType.basic),
            _createTestHabit('2', 'Test Habit 2', HabitType.avoidance),
          ]),
          levelStateProvider.overrideWith((ref) => {
            'currentLevel': 1,
            'currentXP': 50,
            'nextLevelXP': 100,
            'progress': 0.5,
          }),
          routeAvailabilityProvider.overrideWith((ref) => {
            'addHabit': true,
            'levels': true,
            'viewHabit': false,
          }),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should render without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Verify basic structure is present
      expect(find.byType(LevelBar), findsOneWidget);
      expect(find.text('Today\'s Habits'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Verify no overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display level bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      expect(find.byType(LevelBar), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);
    });

    testWidgets('should display habit tiles when habits exist', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      expect(find.byType(HabitTile), findsNWidgets(2));
      expect(find.text('Test Habit 1'), findsOneWidget);
      expect(find.text('Test Habit 2'), findsOneWidget);
      expect(find.text('2 total'), findsOneWidget);
    });

    testWidgets('should display empty state when no habits exist', (WidgetTester tester) async {
      final emptyContainer = ProviderContainer(
        overrides: [
          homeHabitsProvider.overrideWith((ref) => <Habit>[]),
          levelStateProvider.overrideWith((ref) => {
            'currentLevel': 1,
            'currentXP': 0,
            'nextLevelXP': 100,
            'progress': 0.0,
          }),
          routeAvailabilityProvider.overrideWith((ref) => {
            'addHabit': true,
            'levels': true,
            'viewHabit': false,
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: emptyContainer,
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      expect(find.text('No habits yet'), findsOneWidget);
      expect(find.text('Tap the button below to create your first habit'), findsOneWidget);
      expect(find.text('0 total'), findsOneWidget);

      emptyContainer.dispose();
    });

    testWidgets('should have functional FAB', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      expect(find.text('Add Habit'), findsOneWidget);

      // FAB should be tappable
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Should navigate (though we can't test the actual navigation without more setup)
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle portrait and landscape orientations', (WidgetTester tester) async {
      // Test portrait
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );
      expect(tester.takeException(), isNull);

      // Test landscape
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Reset to default
      await tester.binding.setSurfaceSize(null);
    });
  });
}

Habit _createTestHabit(String id, String name, HabitType type) {
  return Habit(
    id: id,
    name: name,
    description: 'Test description',
    type: type,
    createdAt: DateTime.now(),
  );
}