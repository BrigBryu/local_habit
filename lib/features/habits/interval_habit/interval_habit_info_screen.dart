import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/services/due_date_service.dart';
import '../../../core/theme/flexible_theme_system.dart';

class IntervalHabitInfoScreen extends ConsumerWidget {
  final Habit habit;

  const IntervalHabitInfoScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;
    final dueDateService = DueDateService();
    final today = DateTime.now();
    final isDue = dueDateService.isDue(habit, today);
    final isCompleted = isHabitCompletedToday(habit);

    return Scaffold(
      backgroundColor: colors.gruvboxBg,
      appBar: AppBar(
        backgroundColor: colors.gruvboxBg,
        foregroundColor: colors.gruvboxFg,
        title: const Text('Interval Habit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: isDue
                      ? [
                          colors.gruvboxYellow.withOpacity(0.3),
                          colors.gruvboxYellow.withOpacity(0.1),
                        ]
                      : [
                          colors.draculaComment.withOpacity(0.2),
                          colors.draculaComment.withOpacity(0.1),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isDue
                      ? colors.gruvboxYellow.withOpacity(0.5)
                      : colors.draculaComment.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isDue
                              ? colors.gruvboxYellow.withOpacity(0.15)
                              : colors.draculaComment.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDue
                                ? colors.gruvboxYellow.withOpacity(0.3)
                                : colors.draculaComment.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.schedule,
                                color: isDue
                                    ? colors.gruvboxYellow
                                    : colors.draculaComment,
                                size: 32,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Text(
                                '⟳',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.gruvboxYellow,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDue
                                    ? colors.gruvboxYellow
                                    : colors.draculaComment,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Interval Habit',
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.gruvboxFg.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (habit.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      habit.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.gruvboxFg.withOpacity(0.9),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Interval Configuration
            _buildInfoCard(
              colors,
              'Interval Configuration',
              [
                _buildInfoRow(
                  'Interval',
                  '${habit.intervalDays ?? 1} days',
                  Icons.schedule,
                  colors,
                ),
                _buildInfoRow(
                  'Next Due',
                  dueDateService.getNextDueDescription(habit).isNotEmpty
                      ? dueDateService.getNextDueDescription(habit)
                      : 'Today',
                  Icons.calendar_today,
                  colors,
                ),
                _buildInfoRow(
                  'Status',
                  isDue
                      ? isCompleted
                          ? 'Completed today'
                          : 'Due now'
                      : 'Not due',
                  isDue ? Icons.check_circle : Icons.schedule,
                  colors,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Stats
            _buildInfoCard(
              colors,
              'Progress',
              [
                _buildInfoRow(
                  'Current Streak',
                  '${getCurrentStreak(habit)} days',
                  Icons.local_fire_department,
                  colors,
                ),
                _buildInfoRow(
                  'XP per completion',
                  '${habit.calculateXPReward()} XP',
                  Icons.star,
                  colors,
                ),
                _buildInfoRow(
                  'Last Completed',
                  habit.lastCompletionDate != null
                      ? _formatDate(habit.lastCompletionDate!)
                      : 'Never',
                  Icons.history,
                  colors,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Complete Button (only when due)
            if (isDue && !isCompleted)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _completeHabit(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.gruvboxYellow,
                    foregroundColor: colors.gruvboxBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Complete Habit (+${habit.calculateXPReward()} XP)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      FlexibleColors colors, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.gruvboxBg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.gruvboxYellow.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.gruvboxFg,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      FlexibleColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colors.gruvboxYellow,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colors.gruvboxFg.withOpacity(0.8),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.gruvboxFg,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(targetDate).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _completeHabit(BuildContext context, WidgetRef ref) async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result = await habitsNotifier.completeHabit(habit.id);

    final colors = ref.read(flexibleColorsProvider);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: colors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${habit.name} completed! +${habit.calculateXPReward()} XP'),
          backgroundColor: colors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final colors = ref.read(flexibleColorsProvider);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.gruvboxBg2,
        title: Text(
          'Delete Habit',
          style: TextStyle(color: colors.gruvboxFg),
        ),
        content: Text(
          'Are you sure you want to delete "${habit.name}"? This action cannot be undone.',
          style: TextStyle(color: colors.gruvboxFg.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.gruvboxFg),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: colors.gruvboxRed),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      ref.read(habitsNotifierProvider.notifier).removeHabit(habit.id);
      Navigator.of(context).pop();
    }
  }
}