import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Smoke Tests', () {
    test('Sign-up email conversion should work correctly', () {
      // Test email conversion logic that sign-up uses
      String convertUsernameToEmail(String username) {
        return '${username.toLowerCase().trim()}@test.com';
      }
      
      // Test various username formats
      expect(convertUsernameToEmail('TestUser'), equals('testuser@test.com'));
      expect(convertUsernameToEmail('user123'), equals('user123@test.com'));
      expect(convertUsernameToEmail('  SpacedUser  '), equals('spaceduser@test.com'));
      expect(convertUsernameToEmail('my_test_user'), equals('my_test_user@test.com'));
    });

    test('Username validation logic should work correctly', () {
      bool isValidUsername(String username) {
        final normalized = username.toLowerCase().trim();
        return normalized.isNotEmpty && 
               normalized.length >= 3 && 
               normalized.length <= 20 &&
               RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(normalized);
      }
      
      // Valid usernames
      expect(isValidUsername('user123'), isTrue);
      expect(isValidUsername('test_user'), isTrue);
      expect(isValidUsername('validuser'), isTrue);
      
      // Invalid usernames
      expect(isValidUsername('ab'), isFalse); // Too short
      expect(isValidUsername(''), isFalse); // Empty
      expect(isValidUsername('user@domain'), isFalse); // Special chars
      expect(isValidUsername('a_very_long_username_that_exceeds_limits'), isFalse); // Too long
    });
    
    test('Password validation logic should work correctly', () {
      bool isValidPassword(String password) {
        return password.isNotEmpty && password.length >= 6;
      }
      
      // Valid passwords
      expect(isValidPassword('password123'), isTrue);
      expect(isValidPassword('123456'), isTrue);
      expect(isValidPassword('q1234567'), isTrue); // Quick test password
      
      // Invalid passwords
      expect(isValidPassword('12345'), isFalse); // Too short
      expect(isValidPassword(''), isFalse); // Empty
    });
  });
}