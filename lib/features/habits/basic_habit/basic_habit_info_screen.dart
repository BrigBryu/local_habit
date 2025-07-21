import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/habit.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/theme_controller.dart';

class BasicHabitInfoScreen extends ConsumerWidget {
  final Habit habit;

  const BasicHabitInfoScreen({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final currentHabit =
        habitsAsync.value?.firstWhere((h) => h.id == habit.id) ?? habit;
    final isCompleted = currentHabit.isCompletedToday;
    final colors = ref.watchColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          habit.name,
          style: TextStyle(
            color: colors.draculaForeground,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.draculaCurrentLine,
        iconTheme: IconThemeData(color: colors.draculaForeground),
      ),
      backgroundColor: colors.draculaBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Habit type
            Text(
              'Basic Habit',
              style: TextStyle(
                fontSize: 16,
                color: colors.draculaYellow,
              ),
            ),
            const SizedBox(height: 12),
            
            // Description section
            if (currentHabit.description.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.draculaCurrentLine,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentHabit.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.draculaForeground,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              const SizedBox(height: 4),
            ],
            
            // Streak display
            Text(
              'Streak: ${currentHabit.streak}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.draculaPink,
              ),
            ),
            const SizedBox(height: 16),
            
            // Completed Today checkbox/toggle
            Row(
              children: [
                Checkbox(
                  value: isCompleted,
                  onChanged: currentHabit.type == HabitType.basic && isCompleted
                      ? null  // Disable checkbox for completed basic habits
                      : (value) async {
                          final notifier = ref.read(habitsNotifierProvider.notifier);
                          await notifier.toggleComplete(currentHabit);
                        },
                  activeColor: colors.draculaGreen,
                ),
                Text(
                  'Completed Today',
                  style: TextStyle(
                    fontSize: 18,
                    color: colors.draculaForeground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Settings section (expandable)
            ExpansionTile(
              title: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.draculaCyan,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created: ${_formatDate(currentHabit.createdAt)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.draculaForeground,
                        ),
                      ),
                      if (currentHabit.lastCompletedAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Last completed: ${_formatDate(currentHabit.lastCompletedAt)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.draculaForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Never';
    return '${date.day}/${date.month}/${date.year}';
  }
}
