import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'username_auth_service.dart';
import '../../screens/auth/username_sign_in_screen.dart';
import '../../widgets/home_tab_scaffold.dart';

/// Simple state provider that directly returns the current auth state
final authStateProvider = StateProvider<bool>((ref) {
  final logger = Logger();
  final isAuth = UsernameAuthService.instance.isAuthenticated;
  logger.i('[authState] Initial state: $isAuth');
  return isAuth;
});

/// Notifier that watches for auth changes via stream and updates the provider
class AuthStateNotifier extends StateNotifier<bool> {
  AuthStateNotifier() : super(UsernameAuthService.instance.isAuthenticated) {
    final logger = Logger();
    logger.i('[AuthStateNotifier] Starting with state: $state');
    _startWatching();
  }

  StreamSubscription<bool>? _subscription;

  void _startWatching() {
    final logger = Logger();
    
    // Cancel any existing subscription before creating a new one
    _subscription?.cancel();
    
    logger.i('[AuthStateNotifier] Setting up auth state stream listener');
    
    // Listen to the auth state stream with distinct() to prevent duplicate emissions
    _subscription = UsernameAuthService.instance.authStateStream
        .distinct() // Prevent duplicate state emissions
        .listen((newState) {
      logger.i('[AuthStateNotifier] Stream received: $newState, current state: $state');
      if (newState != state) {
        logger.i('[AuthStateNotifier] Stream state changed: $state → $newState');
        state = newState;
      }
    });
    
    // Also immediately check the current state in case we missed an update
    final currentAuthState = UsernameAuthService.instance.isAuthenticated;
    if (currentAuthState != state) {
      logger.i('[AuthStateNotifier] Initial state sync: $state → $currentAuthState');
      state = currentAuthState;
    }
  }

  @override
  void dispose() {
    final logger = Logger();
    logger.i('[AuthStateNotifier] Disposing');
    _subscription?.cancel();
    super.dispose();
  }

  /// Force refresh the auth state
  void refresh() {
    final logger = Logger();
    logger.i('[AuthStateNotifier] Force refresh requested');

    // Get current state directly instead of waiting
    final currentState = UsernameAuthService.instance.isAuthenticated;
    logger.i('[AuthStateNotifier] Force refresh: $state → $currentState');
    
    // Always update state to force a rebuild
    state = currentState;
    
    // Also manually trigger the auth service to emit the current state
    UsernameAuthService.instance.forceNotifyAuthStateChange();
  }
  
  /// Reset and restart the stream listener (useful after sign-out)
  void resetStreamListener() {
    final logger = Logger();
    logger.i('[AuthStateNotifier] Resetting stream listener');
    
    // Cancel existing subscription
    _subscription?.cancel();
    
    // Get current auth state and update immediately
    final currentState = UsernameAuthService.instance.isAuthenticated;
    logger.i('[AuthStateNotifier] Reset: updating state to $currentState');
    state = currentState;
    
    // Restart the stream listener
    _startWatching();
  }
}

/// Provider for the auth state notifier
final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, bool>((ref) {
  return AuthStateNotifier();
});

/// Wrapper widget that shows sign-in or main app based on auth state
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authStateNotifierProvider);
    final logger = Logger();

    logger.d('AuthWrapper rebuild: $isAuthenticated');

    if (isAuthenticated) {
      logger.i('Showing main app (HomeTabScaffold)');
      return const HomeTabScaffold();
    } else {
      logger.i('Showing sign-in screen');
      return const UsernameSignInScreen();
    }
  }
}
