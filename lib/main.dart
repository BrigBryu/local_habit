import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'widgets/home_tab_scaffold.dart';
import 'core/theme/flexible_theme_system.dart';
import 'core/network/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Supabase
  await SupabaseClientService.instance.initialize();
  
  // Initialize Isar for web if needed
  // Note: In Isar 3.1.0+ this is handled automatically
  
  debugPrint('Running with Supabase integration enabled');
  
  // Run sync queue simulation if debug flag is set
  if (const bool.fromEnvironment('SYNC_QUEUE_SELFTEST')) {
    debugPrint('SYNC_QUEUE_SELFTEST flag detected - simulation would run here');
    // TODO: Implement sync queue simulation
  }
  
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
          background: colors.draculaBackground,
          primary: colors.primaryPurple,
          secondary: colors.purpleAccent,
          error: colors.error,
          onSurface: colors.draculaForeground,
          onBackground: colors.draculaForeground,
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

