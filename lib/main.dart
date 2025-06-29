import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/flexible_theme_system.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('Local-only app startup completed - launching UI');

  // Launch offline app
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
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
