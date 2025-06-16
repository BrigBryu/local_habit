import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/flexible_theme_system.dart';
import 'basic_habit_info_screen.dart';

class HabitTile extends ConsumerWidget {
  final Habit habit;
  final VoidCallback? onTap;

  const HabitTile({
    super.key,
    required this.habit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = isHabitCompletedToday(habit);
    final colors = ref.watchColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            isCompleted
                ? colors.completedBackground.withOpacity(0.8)
                : colors.draculaCurrentLine.withOpacity(0.6),
            isCompleted
                ? colors.completedBackground.withOpacity(0.4)
                : colors.draculaCurrentLine.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isCompleted
              ? colors.completedBorder.withOpacity(0.8)
              : colors.basicHabit.withOpacity(0.4),
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
          onTap: onTap ?? () => _navigateToHabitInfo(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Habit type icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getHabitTypeColor(ref).withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getHabitTypeColor(ref).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getHabitTypeIcon(),
                    color: _getHabitTypeColor(ref),
                    size: 24,
                  ),
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
                              ? colors.completedTextOnGreen
                              : colors.draculaPurple,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _buildSubtitleText(),
                        style: TextStyle(
                          color: isCompleted
                              ? colors.completedTextOnGreen
                              : colors.basicHabit,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (habit.description.isNotEmpty &&
                          !_buildSubtitleText()
                              .contains(habit.description)) ...[
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
                // Completion button
                _buildTrailingWidget(context) ?? const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildSubtitleText() {
    switch (habit.type) {
      case HabitType.basic:
        final count =
            isHabitCompletedToday(habit) ? habit.dailyCompletionCount : 0;
        if (count > 0) {
          return 'Basic Habit · $count completed today';
        }
        // Show description if available, otherwise show basic habit type
        return habit.description.isNotEmpty ? habit.description : 'Basic Habit';

      case HabitType.avoidance:
        final failures = habit.dailyFailureCount;
        if (habit.avoidanceSuccessToday) {
          return 'Avoidance · Success today';
        } else if (failures > 0) {
          return 'Avoidance · $failures failure(s) today';
        }
        return 'Avoidance · In progress';

      case HabitType.bundle:
        final childCount = habit.bundleChildIds?.length ?? 0;
        return 'Bundle · $childCount habits';

      // TODO(bridger): Disabled time-based habit types
      // case HabitType.alarmHabit:
      //   final timeStr = habit.alarmTime?.format24Hour() ?? 'No time set';
      //   return 'Alarm · $timeStr';
      //
      // case HabitType.timeWindow:
      // case HabitType.dailyTimeWindow:
      //   final start = habit.windowStartTime?.format24Hour() ?? '';
      //   final end = habit.windowEndTime?.format24Hour() ?? '';
      //   return 'Time Window · $start - $end';
      //
      // case HabitType.timedSession:
      //   final minutes = habit.timeoutMinutes ?? 0;
      //   return 'Timed Session · ${minutes}min';

      case HabitType.stack:
        return 'Habit Stack';
    }
  }

  Widget? _buildTrailingWidget(BuildContext context) {
    return HomeHabitCheckButton(habit: habit);
  }

  Color _getHabitTypeColor(WidgetRef ref) {
    final colors = ref.watchColors;
    switch (habit.type) {
      case HabitType.basic:
        return colors.basicHabit;
      case HabitType.avoidance:
        return colors.avoidanceHabit;
      case HabitType.bundle:
        return colors.bundleHabit;
      case HabitType.stack:
        return colors.stackHabit;
    }
  }

  IconData _getHabitTypeIcon() {
    switch (habit.type) {
      case HabitType.basic:
        return Icons.check_circle_outline;
      case HabitType.avoidance:
        return Icons.block;
      case HabitType.bundle:
        return Icons.folder_special;
      case HabitType.stack:
        return Icons.layers;
    }
  }

  void _navigateToHabitInfo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BasicHabitInfoScreen(habit: habit),
      ),
    );
  }
}

/// Simplified checkmark button for home page habit tiles
class HomeHabitCheckButton extends ConsumerWidget {
  final Habit habit;

  const HomeHabitCheckButton({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = isHabitCompletedToday(habit);

    if (isCompleted) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ref.watchColors.completed,
          boxShadow: [
            BoxShadow(
              color: ref.watchColors.completed.withOpacity(0.3),
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
          color: ref.watchColors.draculaCurrentLine.withOpacity(0.15),
          border: Border.all(
            color: ref.watchColors.draculaPink,
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
          color: ref.watchColors.draculaPink,
          size: 24,
        ),
      ),
    );
  }

  Future<void> _completeHabit(BuildContext context, WidgetRef ref) async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result = await habitsNotifier.completeHabit(habit.id);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: ref.read(flexibleColorsProvider).success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${habit.name} completed! +${habit.calculateXPReward()} XP'),
          backgroundColor: ref.read(flexibleColorsProvider).success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
