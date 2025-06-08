import 'package:flutter/material.dart';
import 'package:domain/domain.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          habit.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _buildSubtitleText(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getHabitTypeColor(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            _getHabitTypeIcon(),
            color: Colors.white,
            size: 20,
          ),
        ),
        trailing: _buildTrailingWidget(context),
      ),
    );
  }

  String _buildSubtitleText() {
    switch (habit.type) {
      case HabitType.basic:
        final count = isHabitCompletedToday(habit) ? habit.dailyCompletionCount : 0;
        if (count > 0) {
          return 'Repeatable · $count completed today';
        }
        return 'Repeatable · Not completed today';
        
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

  Color _getHabitTypeColor(BuildContext context) {
    switch (habit.type) {
      case HabitType.basic:
        return Colors.blue;
      case HabitType.avoidance:
        return Colors.red;
      case HabitType.bundle:
        return Colors.purple;
      // TODO(bridger): Disabled time-based habit types
      // case HabitType.alarmHabit:
      //   return Colors.orange;
      // case HabitType.timeWindow:
      // case HabitType.dailyTimeWindow:
      //   return Colors.green;
      // case HabitType.timedSession:
      //   return Colors.teal;
      case HabitType.stack:
        return Colors.indigo;
    }
  }

  IconData _getHabitTypeIcon() {
    switch (habit.type) {
      case HabitType.basic:
        return Icons.check_circle;
      case HabitType.avoidance:
        return Icons.block;
      case HabitType.bundle:
        return Icons.folder;
      // TODO(bridger): Disabled time-based habit types
      // case HabitType.alarmHabit:
      //   return Icons.alarm;
      // case HabitType.timeWindow:
      // case HabitType.dailyTimeWindow:
      //   return Icons.schedule;
      // case HabitType.timedSession:
      //   return Icons.timer;
      case HabitType.stack:
        return Icons.layers;
    }
  }

  Widget? _buildTrailingWidget(BuildContext context) {
    if (isHabitCompletedToday(habit)) {
      return Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 24,
      );
    }
    
    return Icon(
      Icons.chevron_right,
      color: Colors.grey[400],
      size: 20,
    );
  }
}