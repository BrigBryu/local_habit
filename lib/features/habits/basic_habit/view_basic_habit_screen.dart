import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/app_colors.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        backgroundColor: AppColors.draculaCurrentLine,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit habit screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Habit Header
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
                  color: AppColors.draculaCyan.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.draculaCyan.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: AppColors.draculaCyan.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: AppColors.draculaCyan,
                            size: 32,
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
                                  color: AppColors.draculaPurple,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Basic Habit',
                                style: TextStyle(
                                  color: AppColors.draculaCyan,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
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
                        'Description:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.draculaPurple,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        habit.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.draculaComment,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Stats Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.draculaPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Current Streak',
                            '${habit.currentStreak}',
                            Icons.local_fire_department,
                            AppColors.draculaOrange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Today',
                            '${habit.dailyCompletionCount}x',
                            Icons.today,
                            AppColors.draculaGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Next XP',
                            '+${habit.calculateXPReward()}',
                            Icons.star,
                            AppColors.draculaPurple,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Created',
                            _formatDate(habit.createdAt),
                            Icons.calendar_today,
                            AppColors.draculaCyan,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Complete Habit Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 60,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: _isCompletedToday(habit)
                    ? null
                    : () => _completeHabit(context, ref, habit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCompletedToday(habit)
                      ? AppColors.draculaGreen
                      : AppColors.draculaPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: _isCompletedToday(habit) ? 0 : 2,
                  shadowColor: AppColors.draculaPink.withOpacity(0.3),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isCompletedToday(habit)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          key: const ValueKey('completed'),
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Completed Today!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          key: const ValueKey('incomplete'),
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.circle_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Mark as Complete',
                              style: TextStyle(
                                fontSize: 18,
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
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference}d ago';
    if (difference < 30) return '${(difference / 7).round()}w ago';
    return '${(difference / 30).round()}mo ago';
  }

  Future<void> _completeHabit(
      BuildContext context, WidgetRef ref, Habit habit) async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result = await habitsNotifier.completeHabit(habit.id);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: AppColors.draculaGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${habit.name} completed! +${habit.calculateXPReward()} XP'),
          backgroundColor: AppColors.draculaGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
