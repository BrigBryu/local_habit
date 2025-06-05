import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/daily_habits_page.dart';

void main() {
  runApp(const ProviderScope(child: HabitLevelUpApp()));
}

class HabitLevelUpApp extends StatelessWidget {
  const HabitLevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Level Up',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DailyHabitsPage(),
    );
  }
}