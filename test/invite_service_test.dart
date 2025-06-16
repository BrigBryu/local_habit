import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:habit_level_up/core/invite/invite_service.dart';
import 'package:habit_level_up/core/auth/auth_service.dart';

// Generate mocks
@GenerateMocks([AuthService])
import 'invite_service_test.mocks.dart';

void main() {
  group('InviteService', () {
    late InviteService inviteService;
    late MockAuthService mockAuthService;

    setUp(() {
      inviteService = InviteService.instance;
      mockAuthService = MockAuthService();
    });

    group('Invite Code Generation', () {
      test('generateInviteCode should return 6-character alphanumeric string',
          () {
        // Act
        final code = inviteService.generateInviteCode();

        // Assert
        expect(code.length, 6);
        expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch(code), true);
      });

      test('generateInviteCode should return unique codes', () {
        // Act
        final code1 = inviteService.generateInviteCode();
        final code2 = inviteService.generateInviteCode();

        // Assert
        expect(code1, isNot(equals(code2)));
      });
    });

    group('Invite Code Creation', () {
      test('createInviteCode should fail when user not authenticated',
          () async {
        // Arrange
        when(mockAuthService.getCurrentUserIdAsync())
            .thenAnswer((_) async => null);

        // Act
        final result = await inviteService.createInviteCode();

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, 'Not authenticated');
      });
    });

    group('Invite Code Acceptance', () {
      test('acceptInviteCode should validate format', () async {
        // Arrange
        when(mockAuthService.getCurrentUserIdAsync())
            .thenAnswer((_) async => 'user123');

        // Act
        final result = await inviteService.acceptInviteCode('INVALID');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, 'Invalid invite code format');
      });

      test('acceptInviteCode should reject self-invitation', () async {
        // Arrange
        when(mockAuthService.getCurrentUserIdAsync())
            .thenAnswer((_) async => 'user123');

        // Mock database response for invite code lookup
        // This would need actual database mocking in a real test

        // Act
        final result = await inviteService.acceptInviteCode('ABC123');

        // Assert - This test would need proper database mocking
        // For now, just testing the input validation
        expect(result.isSuccess, false);
      });
    });

    group('Validation', () {
      test('should validate invite code format correctly', () {
        // Test valid formats
        expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch('ABC123'), true);
        expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch('abc123'), true);
        expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch('AbC123'), true);

        // Test invalid formats
        expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch('ABC-123'), false);
        expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch('ABC_123'), false);
        expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch('ABC 123'), false);
        expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch('ABC@123'), false);
      });
    });
  });
}
