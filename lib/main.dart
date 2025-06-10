import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/flexible_theme_system.dart';

void main() {
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
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

