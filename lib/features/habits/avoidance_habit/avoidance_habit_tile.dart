import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/flexible_theme_system.dart';

/// Tile for displaying avoidance habits with success/failure buttons
class AvoidanceHabitTile extends ConsumerWidget {
  final Habit habit;
  
  const AvoidanceHabitTile({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              habit.avoidanceSuccessToday 
                ? colors.success.withOpacity(0.1)
                : colors.error.withOpacity(0.05),
              habit.avoidanceSuccessToday 
                ? colors.success.withOpacity(0.05)
                : colors.error.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.avoidanceHabit,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.block,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            habit.name,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              decoration: habit.avoidanceSuccessToday ? TextDecoration.lineThrough : null,
              color: habit.avoidanceSuccessToday ? colors.success : null,
            ),
          ),
          subtitle: Text(
            _getSubtitleText(),
            style: TextStyle(
              color: colors.draculaComment,
              fontSize: 14,
            ),
          ),
          trailing: _buildTrailingWidget(context, ref),
        ),
      ),
    );
  }

  String _getSubtitleText() {
    final failures = habit.dailyFailureCount;
    if (habit.avoidanceSuccessToday) {
      return 'Successfully avoided today!';
    } else if (failures > 0) {
      return 'Failed $failures time(s) today';
    }
    return 'Tap ✅ if avoided, ❌ if failed';
  }

  Widget _buildTrailingWidget(BuildContext context, WidgetRef ref) {
    if (habit.avoidanceSuccessToday) {
      return Icon(Icons.check_circle, color: colors.success, size: 32);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Failure button
        GestureDetector(
          onTap: () => _recordFailure(context, ref),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.error.withOpacity(0.3)),
            ),
            child: Icon(Icons.close, color: colors.error, size: 24),
          ),
        ),
        const SizedBox(width: 12),
        // Success button
        GestureDetector(
          onTap: () => _markSuccess(context, ref),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.success.withOpacity(0.3)),
            ),
            child: Icon(Icons.check, color: colors.success, size: 24),
          ),
        ),
      ],
    );
  }

  void _recordFailure(BuildContext context, WidgetRef ref) {
    final habitsNotifier = ref.read(habitsProvider.notifier);
    final result = habitsNotifier.recordFailure(habit.id);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: colors.error,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failure recorded for ${habit.name}'),
          backgroundColor: colors.error,
        ),
      );
    }
  }

  void _markSuccess(BuildContext context, WidgetRef ref) {
    final habitsNotifier = ref.read(habitsProvider.notifier);
    final result = habitsNotifier.completeHabit(habit.id);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: colors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${habit.name} avoided successfully!'),
          backgroundColor: colors.success,
        ),
      );
    }
  }
}