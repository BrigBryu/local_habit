import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/app_colors.dart';

class BasicHabitInfoScreen extends ConsumerWidget {
  final Habit habit;

  const BasicHabitInfoScreen({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentHabit = ref.watch(habitsProvider).firstWhere((h) => h.id == habit.id);
    final isCompleted = _isHabitCompletedToday(currentHabit);

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        backgroundColor: AppColors.draculaCurrentLine,
        actions: [
          if (!isCompleted)
            TextButton.icon(
              onPressed: () => _completeHabit(context, ref),
              icon: Icon(Icons.check, color: AppColors.draculaGreen),
              label: Text('Complete', style: TextStyle(color: AppColors.draculaGreen)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.draculaPurple,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Basic Habit',
                                style: TextStyle(
                                  color: AppColors.draculaCyan,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Completion Status
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted 
                              ? AppColors.draculaGreen.withOpacity(0.15)
                              : AppColors.draculaCurrentLine.withOpacity(0.15),
                            border: Border.all(
                              color: isCompleted 
                                ? AppColors.draculaGreen
                                : AppColors.draculaCyan,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            isCompleted ? Icons.check_circle : Icons.circle_outlined,
                            color: isCompleted 
                              ? AppColors.draculaGreen
                              : AppColors.draculaCyan,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    if (habit.description.isNotEmpty) ...[ 
                      const SizedBox(height: 16),
                      Text(
                        habit.description,
                        style: TextStyle(fontSize: 16, color: AppColors.draculaCyan),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // Habit Stats
            Text(
              'Today\'s Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.draculaPurple,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Status',
                            isCompleted ? 'Completed' : 'Not completed',
                            isCompleted ? AppColors.draculaGreen : AppColors.draculaOrange,
                            isCompleted ? Icons.check_circle : Icons.schedule,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.draculaComment.withOpacity(0.3),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Streak',
                            '${currentHabit.currentStreak} days',
                            AppColors.draculaPink,
                            Icons.local_fire_department,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: AppColors.draculaComment.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Completions Today',
                            '${currentHabit.dailyCompletionCount}',
                            AppColors.draculaCyan,
                            Icons.today,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.draculaComment.withOpacity(0.3),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Type',
                            'Basic',
                            AppColors.draculaYellow,
                            Icons.check_circle_outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.draculaPurple,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                if (!isCompleted)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.draculaGreen,
                            AppColors.draculaGreen.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.draculaGreen.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _completeHabit(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.check, size: 20),
                        label: const Text('Complete Habit', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                if (isCompleted)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.draculaGreen.withOpacity(0.6),
                            AppColors.draculaGreen.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: AppColors.draculaGreen, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Completed!',
                              style: TextStyle(
                                color: AppColors.draculaGreen,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Tips Section
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppColors.draculaCurrentLine.withOpacity(0.6),
                    AppColors.draculaCurrentLine.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppColors.draculaYellow.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: AppColors.draculaYellow),
                        const SizedBox(width: 8),
                        Text(
                          'Tips for Success',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.draculaYellow,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Complete your habit at the same time each day\n'
                      '• Start small and build consistency\n'
                      '• Track your progress and celebrate wins\n'
                      '• Don\'t break the chain - aim for daily completion',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.draculaForeground,
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

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.draculaComment,
          ),
        ),
      ],
    );
  }

  bool _isHabitCompletedToday(Habit habit) {
    if (habit.lastCompleted == null) return false;
    final now = DateTime.now();
    final lastCompleted = habit.lastCompleted!;
    return now.year == lastCompleted.year &&
           now.month == lastCompleted.month &&
           now.day == lastCompleted.day;
  }

  void _completeHabit(BuildContext context, WidgetRef ref) {
    if (_isHabitCompletedToday(habit)) return;
    
    final habitsNotifier = ref.read(habitsProvider.notifier);
    final result = habitsNotifier.completeHabit(habit.id);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${habit.name} completed! +${habit.calculateXPReward()} XP'),
          backgroundColor: AppColors.draculaGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}