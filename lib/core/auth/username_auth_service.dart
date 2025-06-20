import 'dart:async';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/supabase_client.dart';

/// Supabase-backed username/password authentication service
/// Uses native Supabase auth with username-as-email strategy
class UsernameAuthService {
  static UsernameAuthService? _instance;
  static UsernameAuthService get instance {
    _instance ??= UsernameAuthService._();
    return _instance!;
  }

  UsernameAuthService._();

  final _logger = Logger();

  String? _currentUsername;
  
  // Stream controller for auth state changes
  final _authStateController = StreamController<bool>.broadcast();
  
  /// Stream of authentication state changes
  Stream<bool> get authStateStream => _authStateController.stream;
  
  bool? _lastEmittedState;
  
  /// Notify listeners of auth state change
  void _notifyAuthStateChange() {
    final newState = isAuthenticated;
    
    // Only emit if state has actually changed
    if (_lastEmittedState != newState) {
      _logger.d('[_notifyAuthStateChange] Emitting auth state change: $_lastEmittedState → $newState');
      _lastEmittedState = newState;
      _authStateController.add(newState);
    }
  }
  
  /// Force notify auth state change (public method for external calls)
  void forceNotifyAuthStateChange() {
    final newState = isAuthenticated;
    _logger.d('[forceNotifyAuthStateChange] Force emitting auth state: $newState');
    _lastEmittedState = newState;
    _authStateController.add(newState);
  }
  
  /// Dispose of resources
  void dispose() {
    _authStateController.close();
  }

  /// Convert username to fake email for Supabase auth
  String _usernameToEmail(String username) {
    return '${username.toLowerCase().trim()}@app.local';
  }

  /// Register new user with username and password
  Future<AuthResult> signUp(String username, String password) async {
    try {
      final normalizedUsername = username.toLowerCase().trim();

      _logger.i('Sign up attempt for username: $normalizedUsername');

      // Validate input
      if (normalizedUsername.isEmpty || normalizedUsername.length < 3) {
        return AuthResult.error('Username must be at least 3 characters long');
      }

      if (password.isEmpty || password.length < 6) {
        return AuthResult.error('Password must be at least 6 characters long');
      }

      // Convert username to fake email
      final fakeEmail = _usernameToEmail(normalizedUsername);
      
      // Create Supabase auth user
      final authResponse = await supabase.auth.signUp(
        email: fakeEmail,
        password: password,
      );

      if (authResponse.user == null) {
        return AuthResult.error('Failed to create account');
      }

      _logger.i('Supabase user created: ${authResponse.user!.id}');

      // Store username mapping in profiles table
      try {
        await supabase.from('profiles').upsert({
          'id': authResponse.user!.id,
          'username': normalizedUsername,
        });
        _logger.i('Profile created for user: $normalizedUsername');
      } catch (e) {
        _logger.e('Failed to create profile', error: e);
        // If profile creation fails due to duplicate username
        if (e.toString().toLowerCase().contains('duplicate') || 
            e.toString().toLowerCase().contains('unique')) {
          return AuthResult.error('This username is already taken. Please choose a different one.');
        }
        return AuthResult.error('Failed to complete account setup');
      }

      // Set current username and save to storage
      _currentUsername = normalizedUsername;
      await _saveCurrentUsername();
      
      // Notify auth state change
      _notifyAuthStateChange();

      _logger.i('User registered and signed in: $normalizedUsername');
      return AuthResult.success();
    } catch (e) {
      _logger.e('Registration failed', error: e);

      // Parse specific error messages
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('already registered') || 
          errorMessage.contains('user already exists')) {
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

      // Convert username to fake email
      final fakeEmail = _usernameToEmail(normalizedUsername);

      // Sign in with Supabase auth
      final authResponse = await supabase.auth.signInWithPassword(
        email: fakeEmail,
        password: password,
      );

      if (authResponse.user == null) {
        _logger.e('[signIn] Auth response returned null user');
        return AuthResult.error('Invalid username or password');
      }

      _logger.i('[signIn] Supabase auth successful: ${authResponse.user!.id}');

      // Get username from profiles table
      try {
        final profileResponse = await supabase
            .from('profiles')
            .select('username')
            .eq('id', authResponse.user!.id)
            .single();

        _currentUsername = profileResponse['username'] as String;
        _logger.i('[signIn] Retrieved username from profile: $_currentUsername');
      } catch (e) {
        _logger.w('[signIn] Failed to get username from profile, using normalized: $e');
        _currentUsername = normalizedUsername;
      }

      // Save to storage
      await _saveCurrentUsername();
      
      // Notify auth state change
      _notifyAuthStateChange();

      _logger.i('[signIn] SUCCESS for: $_currentUsername');
      return AuthResult.success();
    } catch (e) {
      _logger.e('Sign in failed', error: e);

      // Parse specific error messages
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('invalid login credentials') ||
          errorMessage.contains('invalid email or password')) {
        return AuthResult.error('Invalid username or password');
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

  /// Get current user ID from Supabase auth
  String? getCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }

  /// Get current username
  String? getCurrentUsername() {
    return _currentUsername;
  }

  /// Check if user is authenticated using Supabase session
  bool get isAuthenticated {
    final session = supabase.auth.currentSession;
    final hasSession = session != null && !session.isExpired;
    
    _logger.d('[isAuthenticated] session exists: ${session != null}, expired: ${session?.isExpired}, result: $hasSession');
    return hasSession;
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _logger.i('[signOut] Starting sign out process...');
      
      // Sign out from Supabase auth
      await supabase.auth.signOut();
      
      // Clear local data
      _currentUsername = null;

      // Clear from storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_username');
      
      _logger.i('[signOut] Cleared user data and storage');
      
      // Reset the last emitted state to ensure next auth change is detected
      _lastEmittedState = null;
      
      // Force notify auth state change
      forceNotifyAuthStateChange();
      
      _logger.i('[signOut] User signed out successfully');
    } catch (e) {
      _logger.e('Sign out failed', error: e);
      // Even on error, try to force notify the state change
      forceNotifyAuthStateChange();
    }
  }

  /// Initialize and restore session
  Future<void> initialize() async {
    try {
      // Check if we have a valid Supabase session
      final session = supabase.auth.currentSession;
      if (session != null && !session.isExpired) {
        // Try to restore username from storage
        final prefs = await SharedPreferences.getInstance();
        _currentUsername = prefs.getString('current_username');
        
        // If no stored username, try to get it from profiles table
        if (_currentUsername == null && session.user != null) {
          try {
            final profileResponse = await supabase
                .from('profiles')
                .select('username')
                .eq('id', session.user!.id)
                .single();
                
            _currentUsername = profileResponse['username'] as String;
            await _saveCurrentUsername();
            _logger.i('Username restored from profiles: $_currentUsername');
          } catch (e) {
            _logger.w('Failed to restore username from profiles: $e');
          }
        }

        if (_currentUsername != null) {
          _logger.i('Session restored for user: $_currentUsername');
        }
      }
      
      // Set up auth state listener
      supabase.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        _logger.i('Auth state changed: ${session != null ? 'signed in' : 'signed out'}');
        _notifyAuthStateChange();
      });
      
      // Notify initial auth state
      _notifyAuthStateChange();
    } catch (e) {
      _logger.e('Failed to initialize auth service', error: e);
    }
  }

  /// Save current username to storage
  Future<void> _saveCurrentUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUsername != null) {
        await prefs.setString('current_username', _currentUsername!);
      }
    } catch (e) {
      _logger.e('Failed to save username to storage', error: e);
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