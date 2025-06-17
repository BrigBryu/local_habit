import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/stack_service.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/flexible_theme_system.dart';
import 'stack_info_screen.dart';

/// Stack habit tile that shows only the current step in sequence like a basic habit
class StackHabitTile extends ConsumerWidget {
  final Habit habit;
  final List<Habit> allHabits;

  const StackHabitTile(
      {super.key, required this.habit, required this.allHabits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stackService = StackService();
    final progress = stackService.getStackProgress(habit, allHabits);
    final isCompleted = stackService.isStackCompleted(habit, allHabits);
    final steps = stackService.getStackSteps(habit, allHabits);
    final progressPercentage =
        stackService.getStackProgressPercentage(habit, allHabits);
    final colors = ref.watchColors;
    
    // Get the current step to display
    final currentStep = stackService.getNextIncompleteStep(habit, allHabits);
    final currentStepIndex = currentStep != null ? steps.indexOf(currentStep) : -1;
    
    // If completed, show the stack name, otherwise show current step
    final displayHabit = isCompleted ? habit : (currentStep ?? habit);
    final canComplete = currentStep != null && !_isHabitCompletedToday(currentStep);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            isCompleted
                ? colors.completedBackground.withOpacity(0.8)
                : colors.stackHabit.withOpacity(0.15),
            isCompleted
                ? colors.completedBackground.withOpacity(0.4)
                : colors.stackHabit.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isCompleted
              ? colors.completedBorder.withOpacity(0.8)
              : colors.stackHabit.withOpacity(0.4),
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
          onTap: () => _navigateToStackInfo(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isCompleted
                      ? colors.draculaGreen.withOpacity(0.15)
                      : colors.stackHabit.withOpacity(0.1),
                  isCompleted
                      ? colors.draculaGreen.withOpacity(0.08)
                      : colors.stackHabit.withOpacity(0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                // Progress Ring showing sequence progress
                _buildProgressRing(
                    progress, isCompleted, progressPercentage, context, ref),
                const SizedBox(width: 16),
                // Current Step Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stack name with indicator
                      Text(
                        '${habit.name} 📚',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.stackHabit.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Current step info
                      if (!isCompleted && currentStep != null) ...[
                        Text(
                          'Current: ${currentStep.name}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.stackHabit,
                          ),
                        ),
                        if (currentStep.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            currentStep.description,
                            style: TextStyle(
                              color: colors.draculaCyan,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ] else if (isCompleted) ...[
                        Text(
                          'Stack Complete! 🎉',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.lineThrough,
                            color: colors.draculaGreen,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'No steps available',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: colors.draculaComment,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Complete button for current step
                if (canComplete)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.stackHabit,
                          colors.stackHabit.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colors.stackHabit.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _completeCurrentStep(context, ref, currentStep!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Complete', style: TextStyle(fontSize: 12)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRing(StackProgress progress, bool isCompleted,
      double progressPercentage, BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;

    return Tooltip(
      message: 'Stack progress: ${progress.completed}/${progress.total} steps completed',
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progressPercentage,
              backgroundColor: colors.draculaComment.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(
                isCompleted ? colors.draculaGreen : colors.stackHabit,
              ),
              strokeWidth: 5,
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${progress.completed}/${progress.total}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color:
                        isCompleted ? colors.draculaGreen : colors.stackHabit,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeCurrentStep(BuildContext context, WidgetRef ref, Habit step) async {
    if (_isHabitCompletedToday(step)) return; // Already completed

    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result = await habitsNotifier.completeHabit(step.id);
    final colors = ref.watchColors;

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
          content:
              Text('✅ ${step.name} completed! +${step.calculateXPReward()} XP'),
          backgroundColor: colors.success,
        ),
      );
    }
  }

  void _navigateToStackInfo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StackInfoScreen(
          stack: habit,
          allHabits: allHabits,
        ),
      ),
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
}