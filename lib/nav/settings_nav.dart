import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';

/// Navigator for Settings tab with internal routing
class SettingsNavigator extends StatelessWidget {
  const SettingsNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const SettingsScreen(),
            );
          case '/debug':
            return MaterialPageRoute(
              builder: (_) => _DebugPage(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const SettingsScreen(),
            );
        }
      },
    );
  }
}

/// Hidden debug page
class _DebugPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
      ),
      body: const Center(
        child: Text('Debug Information'),
      ),
    );
  }
}