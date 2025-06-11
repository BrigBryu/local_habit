import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/flexible_theme_system.dart';

class BasicHabitInfoScreen extends ConsumerWidget {
  final Habit habit;

  const BasicHabitInfoScreen({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final currentHabit = habitsAsync.value?.firstWhere((h) => h.id == habit.id) ?? habit;
    final isCompleted = _isHabitCompletedToday(currentHabit);
    final colors = ref.watchColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          habit.name,
          style: TextStyle(color: colors.draculaForeground),
        ),
        backgroundColor: colors.draculaCurrentLine,
        iconTheme: IconThemeData(color: colors.draculaForeground),
        actions: [
          if (!isCompleted)
            TextButton.icon(
              onPressed: () => _completeHabit(context, ref),
              icon: Icon(Icons.check, color: colors.draculaGreen),
              label: Text('Complete', style: TextStyle(color: colors.draculaGreen)),
            ),
        ],
      ),
      backgroundColor: colors.draculaBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit Header Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    colors.draculaCurrentLine.withOpacity(0.6),
                    colors.draculaCurrentLine.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: colors.draculaCyan.withOpacity(0.3),
                  width: 2,
                ),
              ),
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
                                  color: colors.draculaPurple,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Basic Habit',
                                style: TextStyle(
                                  color: colors.draculaCyan,
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
                              ? colors.draculaGreen.withOpacity(0.15)
                              : colors.draculaCurrentLine.withOpacity(0.15),
                            border: Border.all(
                              color: isCompleted 
                                ? colors.draculaGreen
                                : colors.draculaCyan,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            isCompleted ? Icons.check_circle : Icons.circle_outlined,
                            color: isCompleted 
                              ? colors.draculaGreen
                              : colors.draculaCyan,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    if (habit.description.isNotEmpty) ...[ 
                      const SizedBox(height: 16),
                      Text(
                        habit.description,
                        style: TextStyle(fontSize: 16, color: colors.draculaCyan),
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
                color: colors.draculaPurple,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    colors.draculaCurrentLine.withOpacity(0.6),
                    colors.draculaCurrentLine.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: colors.draculaPurple.withOpacity(0.3),
                  width: 2,
                ),
              ),
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
                            isCompleted ? colors.draculaGreen : colors.draculaOrange,
                            isCompleted ? Icons.check_circle : Icons.schedule,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: colors.draculaComment.withOpacity(0.3),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Streak',
                            '${currentHabit.currentStreak} days',
                            colors.draculaPink,
                            Icons.local_fire_department,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: colors.draculaComment.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Completions Today',
                            '${currentHabit.dailyCompletionCount}',
                            colors.draculaCyan,
                            Icons.today,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: colors.draculaComment.withOpacity(0.3),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Type',
                            'Basic',
                            colors.draculaYellow,
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
                color: colors.draculaPurple,
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
                            colors.draculaGreen,
                            colors.draculaGreen.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: colors.draculaGreen.withOpacity(0.3),
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
                            colors.draculaGreen.withOpacity(0.6),
                            colors.draculaGreen.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: colors.draculaGreen, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Completed!',
                              style: TextStyle(
                                color: colors.draculaGreen,
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
                    colors.draculaCurrentLine.withOpacity(0.6),
                    colors.draculaCurrentLine.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: colors.draculaYellow.withOpacity(0.3),
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
                        Icon(Icons.lightbulb_outline, color: colors.draculaYellow),
                        const SizedBox(width: 8),
                        Text(
                          'Tips for Success',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colors.draculaYellow,
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
                        color: colors.draculaForeground,
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
    return Consumer(
      builder: (context, ref, child) {
        final colors = ref.watchColors;
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
                color: colors.draculaComment,
              ),
            ),
          ],
        );
      }
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

  Future<void> _completeHabit(BuildContext context, WidgetRef ref) async {
    if (_isHabitCompletedToday(habit)) return;
    
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result = await habitsNotifier.completeHabit(habit.id);
    final colors = ref.watchColors;
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${habit.name} completed! +${habit.calculateXPReward()} XP'),
          backgroundColor: colors.draculaGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}