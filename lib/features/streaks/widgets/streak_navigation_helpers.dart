import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_controller.dart';
import '../screens/streaks_screen.dart';
import '../screens/streak_calendar_screen.dart';

/// Helper widget to add streak navigation buttons to existing screens
class StreakNavigationTile extends ConsumerWidget {
  const StreakNavigationTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            colors.primaryPurple.withOpacity(0.1),
            colors.purpleAccent.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.primaryPurple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: colors.primaryPurple,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Streak Tracking',
                        style: TextStyle(
                          color: colors.draculaForeground,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'View your consistency and compare with your partner',
                        style: TextStyle(
                          color: colors.draculaComment,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildNavigationButton(
                    context,
                    ref,
                    'Dashboard',
                    Icons.dashboard,
                    () => _navigateToStreaks(context),
                    colors.primaryPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNavigationButton(
                    context,
                    ref,
                    'Calendar',
                    Icons.calendar_month,
                    () => _navigateToStreaksCalendar(context),
                    colors.purpleAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    final colors = ref.watchColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToStreaks(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StreaksScreen(),
      ),
    );
  }

  void _navigateToStreaksCalendar(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StreakCalendarScreen(),
      ),
    );
  }
}

/// Simple floating action button to access streaks
class StreaksFAB extends ConsumerWidget {
  const StreaksFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;

    return FloatingActionButton(
      onPressed: () => _navigateToStreaks(context),
      backgroundColor: colors.primaryPurple,
      foregroundColor: colors.draculaBackground,
      tooltip: 'View Streaks',
      child: const Icon(Icons.local_fire_department),
    );
  }

  void _navigateToStreaks(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StreaksScreen(),
      ),
    );
  }
}

/// App bar action for accessing streaks
class StreaksAppBarAction extends ConsumerWidget {
  const StreaksAppBarAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;

    return IconButton(
      onPressed: () => _navigateToStreaks(context),
      icon: Icon(
        Icons.local_fire_department,
        color: colors.primaryPurple,
      ),
      tooltip: 'View Streaks',
    );
  }

  void _navigateToStreaks(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StreaksScreen(),
      ),
    );
  }
}
