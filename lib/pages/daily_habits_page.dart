import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habits_provider.dart';
import '../core/models/habit.dart';
import '../core/theme/theme_controller.dart';
import '../screens/add_habit_screen.dart';
import '../features/habits/basic_habit/basic_habit_info_screen.dart';
import '../features/habits/common/deletable_habit_tile.dart';

class DailyHabitsPage extends ConsumerWidget {
  const DailyHabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitListProvider);

    return habitsAsync.when(
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
      data: (habits) => _buildHabitsScaffold(context, ref, habits),
    );
  }

  Widget _buildHabitsScaffold(BuildContext context, WidgetRef ref, List<Habit> habits) {
    final colors = ref.watchColors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: habits.isEmpty
          ? _buildEmptyState(context, ref)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return _buildHabitTile(context, ref, habit);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddHabitScreen(),
            ),
          );
        },
        tooltip: 'Add New Habit',
        backgroundColor: colors.primaryPurple,
        child: Icon(Icons.add, color: colors.draculaBackground),
      ),
    );
  }

  Widget _buildHabitTile(BuildContext context, WidgetRef ref, Habit habit) {
    final colors = ref.watchColors;
    
    return DeletableHabitTile(
      habit: habit,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: Checkbox(
            value: habit.isCompletedToday,
            onChanged: habit.type == HabitType.basic && habit.isCompletedToday
                ? null  // Disable checkbox for completed basic habits
                : (value) async {
                    final notifier = ref.read(habitsNotifierProvider.notifier);
                    await notifier.toggleComplete(habit);
                  },
            activeColor: colors.draculaGreen,
          ),
          title: Text(
            habit.displayName,
            style: TextStyle(
              color: colors.draculaForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            'Streak: ${habit.streak}',
            style: TextStyle(
              color: colors.draculaPink,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.info_outline, color: colors.draculaCyan),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BasicHabitInfoScreen(habit: habit),
                ),
              );
            },
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BasicHabitInfoScreen(habit: habit),
              ),
            );
          },
        ),
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
              color: colors.draculaComment.withValues(alpha: 0.6),
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
