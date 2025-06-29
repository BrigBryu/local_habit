import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/daily_habits_page.dart';
import '../screens/settings_screen.dart';
import '../core/theme/flexible_theme_system.dart';
import '../providers/repository_init_provider.dart';

class HomeTabScaffold extends ConsumerWidget {
  const HomeTabScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch repository initialization
    final repositoryInit = ref.watch(repositoryProvider);
    final colors = ref.watchColors;

    return repositoryInit.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to initialize database',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Retry initialization
                  ref.invalidate(repositoryProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (_) => Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Flexible(
                child: Text(
                  'Habit Level Up',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.draculaForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.offline_bolt,
                size: 16,
                color: colors.success,
              ),
            ],
          ),
          backgroundColor: colors.draculaBackground,
          foregroundColor: colors.draculaForeground,
          iconTheme: IconThemeData(color: colors.draculaForeground),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              icon: Icon(Icons.settings, color: colors.draculaForeground),
              tooltip: 'Settings',
            ),
          ],
        ),
        body: const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: DailyHabitsPage(),
        ),
      ),
    );
  }
}

