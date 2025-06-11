import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/home_tab_scaffold.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/flexible_theme_system.dart';
import 'core/auth/auth_service.dart';
import 'core/network/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize core services
    await SupabaseClientService.instance.initialize();
    await AuthService.init();
  } catch (e) {
    // Don't crash on initialization failure - app will fall back to local mode
    debugPrint('Service initialization failed: $e');
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
          background: colors.backgroundDark,
          surface: colors.cardBackgroundDark,
          primary: colors.primaryPurple,
          secondary: colors.purpleAccent,
          error: colors.error,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const HomeTabScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

