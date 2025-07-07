import 'package:flutter/material.dart';
import '../features/streaks/screens/streaks_screen.dart';

/// Navigator for Streaks tab with internal routing
class StreaksNavigator extends StatelessWidget {
  const StreaksNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const StreaksScreen(),
            );
          case '/analytics':
            return MaterialPageRoute(
              builder: (_) => _AnalyticsPage(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const StreaksScreen(),
            );
        }
      },
    );
  }
}

/// Placeholder analytics page
class _AnalyticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: const Center(
        child: Text('Advanced Analytics Dashboard'),
      ),
    );
  }
}