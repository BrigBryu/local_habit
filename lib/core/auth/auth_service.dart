import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../network/supabase_client.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  AuthService._();

  final _logger = Logger();

  /// Initialize auth service and attempt test login
  static Future<void> init() async {
    final authService = AuthService.instance;
    await authService._performTestLogin();
  }

  Future<void> _performTestLogin() async {
    try {
      // Check if already authenticated
      final currentSession = supabase.auth.currentSession;
      if (currentSession != null) {
        _logger.i('Already authenticated as: ${currentSession.user.email}');
        return;
      }

      // Get test credentials from environment
      final testEmail = dotenv.env['TEST_EMAIL'];
      final testPassword = dotenv.env['TEST_PASSWORD'];

      if (testEmail == null || testPassword == null) {
        _logger.w('No test credentials found in .env file - skipping auth');
        return;
      }

      _logger.i('Attempting test login with: $testEmail');

      // Attempt sign in
      final response = await supabase.auth.signInWithPassword(
        email: testEmail,
        password: testPassword,
      );

      if (response.session != null) {
        _logger.i('Successfully authenticated as: ${response.user?.email}');
      } else {
        _logger.w('Authentication succeeded but no session created');
      }

    } catch (e, stackTrace) {
      _logger.e('Authentication failed - falling back to local mode', 
               error: e, stackTrace: stackTrace);
      // Don't rethrow - we want to fall back to local mode gracefully
    }
  }

  /// Get current user ID for database operations
  String? getCurrentUserId() {
    try {
      return supabase.auth.currentUser?.id;
    } catch (e) {
      _logger.e('Failed to get current user ID', error: e);
      return null;
    }
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

  /// TODO: Implement proper user registration
  Future<void> signUp(String email, String password) async {
    // Implementation for future sprints
    throw UnimplementedError('User registration not implemented yet');
  }

  /// TODO: Implement proper user login
  Future<void> signIn(String email, String password) async {
    // Implementation for future sprints
    throw UnimplementedError('User login not implemented yet');
  }
}