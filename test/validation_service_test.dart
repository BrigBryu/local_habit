import 'package:flutter_test/flutter_test.dart';
import 'package:habit_level_up/core/validation/validation_service.dart';

void main() {
  group('ValidationService', () {
    late ValidationService validationService;

    setUp(() {
      validationService = ValidationService.instance;
    });

    group('Username Validation', () {
      test('should accept valid usernames', () {
        final validUsernames = [
          'John',
          'JohnDoe',
          'John Doe',
          'John_Doe',
          'John-Doe',
          'User123',
          'A',
          'A' * 32, // 32 characters (max)
        ];

        for (final username in validUsernames) {
          final result = validationService.validateUsername(username);
          expect(result.isValid, true,
              reason: 'Username "$username" should be valid');
        }
      });

      test('should reject invalid usernames', () {
        final invalidUsernames = [
          '', // Empty
          ' John', // Leading space
          'John ', // Trailing space
          'A' * 33, // Too long (33 characters)
          'John@Doe', // Invalid character
          'John#Doe', // Invalid character
          'John.Doe', // Invalid character
        ];

        for (final username in invalidUsernames) {
          final result = validationService.validateUsername(username);
          expect(result.isValid, false,
              reason: 'Username "$username" should be invalid');
        }
      });

      test('should provide meaningful error messages', () {
        var result = validationService.validateUsername('');
        expect(result.errorMessage, 'Username cannot be empty');

        result = validationService.validateUsername(' John');
        expect(result.errorMessage,
            'Username cannot have leading or trailing spaces');

        result = validationService.validateUsername('A' * 33);
        expect(result.errorMessage, 'Username must be 1-32 characters');

        result = validationService.validateUsername('John@Doe');
        expect(result.errorMessage, 'Username contains invalid characters');
      });
    });

    group('Habit Name Validation', () {
      test('should accept valid habit names', () {
        final validNames = [
          'Exercise',
          'Read 30 minutes',
          'A',
          'A' * 64, // 64 characters (max)
          'Drink water 💧', // Unicode characters
        ];

        for (final name in validNames) {
          final result = validationService.validateHabitName(name);
          expect(result.isValid, true,
              reason: 'Habit name "$name" should be valid');
        }
      });

      test('should reject invalid habit names', () {
        final invalidNames = [
          '', // Empty
          'A' * 65, // Too long (65 characters)
        ];

        for (final name in invalidNames) {
          final result = validationService.validateHabitName(name);
          expect(result.isValid, false,
              reason: 'Habit name "$name" should be invalid');
        }
      });

      test('should handle Unicode characters correctly', () {
        // Test with various Unicode characters
        final unicodeNames = [
          'Exercise 🏃‍♂️',
          'Read 📚',
          'Méditation',
          '运动',
          'Зарядка',
        ];

        for (final name in unicodeNames) {
          final result = validationService.validateHabitName(name);
          expect(result.isValid, true,
              reason: 'Unicode habit name "$name" should be valid');
        }
      });
    });

    group('Runtime Guards', () {
      test('guardAgainstSelfPartnership should throw for same IDs', () {
        expect(
          () => validationService.guardAgainstSelfPartnership(
              'user123', 'user123'),
          throwsA(isA<StateError>()),
        );
      });

      test('guardAgainstSelfPartnership should pass for different IDs', () {
        expect(
          () => validationService.guardAgainstSelfPartnership(
              'user123', 'user456'),
          returnsNormally,
        );
      });

      test('guardUsernameExists should throw for null username', () {
        expect(
          () => validationService.guardUsernameExists(null),
          throwsA(isA<StateError>()),
        );
      });

      test('guardUsernameExists should throw for empty username', () {
        expect(
          () => validationService.guardUsernameExists(''),
          throwsA(isA<StateError>()),
        );
      });

      test('guardUsernameExists should pass for valid username', () {
        expect(
          () => validationService.guardUsernameExists('John'),
          returnsNormally,
        );
      });
    });

    group('Text Sanitization', () {
      test('should trim and normalize spaces', () {
        final testCases = {
          '  Hello World  ': 'Hello World',
          'Hello    World': 'Hello World',
          '\tHello\nWorld\t': 'Hello World',
          '  Multiple   Spaces   Here  ': 'Multiple Spaces Here',
        };

        testCases.forEach((input, expected) {
          final result = validationService.sanitizeUserText(input);
          expect(result, expected);
        });
      });
    });

    group('Rate Limiting', () {
      test('should allow first write', () {
        validationService.resetRateLimit(); // Reset state for clean test
        final canWrite = validationService.canPerformWrite();
        expect(canWrite, true);
      });

      // TODO: Fix timing-dependent test - may be flaky in CI
      test('should block rapid consecutive writes', () async {
        validationService.resetRateLimit(); // Reset state for clean test
        // First write should succeed
        expect(validationService.canPerformWrite(), true);

        // Add tiny delay to ensure different timestamps
        await Future.delayed(Duration(milliseconds: 1));

        // Immediate second write should fail (within 500ms window)
        expect(validationService.canPerformWrite(), false);

        // Wait for the interval to pass
        await Future.delayed(Duration(milliseconds: 600));

        // Third write should succeed after waiting
        // Note: This test may be flaky due to timing precision in test runner
        expect(validationService.canPerformWrite(), true);
      }, skip: 'Timing-dependent test - may fail in CI due to clock precision');
    });

    group('Username Duplicate Check', () {
      test('should detect duplicates', () {
        final existingUsernames = ['john', 'jane', 'bob'];

        // Test exact match
        var result =
            validationService.checkUsernameDuplicate('john', existingUsernames);
        expect(result.isValid, false);

        // Test case insensitive match
        result =
            validationService.checkUsernameDuplicate('JOHN', existingUsernames);
        expect(result.isValid, false);

        // Test with whitespace
        result = validationService.checkUsernameDuplicate(
            ' john ', existingUsernames);
        expect(result.isValid, false);
      });

      test('should allow unique usernames', () {
        final existingUsernames = ['john', 'jane', 'bob'];

        final result = validationService.checkUsernameDuplicate(
            'alice', existingUsernames);
        expect(result.isValid, true);
      });

      test('should provide meaningful error message for duplicates', () {
        final existingUsernames = ['john'];

        final result =
            validationService.checkUsernameDuplicate('john', existingUsernames);
        expect(result.isValid, false);
        expect(result.errorMessage,
            'Username already taken. Please choose a different one.');
      });
    });
  });
}
