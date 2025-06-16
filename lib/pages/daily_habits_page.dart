import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habits_provider.dart';
import 'package:domain/domain.dart';
import '../features/habits/bundle_habit/index.dart';
import '../features/habits/avoidance_habit/index.dart';
import '../features/habits/stack_habit/index.dart';
import '../features/habits/basic_habit/index.dart';
import '../features/habits/basic_habit/add_basic_habit_screen.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/flexible_theme_system.dart';

class DailyHabitsPage extends ConsumerWidget {
  const DailyHabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHabitsAsync = ref.watch(ownHabitsProvider);

    return allHabitsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading habits: $error'),
            ],
          ),
        ),
      ),
      data: (allHabits) {
        // Filter to show only top-level habits (not children of bundles or stacks)
        final topLevelHabits = allHabits
            .where((habit) =>
                habit.parentBundleId == null && habit.stackedOnHabitId == null)
            .toList();

        return _buildHabitsScaffold(context, ref, topLevelHabits, allHabits);
      },
    );
  }

  Widget _buildHabitsScaffold(BuildContext context, WidgetRef ref,
      List<Habit> topLevelHabits, List<Habit> allHabits) {
    final colors = ref.watchColors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: topLevelHabits.isEmpty
          ? _buildEmptyState(context, ref)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: topLevelHabits.length,
              itemBuilder: (context, index) {
                final habit = topLevelHabits[index];

                switch (habit.type) {
                  case HabitType.bundle:
                    return BundleHabitTile(habit: habit, allHabits: allHabits);
                  case HabitType.stack:
                    return StackHabitTile(habit: habit, allHabits: allHabits);
                  case HabitType.avoidance:
                    return AvoidanceHabitTile(habit: habit);
                  case HabitType.basic:
                  default:
                    return HabitTile(
                        habit: habit); // Use the proper HabitTile from features
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the proper add screen with type selection
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  const AddBasicHabitScreen(), // Has type selection dropdown
            ),
          );
        },
        tooltip: 'Add New Habit',
        backgroundColor: colors.primaryPurple,
        child: Icon(Icons.add, color: colors.draculaBackground),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: colors.draculaComment.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'No habits yet!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.draculaForeground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the + button below to create your first habit and start building a better you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colors.draculaComment,
              ),
            ),
            const SizedBox(height: 120), // Space for FAB
          ],
        ),
      ),
    );
  }
}
