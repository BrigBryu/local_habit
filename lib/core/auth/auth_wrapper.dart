import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'username_auth_service.dart';
import '../../screens/auth/username_sign_in_screen.dart';
import '../../widgets/home_tab_scaffold.dart';

/// Provider for authentication state using username auth
final authStateProvider = StateProvider<bool>((ref) {
  // Initial state based on current authentication
  return UsernameAuthService.instance.isAuthenticated;
});

/// Wrapper widget that shows sign-in or main app based on auth state
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authStateProvider);
    final logger = Logger();
    
    logger.d('AuthWrapper building - isAuthenticated: $isAuthenticated');
    logger.d('Service isAuthenticated: ${UsernameAuthService.instance.isAuthenticated}');
    logger.d('Current user ID: ${UsernameAuthService.instance.getCurrentUserId()}');

    if (isAuthenticated) {
      // User is authenticated - show main app
      logger.i('Showing main app (HomeTabScaffold)');
      return const HomeTabScaffold();
    } else {
      // User is not authenticated - show sign-in screen
      logger.i('Showing sign-in screen');
      return const UsernameSignInScreen();
    }
  }
}