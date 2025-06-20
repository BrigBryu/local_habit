import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/services/due_date_service.dart';
import '../../../core/theme/flexible_theme_system.dart';
import 'weekly_habit_info_screen.dart';

class WeeklyHabitTile extends ConsumerWidget {
  final Habit habit;
  final VoidCallback? onTap;

  const WeeklyHabitTile({
    super.key,
    required this.habit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueDateService = DueDateService();
    final today = DateTime.now();
    final isDue = dueDateService.isDue(habit, today);
    final isCompleted = dueDateService.isCompletedToday(habit, today);
    final colors = ref.watchColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: isCompleted
              ? [
                  colors.successBg.withOpacity(0.8),
                  colors.successBg.withOpacity(0.4),
                ]
              : isDue
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
          color: isCompleted
              ? colors.successFg.withOpacity(0.6)
              : isDue
                  ? colors.gruvboxBlue.withOpacity(0.5)
                  : colors.draculaComment.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: (isDue && !isCompleted) ? (onTap ?? () => _navigateToHabitInfo(context)) : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Habit type icon with corner badge
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? colors.successBg.withOpacity(0.3)
                            : isDue
                                ? colors.gruvboxBlue.withOpacity(0.15)
                                : colors.draculaComment.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? colors.successFg.withOpacity(0.5)
                              : isDue
                                  ? colors.gruvboxBlue.withOpacity(0.3)
                                  : colors.draculaComment.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.event_repeat,
                        color: isCompleted
                            ? colors.successFg
                            : isDue
                                ? colors.gruvboxBlue
                                : colors.draculaComment,
                        size: 24,
                      ),
                    ),
                    // Corner badge for weekly type
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colors.gruvboxBlue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.gruvboxBg,
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          '📅',
                          style: TextStyle(
                            fontSize: 6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Habit info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted
                              ? colors.successFg
                              : isDue
                                  ? colors.gruvboxBlue
                                  : colors.draculaComment,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _buildSubtitleText(dueDateService),
                        style: TextStyle(
                          color: isCompleted
                              ? colors.successFg
                              : isDue
                                  ? colors.gruvboxFg
                                  : colors.draculaComment,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (habit.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          habit.description,
                          style: TextStyle(
                            color: colors.draculaComment,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Completion button (only active when due and not completed)
                if (isDue)
                  _buildTrailingWidget(context)
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.draculaComment.withOpacity(0.1),
                      border: Border.all(
                        color: colors.draculaComment.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.event_busy,
                      color: colors.draculaComment,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildSubtitleText(DueDateService dueDateService) {
    final today = DateTime.now();
    final isDue = dueDateService.isDue(habit, today);
    
    if (habit.weekdayMask == null) {
      return 'Weekly · No days selected';
    }

    final dayNames = dueDateService.getWeekdayNames(habit.weekdayMask!);
    final shortDayNames = dayNames.map((name) => name.substring(0, 3)).join(', ');

    final isCompleted = dueDateService.isCompletedToday(habit, today);
    
    if (isCompleted) {
      return 'Weekly ($shortDayNames) · Completed today';
    } else if (isDue) {
      return 'Weekly ($shortDayNames) · Due now';
    } else {
      final nextDueDescription = dueDateService.getNextDueDescription(habit);
      return 'Weekly ($shortDayNames) · $nextDueDescription';
    }
  }

  Widget _buildTrailingWidget(BuildContext context) {
    return WeeklyHabitCheckButton(habit: habit);
  }

  void _navigateToHabitInfo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WeeklyHabitInfoScreen(habit: habit),
      ),
    );
  }
}

class WeeklyHabitCheckButton extends ConsumerWidget {
  final Habit habit;

  const WeeklyHabitCheckButton({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueDateService = DueDateService();
    final today = DateTime.now();
    final isCompleted = dueDateService.isCompletedToday(habit, today);
    final colors = ref.watchColors;

    if (isCompleted) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.successFg,
          boxShadow: [
            BoxShadow(
              color: colors.successFg.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 24,
        ),
      );
    }

    return GestureDetector(
      onTap: () => _completeHabit(context, ref),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.gruvboxBlue.withOpacity(0.15),
          border: Border.all(
            color: colors.gruvboxBlue,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          Icons.circle_outlined,
          color: colors.gruvboxBlue,
          size: 24,
        ),
      ),
    );
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
}