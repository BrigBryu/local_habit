import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../core/theme/flexible_theme_system.dart';

class PartnerStackHabitTile extends ConsumerWidget {
  final Habit habit;
  final List<Habit> allHabits;

  const PartnerStackHabitTile({
    super.key,
    required this.habit,
    required this.allHabits,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stackSteps =
        allHabits.where((h) => h.stackedOnHabitId == habit.id).toList();

    final completedCount =
        stackSteps.where((h) => _isHabitCompletedToday(h)).length;
    final totalCount = stackSteps.length;
    final isCompleted = completedCount == totalCount && totalCount > 0;
    final progressPercentage = totalCount > 0 ? completedCount / totalCount : 0.0;
    final colors = ref.watchColors;
    
    // Get the current step to display (same logic as user's stack)
    final currentStepIndex = completedCount;
    final currentStep = currentStepIndex < stackSteps.length ? stackSteps[currentStepIndex] : null;
    
    // If completed, show the stack name, otherwise show current step
    final displayHabit = isCompleted ? habit : (currentStep ?? habit);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            isCompleted
                ? colors.completedBackground.withOpacity(0.6)
                : colors.stackHabit.withOpacity(0.15),
            isCompleted
                ? colors.completedBackground.withOpacity(0.3)
                : colors.stackHabit.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isCompleted
              ? colors.completedBorder.withOpacity(0.6)
              : colors.stackHabit.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isCompleted
                    ? colors.draculaGreen.withOpacity(0.12)
                    : colors.stackHabit.withOpacity(0.08),
                isCompleted
                    ? colors.draculaGreen.withOpacity(0.06)
                    : colors.stackHabit.withOpacity(0.04),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              // Progress Ring showing sequence progress
              _buildProgressRing(completedCount, totalCount, isCompleted, progressPercentage, context, ref),
              const SizedBox(width: 16),
              // Current Step Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Partner indicator
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 12,
                          color: colors.draculaComment.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Partner\'s Stack',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.draculaComment.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Show step indicator if not completed
                    if (!isCompleted && currentStepIndex < totalCount) ...[
                      Text(
                        'Step ${currentStepIndex + 1} of $totalCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.stackHabit.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      isCompleted ? '${habit.name} (Complete)' : (displayHabit.name),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? colors.draculaGreen.withOpacity(0.9)
                            : colors.stackHabit.withOpacity(0.9),
                      ),
                    ),
                    if (displayHabit.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        displayHabit.description,
                        style: TextStyle(
                          color: colors.draculaCyan.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // No complete button - this is read-only for partner habits
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRing(
      int completedCount,
      int totalCount,
      bool isCompleted,
      double progressPercentage,
      BuildContext context,
      WidgetRef ref) {
    final colors = ref.watchColors;

    return Tooltip(
      message: 'Partner stack progress: $completedCount/$totalCount steps completed',
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progressPercentage,
              backgroundColor: colors.draculaComment.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(
                isCompleted ? colors.draculaGreen.withOpacity(0.8) : colors.stackHabit.withOpacity(0.8),
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
                  '$completedCount/$totalCount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? colors.draculaGreen.withOpacity(0.9) : colors.stackHabit.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ],
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