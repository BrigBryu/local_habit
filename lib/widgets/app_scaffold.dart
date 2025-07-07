import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../nav/home_nav.dart';
import '../nav/streaks_nav.dart';
import '../nav/shop_nav.dart';
import '../nav/settings_nav.dart';
import '../core/theme/flexible_theme_system.dart';
import '../providers/repository_init_provider.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repositoryInit = ref.watch(repositoryProvider);
    final selectedTab = ref.watch(selectedTabProvider);
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
                  _getAppBarTitle(selectedTab),
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
        ),
        body: IndexedStack(
          index: selectedTab,
          children: const [
            HomeNavigator(),
            StreaksNavigator(),
            ShopNavigator(),
            SettingsNavigator(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedTab,
          onTap: (index) => ref.read(selectedTabProvider.notifier).state = index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: colors.draculaBackground,
          selectedItemColor: colors.draculaPink,
          unselectedItemColor: colors.draculaComment,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_fire_department),
              label: 'Streaks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle(int selectedTab) {
    switch (selectedTab) {
      case 0:
        return 'Daily Habits';
      case 1:
        return 'Streaks & Analytics';
      case 2:
        return 'Themes & Utilities';
      case 3:
        return 'Settings';
      default:
        return 'Habit Level Up';
    }
  }
}