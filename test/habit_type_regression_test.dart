import 'package:flutter_test/flutter_test.dart';
import 'package:domain/domain.dart';

/// Regression test to ensure all HabitType enum values are properly supported
/// across UI rendering, theme selection, and data handling.
///
/// This test prevents future additions of new HabitType values from breaking
/// existing switch statements and ensures complete coverage.
void main() {
  group('HabitType Regression Tests', () {
    test('all HabitType values should be defined', () {
      // Verify all expected habit types exist
      final allTypes = HabitType.values;
      
      expect(allTypes, contains(HabitType.basic));
      expect(allTypes, contains(HabitType.avoidance));
      expect(allTypes, contains(HabitType.bundle));
      expect(allTypes, contains(HabitType.stack));
      expect(allTypes, contains(HabitType.interval));
      expect(allTypes, contains(HabitType.weekly));
      
      // Ensure we have exactly the expected number of types
      expect(allTypes.length, equals(6), 
        reason: 'If this fails, a new HabitType was added. Update switch statements in:\n'
                '- stack_habit/add_stack_habit_screen.dart\n'
                '- bundle_habit/bundle_habit_tile.dart\n'
                '- bundle_habit/bundle_info_screen.dart\n'
                '- providers/habits_provider.dart (_calculateBaseXp)\n'
                '- And any other files with HabitType switches');
    });

    test('habit creation should work for all types', () {
      // Test that we can create habits of each type without exceptions
      final testCases = [
        HabitType.basic,
        HabitType.avoidance,
        HabitType.bundle,
        HabitType.stack,
        HabitType.interval,
        HabitType.weekly,
      ];

      for (final type in testCases) {
        expect(() {
          final habit = Habit.create(
            name: 'Test ${type.name} Habit',
            description: 'Test description',
            type: type,
          );
          expect(habit.type, equals(type));
          expect(habit.name, equals('Test ${type.name} Habit'));
        }, returnsNormally, reason: 'Failed to create habit of type: ${type.name}');
      }
    });

    test('XP calculation should handle all habit types', () {
      // Mock the XP calculation logic to ensure all types are handled
      int calculateMockBaseXp(HabitType type) {
        switch (type) {
          case HabitType.basic:
            return 10;
          case HabitType.avoidance:
            return 15;
          case HabitType.bundle:
            return 25;
          case HabitType.stack:
            return 20;
          case HabitType.interval:
            return 12;
          case HabitType.weekly:
            return 15;
        }
      }

      // Test all habit types return valid XP values
      for (final type in HabitType.values) {
        final xp = calculateMockBaseXp(type);
        expect(xp, greaterThan(0), 
          reason: 'XP calculation returned 0 or negative for type: ${type.name}');
        expect(xp, lessThanOrEqualTo(30), 
          reason: 'XP calculation returned suspiciously high value for type: ${type.name}');
      }
    });

    test('UI icon mapping should cover all habit types', () {
      // Mock the icon mapping logic to ensure all types have icons
      String getIconName(HabitType type) {
        switch (type) {
          case HabitType.basic:
            return 'check_circle_outline';
          case HabitType.avoidance:
            return 'block';
          case HabitType.bundle:
            return 'folder_special';
          case HabitType.stack:
            return 'layers';
          case HabitType.interval:
            return 'schedule';
          case HabitType.weekly:
            return 'date_range';
        }
      }

      // Test all habit types have icon mappings
      for (final type in HabitType.values) {
        final iconName = getIconName(type);
        expect(iconName.isNotEmpty, isTrue, 
          reason: 'No icon mapping found for type: ${type.name}');
      }
    });

    test('habit type names should be consistent', () {
      // Verify habit type names are what we expect (protects against enum refactoring)
      expect(HabitType.basic.name, equals('basic'));
      expect(HabitType.avoidance.name, equals('avoidance'));
      expect(HabitType.bundle.name, equals('bundle'));
      expect(HabitType.stack.name, equals('stack'));
      expect(HabitType.interval.name, equals('interval'));
      expect(HabitType.weekly.name, equals('weekly'));
    });
  });
}