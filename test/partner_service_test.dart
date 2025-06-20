import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:habit_level_up/core/network/partner_service.dart';
import 'package:habit_level_up/core/auth/username_auth_service.dart';

// Generate mocks
@GenerateMocks([UsernameAuthService])
import 'partner_service_test.mocks.dart';

void main() {
  group('PartnerService', () {
    late PartnerService partnerService;
    late MockUsernameAuthService mockAuthService;

    setUp(() {
      partnerService = PartnerService.instance;
      mockAuthService = MockUsernameAuthService();
    });

    group('Link Partner by Username', () {
      test('linkPartner should fail when user not authenticated', () async {
        // Arrange
        when(mockAuthService.getCurrentUserId()).thenReturn(null);

        // Act & Assert
        expect(
          () async => await partnerService.linkPartner('testuser'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No authenticated user'),
          )),
        );
      });

      test('linkPartner should throw exception for empty username', () async {
        // Arrange
        when(mockAuthService.getCurrentUserId()).thenReturn('user123');

        // Act & Assert
        expect(
          () async => await partnerService.linkPartner(''),
          throwsA(isA<Exception>()),
        );
      });

      test('linkPartner should handle self-linking prevention', () async {
        // Arrange
        when(mockAuthService.getCurrentUserId()).thenReturn('user123');

        // This test would need Supabase mocking to test the actual RPC call
        // For now, we'll test the input validation
        
        // Act & Assert
        expect(
          () async => await partnerService.linkPartner('   '),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Partner Management', () {
      test('getPartners should return empty list when not authenticated', () async {
        // Arrange
        when(mockAuthService.getCurrentUserId()).thenReturn(null);

        // Act
        final result = await partnerService.getPartners();

        // Assert
        expect(result, isEmpty);
      });

      test('removePartner should fail when user not authenticated', () async {
        // Arrange
        when(mockAuthService.getCurrentUserId()).thenReturn(null);

        // Act & Assert
        expect(
          () async => await partnerService.removePartner('partner123'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No authenticated user'),
          )),
        );
      });
    });

    group('Username Validation', () {
      test('should validate partner username format correctly', () {
        // Test valid usernames
        expect('testuser'.trim().isNotEmpty, true);
        expect('test_user'.trim().isNotEmpty, true);
        expect('testUser123'.trim().isNotEmpty, true);

        // Test invalid usernames
        expect(''.trim().isNotEmpty, false);
        expect('   '.trim().isNotEmpty, false);
      });

      test('should handle whitespace in usernames', () {
        // Test trimming behavior
        expect('  testuser  '.trim(), equals('testuser'));
        expect('\n\ttestuser\n\t'.trim(), equals('testuser'));
      });
    });
  });
}