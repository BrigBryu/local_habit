import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/services/due_date_service.dart';
import '../../../core/theme/flexible_theme_system.dart';

class WeeklyHabitInfoScreen extends ConsumerWidget {
  final Habit habit;

  const WeeklyHabitInfoScreen({super.key, required this.habit});

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
        title: const Text('Weekly Habit'),
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
                          colors.gruvboxBlue.withOpacity(0.3),
                          colors.gruvboxBlue.withOpacity(0.1),
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
                      ? colors.gruvboxBlue.withOpacity(0.5)
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
                              ? colors.gruvboxBlue.withOpacity(0.15)
                              : colors.draculaComment.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDue
                                ? colors.gruvboxBlue.withOpacity(0.3)
                                : colors.draculaComment.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.event_repeat,
                                color: isDue
                                    ? colors.gruvboxBlue
                                    : colors.draculaComment,
                                size: 32,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Text(
                                '📅',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.gruvboxBlue,
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
                                    ? colors.gruvboxBlue
                                    : colors.draculaComment,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Weekly Habit',
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

            // Weekly Configuration
            _buildInfoCard(
              colors,
              'Weekly Configuration',
              [
                _buildInfoRow(
                  'Active Days',
                  _getWeekdayText(dueDateService),
                  Icons.calendar_view_week,
                  colors,
                ),
                _buildInfoRow(
                  'Today',
                  _getTodayStatus(dueDateService, isDue),
                  isDue ? Icons.check_circle : Icons.schedule,
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
              ],
            ),
            const SizedBox(height: 16),

            // Weekly Schedule Visualization
            _buildWeekScheduleCard(colors, dueDateService),
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
                  habit.lastCompleted != null
                      ? _formatDate(habit.lastCompleted!)
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
                    backgroundColor: colors.gruvboxBlue,
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
          color: colors.gruvboxBlue.withOpacity(0.2),
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

  Widget _buildWeekScheduleCard(FlexibleColors colors, DueDateService dueDateService) {
    if (habit.weekdayMask == null) return const SizedBox();

    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final today = DateTime.now();
    final todayWeekday = today.weekday % 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.gruvboxBg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.gruvboxBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Schedule',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.gruvboxFg,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final isActive = (habit.weekdayMask! & (1 << index)) != 0;
              final isToday = index == todayWeekday;
              
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isActive
                      ? isToday
                          ? colors.gruvboxBlue
                          : colors.gruvboxBlue.withOpacity(0.3)
                      : colors.gruvboxBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isToday
                        ? colors.gruvboxBlue
                        : isActive
                            ? colors.gruvboxBlue.withOpacity(0.5)
                            : colors.gruvboxFg.withOpacity(0.2),
                    width: isToday ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    dayNames[index],
                    style: TextStyle(
                      color: isActive
                          ? isToday
                              ? Colors.white
                              : colors.gruvboxBlue
                          : colors.gruvboxFg.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              );
            }),
          ),
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
            color: colors.gruvboxBlue,
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

  String _getWeekdayText(DueDateService dueDateService) {
    if (habit.weekdayMask == null) return 'None selected';
    final dayNames = dueDateService.getWeekdayNames(habit.weekdayMask!);
    return dayNames.join(', ');
  }

  String _getTodayStatus(DueDateService dueDateService, bool isDue) {
    if (isDue) {
      return isHabitCompletedToday(habit) ? 'Completed' : 'Due now';
    } else {
      return 'Not active';
    }
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