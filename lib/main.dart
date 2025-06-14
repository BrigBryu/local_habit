import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'widgets/home_tab_scaffold.dart';
import 'core/theme/flexible_theme_system.dart';
import 'core/network/supabase_client.dart';
import 'core/auth/test_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables - check for dev environment first
  const isDev = bool.fromEnvironment('DEV', defaultValue: false);
  final envFile = isDev ? '.env.dev' : '.env';
  await dotenv.load(fileName: envFile);
  
  // Development-only: Reset local Isar database to avoid corrupt state
  if (kDebugMode) {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final isarFiles = [
        File('${appDir.path}/default.isar'),
        File('${appDir.path}/default.isar.lock'),
        File('${appDir.path}/sync.isar'),
        File('${appDir.path}/sync.isar.lock'),
      ];
      
      for (final file in isarFiles) {
        if (await file.exists()) {
          await file.delete();
          debugPrint('Deleted Isar file: ${file.path}');
        }
      }
    } catch (e) {
      debugPrint('Failed to reset Isar database: $e');
    }
  }
  
  // Initialize Supabase
  try {
    await SupabaseClientService.instance.initialize().timeout(const Duration(seconds: 15));
    debugPrint('Supabase initialization completed');
  } catch (e) {
    debugPrint('Supabase initialization failed or timed out: $e - continuing in offline mode');
  }
  
  // Initialize test authentication for development/testing
  if (isDev || const bool.fromEnvironment('TESTING', defaultValue: false)) {
    debugPrint('Development/Testing mode - ensuring test users exist');
    try {
      await TestSignIn.ensureTestUsersExist().timeout(const Duration(seconds: 10));
      
      final signedIn = await TestSignIn.signInTestUser().timeout(const Duration(seconds: 10));
      if (signedIn) {
        debugPrint('Test authentication successful');
      } else {
        debugPrint('Test authentication failed - continuing in local mode');
      }
    } catch (e) {
      debugPrint('Test authentication timed out or failed: $e - continuing in local mode');
    }
  }
  
  // Initialize Isar for web if needed
  // Note: In Isar 3.1.0+ this is handled automatically
  
  debugPrint('Running with Supabase integration enabled');
  
  // Run sync queue simulation if debug flag is set
  if (const bool.fromEnvironment('SYNC_QUEUE_SELFTEST')) {
    debugPrint('SYNC_QUEUE_SELFTEST flag detected - simulation would run here');
    // TODO: Implement sync queue simulation
  }
  
  debugPrint('App Startup Completed - launching UI');
  
  runApp(const ProviderScope(child: HabitLevelUpApp()));
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
      home: const HomeTabScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

