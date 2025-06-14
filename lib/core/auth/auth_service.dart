import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/supabase_client.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  AuthService._();

  final _logger = Logger();

  /// Get test email based on simple random selection to simulate different users
  String? _getTestEmail() {
    // Check if there's a dart-define override first
    const cmdOverride = String.fromEnvironment('TEST_USER_OVERRIDE');
    if (cmdOverride.isNotEmpty) return cmdOverride;
    
    // Check if there's an environment variable override
    final envOverride = dotenv.env['TEST_USER_OVERRIDE'];
    if (envOverride != null) {
      return envOverride;
    }
    
    // Use a deterministic approach based on app startup time hash
    // This will give us different users on different app instances
    final hashValue = DateTime.now().millisecondsSinceEpoch % 2;
    
    if (hashValue == 0) {
      _logger.i('Selecting USER1 for this device instance');
      return dotenv.env['TEST_EMAIL_USER1'];
    } else {
      _logger.i('Selecting USER2 for this device instance');
      return dotenv.env['TEST_EMAIL_USER2'];
    }
  }

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
      // Use device identifier to determine which test user to use
      final testEmail = _getTestEmail();
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

  /// Get current user ID for database operations (synchronous fallback)
  String? getCurrentUserId() {
    try {
      final userId = supabase.auth.currentUser?.id;
      final userEmail = supabase.auth.currentUser?.email;
      _logger.d('🔑 Auth check - User ID: $userId, Email: $userEmail');
      
      // Fallback for development - use device-specific user IDs for testing
      if (userId == null) {
        final fallbackId = _getDeviceFallbackUserId();
        _logger.w('⚠️ No authenticated user, using dev fallback: $fallbackId');
        _logger.w('💡 Consider using getUserIdAsync() for username-based ID');
        return fallbackId;
      }
      
      return userId;
    } catch (e) {
      final fallbackId = _getDeviceFallbackUserId();
      _logger.e('❌ Failed to get current user ID, using fallback: $fallbackId', error: e);
      return fallbackId;
    }
  }

  /// Get current user ID for database operations (async, username-aware)
  Future<String> getCurrentUserIdAsync() async {
    try {
      // Check for TEST_USER_OVERRIDE first (same as getCurrentUserId)
      const cmdOverride = String.fromEnvironment('TEST_USER_OVERRIDE');
      if (cmdOverride.isNotEmpty) {
        final userPart = cmdOverride.split('@')[0].toLowerCase();
        final overrideUserId = '${userPart}_dev_user';
        _logger.i('🎯 Async: Using TEST_USER_OVERRIDE: $cmdOverride -> $overrideUserId');
        return overrideUserId;
      }
      
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
        _logger.w('⚠️ Supabase not initialized, falling back to local user ID');
      }
      
      // Otherwise, use username-based fallback
      return await getUserIdWithUsername();
    } catch (e) {
      _logger.e('❌ Failed to get async user ID', error: e);
      return await getUserIdWithUsername();
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

  /// Get device-specific fallback user ID for testing
  String _getDeviceFallbackUserId() {
    try {
      // Check for test user override first
      const cmdOverride = String.fromEnvironment('TEST_USER_OVERRIDE');
      if (cmdOverride.isNotEmpty) {
        final userPart = cmdOverride.split('@')[0].toLowerCase();
        _logger.i('🎯 Using TEST_USER_OVERRIDE: $cmdOverride -> ${userPart}_dev_user');
        return '${userPart}_dev_user';
      }
      
      // Check environment variables
      final envOverride = dotenv.env['TEST_USER_OVERRIDE'];
      if (envOverride != null && envOverride.isNotEmpty) {
        _logger.i('🎯 Using env TEST_USER_OVERRIDE: $envOverride');
        return '${envOverride.split('@')[0]}_dev_user';
      }
      
      // Use a more stable approach based on the instance
      if (_instance.hashCode % 2 == 0) {
        _logger.i('📱 This is Device A (default Alice)');
        return 'alice_dev_user'; // Device A - Alice
      } else {
        _logger.i('📱 This is Device B (default Bob)');
        return 'bob_dev_user'; // Device B - Bob
      }
    } catch (e) {
      return 'default_dev_user';
    }
  }

  /// Get user ID based on stored username or fallback
  Future<String> getUserIdWithUsername() async {
    final username = await getStoredUsername();
    if (username != null) {
      final userId = '${username.toLowerCase()}_dev_user';
      _logger.d('🔑 Using stored username: $username -> $userId');
      return userId;
    }
    
    final fallback = _getDeviceFallbackUserId();
    _logger.w('⚠️ No stored username, using fallback: $fallback');
    return fallback;
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
      // Check for real Supabase session first
      if (supabase.auth.currentSession != null) {
        return true;
      }
      
      // For dev users, consider them authenticated if we have a user ID
      final devUserId = getCurrentUserId();
      return devUserId != null;
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