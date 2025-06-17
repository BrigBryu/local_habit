import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/supabase_client.dart';

/// Supabase-backed username/password authentication service
class UsernameAuthService {
  static UsernameAuthService? _instance;
  static UsernameAuthService get instance {
    _instance ??= UsernameAuthService._();
    return _instance!;
  }

  UsernameAuthService._();

  final _logger = Logger();

  String? _currentUserId;
  String? _currentUsername;

  /// Register new user with username and password
  Future<AuthResult> signUp(String username, String password) async {
    try {
      final normalizedUsername = username.toLowerCase().trim();

      _logger.i('Sign up attempt for username: $normalizedUsername');
      _logger.i('Original username: \"$username\"');
      _logger.i('Normalized username: \"$normalizedUsername\"');
      _logger.i('Username length: ${normalizedUsername.length}');

      // Validate input
      if (normalizedUsername.isEmpty || normalizedUsername.length < 3) {
        return AuthResult.error('Username must be at least 3 characters long');
      }

      if (password.isEmpty || password.length < 6) {
        return AuthResult.error('Password must be at least 6 characters long');
      }

      // Hash password using SHA-256 with salt
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(password, salt);

      // Create account via Supabase RPC
      final response = await supabase.rpc(
        'create_account',
        params: {
          'p_username': normalizedUsername,
          'p_password_hash': hashedPassword,
        },
      ) as Map<String, dynamic>?;

      if (response == null) {
        return AuthResult.error('Failed to create account');
      }

      // Extract user data from response
      final userData = response as Map<String, dynamic>;
      _currentUserId = userData['id'];
      _currentUsername = userData['username'];

      // Persist to storage
      await _saveCurrentUser();

      _logger.i('User registered and signed in: $normalizedUsername');
      return AuthResult.success();
    } catch (e) {
      _logger.e('Registration failed', error: e);

      // Parse specific error messages
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('username already exists')) {
        return AuthResult.error(
            'This username is already taken. Please choose a different one.');
      } else if (errorMessage.contains('network') ||
          errorMessage.contains('connection')) {
        return AuthResult.error(
            'Network error. Please check your internet connection and try again.');
      } else if (errorMessage.contains('timeout')) {
        return AuthResult.error('Connection timeout. Please try again.');
      } else if (errorMessage.contains('invalid')) {
        return AuthResult.error('Invalid username or password format.');
      } else if (errorMessage.contains('p0001')) {
        return AuthResult.error(
            'Username validation failed. Please use only letters, numbers, and underscores.');
      } else {
        return AuthResult.error(
            'Account creation failed. Please try again later.');
      }
    }
  }

  /// Sign in with username and password
  Future<AuthResult> signIn(String username, String password) async {
    try {
      final normalizedUsername = username.toLowerCase().trim();

      _logger.i('[signIn] Attempt for username: $normalizedUsername');

      // Get account from Supabase
      final response = await supabase.rpc(
        'login_account',
        params: {
          'p_username': normalizedUsername,
        },
      ) as Map<String, dynamic>?;

      if (response == null) {
        _logger.e('[signIn] RPC returned null - username not found');
        return AuthResult.error('Username not found');
      }

      final userData = response as Map<String, dynamic>;
      final storedPasswordHash = userData['password_hash'] as String;

      // Verify password using SHA-256
      final isValidPassword = _verifyPassword(password, storedPasswordHash);

      if (!isValidPassword) {
        _logger.e('[signIn] Password verification failed');
        return AuthResult.error('Invalid password');
      }

      // Set user data
      _currentUserId = userData['id'];
      _currentUsername = userData['username'];
      _logger.i('[signIn] Set user data - ID: $_currentUserId, username: $_currentUsername');

      // Persist to storage
      await _saveCurrentUser();
      _logger.i('[signIn] User data saved to storage');

      // Check isAuthenticated after setting data
      final authStatus = isAuthenticated;
      _logger.i('[signIn] isAuthenticated status: $authStatus');

      _logger.i('[signIn] SUCCESS for: $normalizedUsername');
      return AuthResult.success();
    } catch (e) {
      _logger.e('Sign in failed', error: e);

      // Parse specific error messages
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('username not found') ||
          errorMessage.contains('null')) {
        return AuthResult.error(
            'Username not found. Please check your username or create a new account.');
      } else if (errorMessage.contains('invalid password')) {
        return AuthResult.error('Incorrect password. Please try again.');
      } else if (errorMessage.contains('network') ||
          errorMessage.contains('connection')) {
        return AuthResult.error(
            'Network error. Please check your internet connection and try again.');
      } else if (errorMessage.contains('timeout')) {
        return AuthResult.error('Connection timeout. Please try again.');
      } else {
        return AuthResult.error(
            'Sign in failed. Please check your credentials and try again.');
      }
    }
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _currentUserId;
  }

  /// Get current username
  String? getCurrentUsername() {
    return _currentUsername;
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    final result = _currentUserId != null && _currentUsername != null;
    _logger.d('[isAuthenticated] userID: $_currentUserId, username: $_currentUsername → $result');
    return result;
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _currentUserId = null;
      _currentUsername = null;

      // Clear from storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_id');
      await prefs.remove('current_username');

      _logger.i('User signed out');
    } catch (e) {
      _logger.e('Sign out failed', error: e);
    }
  }

  /// Initialize and restore session
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('current_user_id');
      _currentUsername = prefs.getString('current_username');

      if (_currentUserId != null && _currentUsername != null) {
        _logger.i('Session restored for user: $_currentUsername');
      }
    } catch (e) {
      _logger.e('Failed to restore session', error: e);
    }
  }

  /// Save current user to storage
  Future<void> _saveCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUserId != null && _currentUsername != null) {
        await prefs.setString('current_user_id', _currentUserId!);
        await prefs.setString('current_username', _currentUsername!);
      }
    } catch (e) {
      _logger.e('Failed to save user session', error: e);
    }
  }

  /// Generate a random salt for password hashing
  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// Hash password with salt using SHA-256
  String _hashPassword(String password, String salt) {
    final combined = password + salt;
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return '$salt:${digest.toString()}';
  }

  /// Verify password against stored hash
  bool _verifyPassword(String password, String storedHash) {
    try {
      final parts = storedHash.split(':');
      if (parts.length != 2) return false;

      final salt = parts[0];
      final expectedHash = _hashPassword(password, salt);
      return expectedHash == storedHash;
    } catch (e) {
      _logger.e('Password verification failed', error: e);
      return false;
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
