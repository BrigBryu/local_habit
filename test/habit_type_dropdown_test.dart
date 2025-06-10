import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_level_up/features/habits/bundle_habit/add_bundle_habit_screen.dart';

void main() {
  group('Habit Type Dropdown Tests', () {
    testWidgets('dropdown shows and contains habit types', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: AddBundleHabitScreen(),
        ),
      ));

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Check that the dropdown exists
      expect(find.text('Habit type'), findsOneWidget);

      // Find the dropdown button
      final dropdownFinder = find.byType(DropdownButtonFormField<String>);
      expect(dropdownFinder, findsOneWidget);

      // Tap the dropdown to open it
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      // Verify the dropdown options are present
      expect(find.text('Basic'), findsOneWidget);
      expect(find.text('Bundle'), findsOneWidget);
      expect(find.text('Avoidance'), findsOneWidget);
    });

    testWidgets('dropdown shows current selection', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: AddBundleHabitScreen(),
        ),
      ));

      await tester.pumpAndSettle();

      // The bundle screen should show 'Bundle' as selected
      final dropdownFinder = find.byType(DropdownButtonFormField<String>);
      final dropdown = tester.widget<DropdownButtonFormField<String>>(dropdownFinder);
      expect(dropdown.value, equals('/add-bundle-habit'));
    });
  });
}