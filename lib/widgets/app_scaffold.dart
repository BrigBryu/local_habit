import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../nav/home_nav.dart';
import '../nav/streaks_nav.dart';
import '../nav/settings_nav.dart';
import '../core/theme/theme_controller.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final colors = ref.watchColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(selectedTab),
          style: TextStyle(
            color: colors.draculaForeground,
            fontWeight: FontWeight.w600,
          ),
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
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle(int selectedTab) {
    switch (selectedTab) {
      case 0:
        return 'Daily Habits';
      case 1:
        return 'Streaks';
      case 2:
        return 'Settings';
      default:
        return 'Habit Level Up';
    }
  }
}