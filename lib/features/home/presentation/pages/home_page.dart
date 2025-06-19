import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../providers.dart';
import '../../../habits/basic_habit/index.dart';
import '../../../habits/basic_habit/basic_habit_info_screen.dart';
import '../../../habits/bundle_habit/bundle_habit_tile.dart';
import '../../../../providers/habits_provider.dart';
import '../../../../screens/theme_settings_screen.dart';
import '../../../../screens/partner_settings_screen.dart';
import '../../../../core/theme/app_colors.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(homeHabitsProvider);
    final allHabits =
        ref.watch(habitsProvider); // Get ALL habits for bundle children
    final routeAvailability = ref.watch(routeAvailabilityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Habit Level Up',
          style: TextStyle(
            color: AppColors.draculaForeground,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.draculaCurrentLine,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _navigateToPartnerSettings(context),
            icon: Icon(
              Icons.people_outline,
              color: AppColors.draculaCyan,
            ),
            tooltip: 'Partner Settings',
          ),
          IconButton(
            onPressed: () => _navigateToThemeSettings(context),
            icon: Icon(
              Icons.palette_outlined,
              color: AppColors.draculaPurple,
            ),
            tooltip: 'Theme Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Habits section header
              Row(
                children: [
                  Text(
                    'Today\'s Habits',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '${habits.length} total',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Habits list
              Expanded(
                child: habits.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          // Use different tiles for different habit types
                          if (habit.type == HabitType.bundle) {
                            return RepaintBoundary(
                              child: BundleHabitTile(
                                habit: habit,
                                allHabits: allHabits.value ??
                                    [], // Extract value from AsyncValue
                              ),
                            );
                          } else {
                            return RepaintBoundary(
                              child: HabitTile(
                                habit: habit,
                                onTap: () =>
                                    _navigateToViewHabit(context, habit),
                              ),
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddHabit(context, routeAvailability),
        icon: Icon(Icons.add, color: AppColors.primaryPurple),
        label: Text('Add Habit',
            style: TextStyle(
                color: AppColors.primaryPurple, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.completedBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: AppColors.primaryPurple.withOpacity(0.3), width: 1),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: AppColors.borderMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to create your first habit',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 120), // Space for FAB
        ],
      ),
    );
  }

  void _navigateToAddHabit(
      BuildContext context, Map<String, bool> routeAvailability) {
    if (routeAvailability['addHabit'] == true) {
      try {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AddBasicHabitScreen(),
          ),
        );
      } catch (e) {
        _showPlaceholder(context, 'Add Habit (TODO)', 'Feature coming soon');
      }
    } else {
      _showPlaceholder(context, 'Add Habit (TODO)', 'Feature coming soon');
    }
  }


  void _navigateToViewHabit(BuildContext context, Habit habit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BasicHabitInfoScreen(habit: habit),
      ),
    );
  }

  void _navigateToThemeSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ThemeSettingsScreen(),
      ),
    );
  }

  void _navigateToPartnerSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PartnerSettingsScreen(),
      ),
    );
  }

  void _showPlaceholder(BuildContext context, String title, String message) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Center(
            child: Text(message),
          ),
        ),
      ),
    );
  }
}
