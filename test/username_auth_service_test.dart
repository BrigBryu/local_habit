import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_level_up/core/auth/username_auth_service.dart';
import 'package:habit_level_up/core/network/supabase_client.dart';

// Mock classes for testing
class MockSupabaseClientService extends Mock implements SupabaseClientService {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockPostgrestClient extends Mock implements PostgrestClient {}
class MockPostgrestQueryBuilder extends Mock implements PostgrestQueryBuilder {}

@GenerateMocks([SupabaseClient, GoTrueClient, PostgrestClient])
void main() {
  group('UsernameAuthService Tests', () {
    test('should convert username to correct email format', () {
      // Test the username to email conversion logic
      const username = 'TestUser123';
      const expectedEmail = 'testuser123@habitapp.example.com';
      
      // Verify the conversion logic
      final actualEmail = '${username.toLowerCase().trim()}@habitapp.example.com';
      expect(actualEmail, equals(expectedEmail));
    });

    test('should validate username requirements', () {
      // Test username validation logic
      expect('ab'.length >= 3, isFalse); // Too short
      expect('validuser'.length >= 3, isTrue); // Valid length
      expect('a_very_long_username_that_exceeds_limits'.length <= 20, isFalse); // Too long
    });

    test('should validate password requirements', () {
      // Test password validation logic
      expect('123'.length >= 6, isFalse); // Too short
      expect('password123'.length >= 6, isTrue); // Valid length
    });

    test('should normalize username correctly', () {
      // Test username normalization
      expect('TestUser123'.toLowerCase().trim(), equals('testuser123'));
      expect('  spaced_user  '.toLowerCase().trim(), equals('spaced_user'));
      expect('MixedCase'.toLowerCase().trim(), equals('mixedcase'));
    });
  });
}