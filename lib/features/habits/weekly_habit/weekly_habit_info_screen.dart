import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../core/services/due_date_service.dart';
import '../../../core/theme/theme_controller.dart';

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
      backgroundColor: colors.draculaBackground,
      appBar: AppBar(
        backgroundColor: colors.draculaCurrentLine,
        foregroundColor: colors.draculaForeground,
        title: Text(
          habit.name,
          style: TextStyle(color: colors.draculaForeground),
        ),
        iconTheme: IconThemeData(color: colors.draculaForeground),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            Text(
              habit.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.draculaPurple,
              ),
            ),
            const SizedBox(height: 16),
            
            // Description
            if (habit.description.isNotEmpty) ...[
              Text(
                habit.description,
                style: TextStyle(
                  fontSize: 16,
                  color: colors.draculaCyan,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Habit Type
            Text(
              'Type: Weekly Habit',
              style: TextStyle(
                fontSize: 16,
                color: colors.draculaYellow,
              ),
            ),
            const SizedBox(height: 16),
            
            // Status
            Text(
              'Status: ${isCompleted ? 'Completed' : 'Not completed'}',
              style: TextStyle(
                fontSize: 16,
                color: isCompleted ? colors.draculaGreen : colors.draculaOrange,
              ),
            ),
            const SizedBox(height: 16),
            
            // Streak
            Text(
              'Streak: ${getCurrentStreak(habit)} days',
              style: TextStyle(
                fontSize: 16,
                color: colors.draculaPink,
              ),
            ),
            const SizedBox(height: 16),
            
            // Coins award for next completion
            Text(
              'Coins award for next completion: ${_getCoinsForNextCompletion(habit)}',
              style: TextStyle(
                fontSize: 16,
                color: colors.draculaCyan,
              ),
            ),
            const SizedBox(height: 16),
            
            // Active days
            Text(
              'Active Days: ${_getWeekdayText(dueDateService)}',
              style: TextStyle(
                fontSize: 16,
                color: colors.draculaForeground,
              ),
            ),
            const SizedBox(height: 16),
            
            // Next due
            Text(
              'Next Due: ${dueDateService.getNextDueDescription(habit).isNotEmpty ? dueDateService.getNextDueDescription(habit) : 'Today'}',
              style: TextStyle(
                fontSize: 16,
                color: colors.draculaForeground,
              ),
            ),
            const SizedBox(height: 16),
            
            // Today status
            Text(
              'Today: ${_getTodayStatus(dueDateService, isDue)}',
              style: TextStyle(
                fontSize: 16,
                color: isDue ? colors.draculaGreen : colors.draculaComment,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCoinsForNextCompletion(Habit habit) {
    // Calculate coins based on streak length + 1 (capped at 30)
    final nextStreak = getCurrentStreak(habit) + 1;
    final baseAward = nextStreak.clamp(1, 30);
    
    // Calculate milestone bonuses
    int milestoneBonus = 0;
    if (nextStreak == 7) {
      milestoneBonus = 10;
    } else if (nextStreak == 30) {
      milestoneBonus = 25;
    } else if (nextStreak == 100) {
      milestoneBonus = 75;
    }
    
    return baseAward + milestoneBonus;
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
}