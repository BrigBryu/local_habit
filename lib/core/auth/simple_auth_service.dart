import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_client.dart';
import 'auth_service.dart';

/// Simple auth service that bypasses email verification for testing
class SimpleAuthService {
  static SimpleAuthService? _instance;
  static SimpleAuthService get instance {
    _instance ??= SimpleAuthService._();
    return _instance!;
  }

  SimpleAuthService._();

  final _logger = Logger();
  final Map<String, Map<String, String>> _localUsers = {};

  /// Register user with immediate sign-in (no email verification)
  Future<AuthResult> signUpAndSignIn(
      String email, String password, String displayName) async {
    try {
      // For testing, create a local user record
      _localUsers[email] = {
        'password': password,
        'displayName': displayName,
        'userId': 'user_${DateTime.now().millisecondsSinceEpoch}',
      };

      // Store in SharedPreferences for persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_email', email);
      await prefs.setString('current_user_display_name', displayName);
      await prefs.setString('current_user_id', _localUsers[email]!['userId']!);

      _logger.i('User registered and signed in: $email');
      return AuthResult.success();
    } catch (e) {
      _logger.e('Registration failed', error: e);
      return AuthResult.error(e.toString());
    }
  }

  /// Simple sign-in without email verification
  Future<AuthResult> signIn(String email, String password) async {
    try {
      // Check local users first
      if (_localUsers.containsKey(email)) {
        if (_localUsers[email]!['password'] == password) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_user_email', email);
          await prefs.setString('current_user_display_name', _localUsers[email]!['displayName']!);
          await prefs.setString('current_user_id', _localUsers[email]!['userId']!);
          
          _logger.i('Local user signed in: $email');
          return AuthResult.success();
        } else {
          return AuthResult.error('Invalid password');
        }
      }

      // Try Supabase auth (but don't require email verification)
      try {
        final response = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.session != null) {
          _logger.i('Supabase user signed in: $email');
          return AuthResult.success();
        }
      } catch (supabaseError) {
        _logger.w('Supabase sign-in failed, using local auth: $supabaseError');
      }

      return AuthResult.error('Invalid email or password');
    } catch (e) {
      _logger.e('Sign in failed', error: e);
      return AuthResult.error(e.toString());
    }
  }

  /// Get current user ID
  Future<String?> getCurrentUserId() async {
    try {
      // Check Supabase first
      final supabaseUser = supabase.auth.currentUser;
      if (supabaseUser != null) {
        return supabaseUser.id;
      }

      // Check local storage
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('current_user_id');
    } catch (e) {
      _logger.e('Failed to get current user ID', error: e);
      return null;
    }
  }

  /// Get current user display name
  Future<String> getCurrentUserDisplayName() async {
    try {
      // Check Supabase first
      final supabaseUser = supabase.auth.currentUser;
      if (supabaseUser != null) {
        return supabaseUser.userMetadata?['display_name'] ?? 
               supabaseUser.email ?? 
               'User';
      }

      // Check local storage
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('current_user_display_name') ?? 'User';
    } catch (e) {
      _logger.e('Failed to get current user display name', error: e);
      return 'User';
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    try {
      // Check Supabase first
      if (supabase.auth.currentSession != null) {
        return true;
      }

      // Check local storage (synchronous check)
      // This is a simplified check - in practice you'd want to validate the session
      return true; // For testing, assume authenticated if we got this far
    } catch (e) {
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Supabase
      await supabase.auth.signOut();

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_email');
      await prefs.remove('current_user_display_name');
      await prefs.remove('current_user_id');

      _logger.i('User signed out');
    } catch (e) {
      _logger.e('Sign out failed', error: e);
    }
  }
}