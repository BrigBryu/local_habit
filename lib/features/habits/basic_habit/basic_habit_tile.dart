import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/app_colors.dart';
import 'basic_habit_info_screen.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;

  const HabitTile({
    super.key,
    required this.habit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = isHabitCompletedToday(habit);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            isCompleted 
              ? AppColors.draculaGreen.withOpacity(0.4)
              : AppColors.draculaCurrentLine.withOpacity(0.6),
            isCompleted 
              ? AppColors.draculaGreen.withOpacity(0.1)
              : AppColors.draculaCurrentLine.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isCompleted 
            ? AppColors.draculaGreen.withOpacity(0.4)
            : AppColors.draculaCyan.withOpacity(0.4),
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
                    color: _getHabitTypeColor().withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getHabitTypeColor().withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getHabitTypeIcon(),
                    color: _getHabitTypeColor(),
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
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? AppColors.draculaGreen : AppColors.draculaPurple,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _buildSubtitleText(),
                        style: TextStyle(
                          color: isCompleted ? AppColors.draculaGreen : AppColors.draculaCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (habit.description.isNotEmpty && !_buildSubtitleText().contains(habit.description)) ...[
                        const SizedBox(height: 2),
                        Text(
                          habit.description,
                          style: TextStyle(
                            color: AppColors.draculaComment,
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
        final count = isHabitCompletedToday(habit) ? habit.dailyCompletionCount : 0;
        if (count > 0) {
          return 'Basic Habit · $count completed today';
        }
        // Show description if available, otherwise show basic habit type
        return habit.description.isNotEmpty 
            ? habit.description 
            : 'Basic Habit';
        
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
  
  Color _getHabitTypeColor() {
    switch (habit.type) {
      case HabitType.basic:
        return AppColors.draculaCyan;
      case HabitType.avoidance:
        return AppColors.draculaRed;
      case HabitType.bundle:
        return AppColors.draculaPurple;
      case HabitType.stack:
        return AppColors.draculaOrange;
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
          color: AppColors.draculaGreen,
          boxShadow: [
            BoxShadow(
              color: AppColors.draculaGreen.withOpacity(0.3),
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
          color: AppColors.draculaCurrentLine.withOpacity(0.15),
          border: Border.all(
            color: AppColors.draculaPink,
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
          color: AppColors.draculaPink,
          size: 24,
        ),
      ),
    );
  }

  void _completeHabit(BuildContext context, WidgetRef ref) {
    final habitsNotifier = ref.read(habitsProvider.notifier);
    final result = habitsNotifier.completeHabit(habit.id);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: AppColors.draculaGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${habit.name} completed! +${habit.calculateXPReward()} XP'),
          backgroundColor: AppColors.draculaGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}