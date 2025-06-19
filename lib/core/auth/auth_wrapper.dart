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
    logger.i('[AuthStateNotifier] Setting up auth state stream listener');
    
    // Listen to the auth state stream instead of polling
    _subscription = UsernameAuthService.instance.authStateStream.listen((newState) {
      if (newState != state) {
        logger.i('[AuthStateNotifier] Stream state changed: $state → $newState');
        state = newState;
      }
    });
  }

  @override
  void dispose() {
    final logger = Logger();
    logger.i('[AuthStateNotifier] Disposing');
    _subscription?.cancel();
    super.dispose();
  }

  /// Force refresh the auth state
  void refresh() async {
    final logger = Logger();
    logger.i('[AuthStateNotifier] Force refresh requested');

    // Get current state directly instead of waiting
    final currentState = UsernameAuthService.instance.isAuthenticated;
    logger.i('[AuthStateNotifier] Force refresh: $state → $currentState');
    if (currentState != state) {
      state = currentState;
    }
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

    logger.d('AuthWrapper building - isAuthenticated: $isAuthenticated');
    logger.d(
        'Current user ID: ${UsernameAuthService.instance.getCurrentUserId()}');

    if (isAuthenticated) {
      logger.i('Showing main app (HomeTabScaffold)');
      return const HomeTabScaffold();
    } else {
      logger.i('Showing sign-in screen');
      return const UsernameSignInScreen();
    }
  }
}
