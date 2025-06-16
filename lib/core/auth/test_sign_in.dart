import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/supabase_client.dart';

/// Test authentication helper for development and integration testing
class TestSignIn {
  static final _logger = Logger();

  /// Signs in with test credentials based on device configuration
  ///
  /// Uses --dart-define DEVICE=A or DEVICE=B to determine which test account to use
  /// Falls back to device A credentials if DEVICE is not specified
  static Future<bool> signInTestUser() async {
    try {
      // Check if already authenticated
      final currentSession = supabase.auth.currentSession;
      if (currentSession != null) {
        _logger.i('Already authenticated as: ${currentSession.user.email}');
        return true;
      }

      // Determine which device credentials to use
      const device = String.fromEnvironment('DEVICE', defaultValue: 'A');
      _logger.i('Signing in as test device: $device');

      final email = device == 'B'
          ? dotenv.env['TEST_EMAIL_B']
          : dotenv.env['TEST_EMAIL_A'];

      final password = device == 'B'
          ? dotenv.env['TEST_PASSWORD_B']
          : dotenv.env['TEST_PASSWORD_A'];

      if (email == null || password == null) {
        _logger.e('Test credentials not found in .env for device $device');
        return false;
      }

      _logger.i('Attempting test sign-in with: $email');

      // Try to sign in first
      AuthResponse response;
      try {
        response = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } on AuthException catch (e) {
        if (e.statusCode == 400 &&
            e.message.contains('Invalid login credentials')) {
          // User doesn't exist, try to create them
          _logger.i('User not found, creating test user: $email');
          response = await supabase.auth.signUp(
            email: email,
            password: password,
          );

          if (response.user != null && response.session != null) {
            _logger.i('Test user created and signed in successfully');
          } else {
            _logger.w('User created but needs email confirmation');
            // For testing, we can try to sign in again after a brief delay
            await Future.delayed(const Duration(seconds: 2));
            response = await supabase.auth.signInWithPassword(
              email: email,
              password: password,
            );
          }
        } else {
          rethrow;
        }
      }

      if (response.session != null) {
        _logger.i('Successfully authenticated as: ${response.user?.email}');
        _logger.d('User ID: ${response.user?.id}');
        return true;
      } else {
        _logger.e('Authentication succeeded but no session created');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e('Test authentication failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Signs out the current user
  static Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      _logger.i('Test user signed out successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to sign out test user',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Gets the current authenticated user ID
  static String? getCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }

  /// Gets the current authenticated user email
  static String? getCurrentUserEmail() {
    return supabase.auth.currentUser?.email;
  }

  /// Checks if a user is currently authenticated
  static bool get isAuthenticated {
    return supabase.auth.currentSession != null;
  }

  /// Creates both test users if they don't exist
  /// Useful for initial setup and CI environments
  static Future<void> ensureTestUsersExist() async {
    final testUsers = [
      {
        'email': dotenv.env['TEST_EMAIL_A'],
        'password': dotenv.env['TEST_PASSWORD_A'],
        'device': 'A',
      },
      {
        'email': dotenv.env['TEST_EMAIL_B'],
        'password': dotenv.env['TEST_PASSWORD_B'],
        'device': 'B',
      },
    ];

    for (final user in testUsers) {
      final email = user['email'];
      final password = user['password'];
      final device = user['device'];

      if (email == null || password == null) {
        _logger.w('Missing credentials for test device $device');
        continue;
      }

      try {
        // Try to sign up (will fail if user already exists)
        await supabase.auth.signUp(email: email, password: password);
        _logger.i('Created test user for device $device: $email');
      } on AuthException catch (e) {
        if (e.message.contains('already registered')) {
          _logger.d('Test user already exists for device $device: $email');
        } else {
          _logger
              .w('Failed to create test user for device $device: ${e.message}');
        }
      } catch (e) {
        _logger.e('Unexpected error creating test user for device $device',
            error: e);
      }
    }
  }
}
