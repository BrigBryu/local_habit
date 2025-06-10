import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: HabitLevelUpApp()));
}

class HabitLevelUpApp extends StatelessWidget {
  const HabitLevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Level Up',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

