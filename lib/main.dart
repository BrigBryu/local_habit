import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/flexible_theme_system.dart';
import 'core/network/supabase_client.dart';
import 'core/auth/username_auth_service.dart';
import 'core/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables quickly
  const isDev = bool.fromEnvironment('DEV', defaultValue: false);
  final envFile = isDev ? '.env.dev' : '.env';
  await dotenv.load(fileName: envFile);

  // Initialize Supabase FIRST since auth service depends on it
  await SupabaseClientService.instance.initialize();
  debugPrint('Supabase initialized before auth service');

  // Initialize auth service AFTER Supabase is ready
  await UsernameAuthService.instance.initialize();
  debugPrint('Auth service initialized after Supabase');

  debugPrint('App Startup Completed - launching UI');

  // Launch app with both services already initialized
  runApp(const ProviderScope(child: HabitLevelUpApp()));

  // Check initial session status
  _checkInitialSession();
}

/// Check initial session and handle test user override
void _checkInitialSession() async {
  // Check initial Supabase session
  final session = SupabaseClientService.instance.supabase.auth.currentSession;
  debugPrint('Initial Supabase session: $session');

  // Handle TEST_USER_OVERRIDE for automated testing
  final testUserOverride = Platform.environment['TEST_USER_OVERRIDE'];
  if (testUserOverride != null && testUserOverride.isNotEmpty) {
    debugPrint('TEST_USER_OVERRIDE detected: $testUserOverride');

    // Extract username from email format if needed
    String testUsername;
    if (testUserOverride.contains('@')) {
      testUsername = testUserOverride.split('@')[0];
    } else {
      testUsername = testUserOverride;
    }

    // Auto-sign in test user in background
    _signInTestUser(testUsername);
  }

  debugPrint('Running with Supabase integration enabled');

  // Run sync queue simulation if debug flag is set
  if (const bool.fromEnvironment('SYNC_QUEUE_SELFTEST')) {
    debugPrint('SYNC_QUEUE_SELFTEST flag detected - simulation would run here');
    // TODO: Implement sync queue simulation
  }
}

/// Sign in test user asynchronously
void _signInTestUser(String testUsername) async {
  try {
    // Try to sign in with test user
    final result =
        await UsernameAuthService.instance.signIn(testUsername, 'testpass123');
    if (result.isSuccess) {
      debugPrint('Test user auto-signed in successfully: $testUsername');
    } else {
      debugPrint(
          'Test user sign-in failed, trying to create account: ${result.error}');
      // If sign-in fails, try to create the test account
      final createResult = await UsernameAuthService.instance
          .signUp(testUsername, 'testpass123');
      if (createResult.isSuccess) {
        debugPrint('Test user account created and signed in: $testUsername');
      } else {
        debugPrint('Test user account creation failed: ${createResult.error}');
      }
    }
  } catch (e) {
    debugPrint('Test user override failed: $e');
  }
}

class HabitLevelUpApp extends ConsumerWidget {
  const HabitLevelUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get theme-aware colors (optional - components can still use AppColors directly)
    final colors = ref.watchColors;

    return MaterialApp(
      title: 'Habit Level Up',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: colors.primaryPurple,
          brightness: Brightness.dark,
          surface: colors.draculaCurrentLine,
          primary: colors.primaryPurple,
          secondary: colors.purpleAccent,
          error: colors.error,
          onSurface: colors.draculaForeground,
          onPrimary: colors.draculaBackground,
        ),
        scaffoldBackgroundColor: colors.draculaBackground,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: colors.primaryPurple,
          foregroundColor: colors.draculaBackground,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: colors.primaryPurple,
          unselectedLabelColor: colors.draculaComment,
          indicatorColor: colors.primaryPurple,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colors.draculaBackground,
          foregroundColor: colors.draculaForeground,
          elevation: 0,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
