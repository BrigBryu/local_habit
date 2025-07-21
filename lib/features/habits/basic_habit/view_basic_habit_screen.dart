import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/theme_controller.dart';

class ViewBasicHabitScreen extends ConsumerWidget {
  final String habitId;

  const ViewBasicHabitScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final habit = habitsAsync.value?.firstWhere((h) => h.id == habitId,
            orElse: () => Habit.create(
                name: 'Unknown', description: '', type: HabitType.basic)) ??
        Habit.create(name: 'Unknown', description: '', type: HabitType.basic);
    
    final isCompleted = _isCompletedToday(habit);
    final colors = ref.watchColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          habit.name,
          style: TextStyle(color: colors.draculaForeground),
        ),
        backgroundColor: colors.draculaCurrentLine,
        iconTheme: IconThemeData(color: colors.draculaForeground),
      ),
      backgroundColor: colors.draculaBackground,
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
              'Type: Basic Habit',
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
              'Streak: ${habit.currentStreak} days',
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
          ],
        ),
      ),
    );
  }

  bool _isCompletedToday(Habit habit) {
    if (habit.lastCompleted == null) return false;
    final now = DateTime.now();
    final lastCompleted = habit.lastCompleted!;
    return now.year == lastCompleted.year &&
        now.month == lastCompleted.month &&
        now.day == lastCompleted.day;
  }

  int _getCoinsForNextCompletion(Habit habit) {
    // Calculate coins based on streak length + 1 (capped at 30)
    final nextStreak = habit.currentStreak + 1;
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
}