import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/supabase_client.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  AuthService._();

  final _logger = Logger();

  /// Initialize auth service
  static Future<void> init() async {
    final authService = AuthService.instance;
    authService._logger.i('AuthService initialized');
  }

  /// Get current user ID for database operations
  String? getCurrentUserId() {
    try {
      final userId = supabase.auth.currentUser?.id;
      final userEmail = supabase.auth.currentUser?.email;
      _logger.d('🔑 Auth check - User ID: $userId, Email: $userEmail');

      if (userId == null) {
        _logger.w('⚠️ No authenticated user - sign in required');
        return null;
      }

      return userId;
    } catch (e) {
      _logger.e('❌ Failed to get current user ID', error: e);
      return null;
    }
  }

  /// Get current user ID for database operations (async)
  Future<String?> getCurrentUserIdAsync() async {
    try {
      // Check if Supabase is available
      if (SupabaseClientService.instance.isInitialized) {
        final userId = supabase.auth.currentUser?.id;
        final userEmail = supabase.auth.currentUser?.email;
        _logger.d('🔑 Async auth check - User ID: $userId, Email: $userEmail');

        // If authenticated, use real user ID
        if (userId != null) {
          return userId;
        }
      } else {
        _logger.w('⚠️ Supabase not initialized');
      }

      _logger.w('⚠️ No authenticated user - sign in required');
      return null;
    } catch (e) {
      _logger.e('❌ Failed to get async user ID', error: e);
      return null;
    }
  }

  /// Get stored username from SharedPreferences
  Future<String?> getStoredUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('selected_username');
    } catch (e) {
      _logger.e('Failed to get stored username', error: e);
      return null;
    }
  }

  /// Get current user display name for UI
  Future<String> getCurrentUserDisplayName() async {
    final realUser = supabase.auth.currentUser;
    if (realUser != null) {
      return realUser.email ?? 'Authenticated User';
    }

    final username = await getStoredUsername();
    if (username != null) {
      return username;
    }

    return 'No Username Set';
  }

  /// Check if username is selected
  Future<bool> hasSelectedUsername() async {
    final username = await getStoredUsername();
    return username != null && username.isNotEmpty;
  }

  /// Check if user is currently authenticated
  bool get isAuthenticated {
    try {
      return supabase.auth.currentSession != null;
    } catch (e) {
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      _logger.i('User signed out successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to sign out', error: e, stackTrace: stackTrace);
    }
  }

  /// Register new user with email and password
  Future<AuthResult> signUp(
      String email, String password, String displayName) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );

      if (response.user != null) {
        _logger.i('User registered successfully: ${response.user!.email}');
        return AuthResult.success();
      } else {
        return AuthResult.error('Registration failed - no user returned');
      }
    } catch (e) {
      _logger.e('Registration failed', error: e);
      return AuthResult.error(e.toString());
    }
  }

  /// Sign in user with email and password
  Future<AuthResult> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        _logger.i('User signed in successfully: ${response.user?.email}');
        return AuthResult.success();
      } else {
        return AuthResult.error('Sign in failed - no session created');
      }
    } catch (e) {
      _logger.e('Sign in failed', error: e);
      return AuthResult.error(e.toString());
    }
  }

  /// Send password reset email
  Future<AuthResult> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      _logger.i('Password reset email sent to: $email');
      return AuthResult.success();
    } catch (e) {
      _logger.e('Password reset failed', error: e);
      return AuthResult.error(e.toString());
    }
  }

  /// Resend email verification
  Future<AuthResult> resendVerification(String email) async {
    try {
      await supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      _logger.i('Verification email resent to: $email');
      return AuthResult.success();
    } catch (e) {
      _logger.e('Resend verification failed', error: e);
      return AuthResult.error(e.toString());
    }
  }
}

/// Authentication result wrapper
class AuthResult {
  final bool isSuccess;
  final String? error;

  AuthResult._(this.isSuccess, this.error);

  factory AuthResult.success() => AuthResult._(true, null);
  factory AuthResult.error(String error) => AuthResult._(false, error);
}
