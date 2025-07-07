import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/daily_habits_page.dart';

/// Navigator for Home tab with internal routing
class HomeNavigator extends StatelessWidget {
  const HomeNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const DailyHabitsPage(),
            );
          case '/habitDetail':
            final habitId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => _HabitDetailPage(habitId: habitId),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const DailyHabitsPage(),
            );
        }
      },
    );
  }
}

/// Placeholder habit detail page
class _HabitDetailPage extends StatelessWidget {
  final String? habitId;
  
  const _HabitDetailPage({this.habitId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Details'),
      ),
      body: Center(
        child: Text('Habit ID: ${habitId ?? 'Unknown'}'),
      ),
    );
  }
}