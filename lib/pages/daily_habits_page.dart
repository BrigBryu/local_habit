import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habits_provider.dart';
import 'package:domain/domain.dart';
import '../features/habits/bundle_habit/index.dart';
import '../features/habits/avoidance_habit/index.dart';
import '../features/habits/stack_habit/index.dart';
import '../features/habits/basic_habit/index.dart';
import '../features/habits/interval_habit/index.dart';
import '../features/habits/weekly_habit/index.dart';
import '../core/services/due_date_service.dart';
import '../features/habits/basic_habit/add_basic_habit_screen.dart';
import '../features/habits/common/deletable_habit_tile.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/flexible_theme_system.dart';

class DailyHabitsPage extends ConsumerWidget {
  const DailyHabitsPage({super.key});

  void _onReorder(BuildContext context, WidgetRef ref, List<Habit> habits, 
      int oldIndex, int newIndex) async {
    // Adjust newIndex if needed (standard ReorderableListView behavior)
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Create a mutable copy of the list
    final reorderedHabits = List<Habit>.from(habits);
    
    // Perform the reorder
    final movedHabit = reorderedHabits.removeAt(oldIndex);
    reorderedHabits.insert(newIndex, movedHabit);

    // Update the display order in the provider
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result = await habitsNotifier.updateHabitOrder(reorderedHabits);
    
    if (result != null && context.mounted) {
      final colors = ref.read(flexibleColorsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reorder habits: $result'),
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

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
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

        // Further filter occasional habits based on due dates
        final dueDateService = DueDateService();
        final today = DateTime.now();
        final visibleHabits = topLevelHabits.where((habit) {
          if (habit.type == HabitType.interval || habit.type == HabitType.weekly) {
            return dueDateService.isDue(habit, today);
          }
          return true; // Show all other habit types
        }).toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

        return _buildHabitsScaffold(context, ref, visibleHabits, allHabits, topLevelHabits);
      },
    );
  }

  Widget _buildHabitsScaffold(BuildContext context, WidgetRef ref,
      List<Habit> visibleHabits, List<Habit> allHabits, List<Habit> topLevelHabits) {
    final colors = ref.watchColors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: topLevelHabits.isEmpty
          ? _buildEmptyState(context, ref)
          : visibleHabits.isEmpty
              ? _buildNoHabitsDueToday(context, ref, topLevelHabits)
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: visibleHabits.length,
                  onReorder: (oldIndex, newIndex) => _onReorder(
                    context, ref, visibleHabits, oldIndex, newIndex),
                  itemBuilder: (context, index) {
                    final habit = visibleHabits[index];

                    Widget habitTile;
                    switch (habit.type) {
                      case HabitType.bundle:
                        habitTile = BundleHabitTile(habit: habit, allHabits: allHabits);
                        break;
                      case HabitType.stack:
                        habitTile = StackHabitTile(habit: habit, allHabits: allHabits);
                        break;
                      case HabitType.avoidance:
                        habitTile = AvoidanceHabitTile(habit: habit);
                        break;
                      case HabitType.interval:
                        habitTile = IntervalHabitTile(habit: habit);
                        break;
                      case HabitType.weekly:
                        habitTile = WeeklyHabitTile(habit: habit);
                        break;
                      case HabitType.basic:
                      default:
                        habitTile = HabitTile(habit: habit);
                        break;
                    }
                    
                    return DeletableHabitTile(
                      key: Key('habit_${habit.id}'),
                      habit: habit,
                      child: habitTile,
                    );
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

  Widget _buildNoHabitsDueToday(BuildContext context, WidgetRef ref, List<Habit> topLevelHabits) {
    final colors = ref.watchColors;
    final dueDateService = DueDateService();
    
    // Count occasional habits that exist but aren't due today
    final occasionalHabits = topLevelHabits.where((habit) =>
        habit.type == HabitType.interval || habit.type == HabitType.weekly).toList();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 80,
              color: colors.draculaComment.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'No habits due today!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.draculaForeground,
              ),
            ),
            const SizedBox(height: 12),
            if (occasionalHabits.isNotEmpty) ...[
              Text(
                'You have ${occasionalHabits.length} occasional habit${occasionalHabits.length == 1 ? '' : 's'} that will appear when due.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: colors.draculaComment,
                ),
              ),
              const SizedBox(height: 16),
              // Show next due dates
              for (final habit in occasionalHabits.take(3))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        habit.type == HabitType.interval ? '⟳' : '📅',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${habit.name}: ${dueDateService.getNextDueDescription(habit)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.draculaComment,
                        ),
                      ),
                    ],
                  ),
                ),
            ] else ...[
              Text(
                'Create some habits to start building your routine!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: colors.draculaComment,
                ),
              ),
            ],
            const SizedBox(height: 120), // Space for FAB
          ],
        ),
      ),
    );
  }
}
