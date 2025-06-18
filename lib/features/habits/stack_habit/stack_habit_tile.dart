import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/stack_service.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/flexible_theme_system.dart';
import 'stack_info_screen.dart';

class StackHabitTile extends ConsumerWidget {
  final Habit habit;
  final List<Habit> allHabits;

  const StackHabitTile({
    super.key,
    required this.habit,
    required this.allHabits,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stackService = StackService();
    final progress = stackService.getStackProgress(habit, allHabits);
    final isCompleted = stackService.isStackCompleted(habit, allHabits);
    final nextStep = stackService.getNextIncompleteStep(habit, allHabits);
    final steps = stackService.getStackSteps(habit, allHabits);
    final progressPercentage =
        stackService.getStackProgressPercentage(habit, allHabits);
    final colors = ref.watchColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            isCompleted
                ? colors.completedBackground.withOpacity(0.8)
                : colors.draculaCurrentLine.withOpacity(0.6),
            isCompleted
                ? colors.completedBackground.withOpacity(0.4)
                : colors.draculaCurrentLine.withOpacity(0.3),
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
            child: Row(
              children: [
                // Progress visualization with layers icon
                _buildProgressIndicator(
                    context, ref, progress, progressPercentage, isCompleted),
                const SizedBox(width: 16),
                // Stack info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted
                              ? colors.completedTextOnGreen
                              : colors.draculaPurple,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _buildSubtitleText(progress, nextStep, isCompleted),
                        style: TextStyle(
                          color: isCompleted
                              ? colors.completedTextOnGreen
                              : colors.stackHabit,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (habit.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          habit.description,
                          style: TextStyle(
                            color: colors.draculaComment,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Show mini step indicator
                      if (steps.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildMiniStepIndicator(context, ref, steps, progress),
                      ],
                    ],
                  ),
                ),
                // Next step button or completion checkmark
                _buildTrailingWidget(context, ref, nextStep, isCompleted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    WidgetRef ref,
    StackProgress progress,
    double progressPercentage,
    bool isCompleted,
  ) {
    final colors = ref.watchColors;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colors.stackHabit.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.stackHabit.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress ring
          CircularProgressIndicator(
            value: progressPercentage,
            backgroundColor: colors.draculaComment.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(
              isCompleted ? colors.draculaGreen : colors.stackHabit,
            ),
            strokeWidth: 3,
          ),
          // Layers icon with progress text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.layers,
                color: colors.stackHabit,
                size: 16,
              ),
              Text(
                '${progress.completed}/${progress.total}',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? colors.draculaGreen : colors.stackHabit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStepIndicator(
    BuildContext context,
    WidgetRef ref,
    List<Habit> steps,
    StackProgress progress,
  ) {
    final colors = ref.watchColors;
    final maxStepsToShow = 5;
    final stepsToShow = steps.take(maxStepsToShow).toList();

    return Row(
      children: [
        ...stepsToShow.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isCompleted = isHabitCompletedToday(step);
          final isCurrent = index == progress.completed && !isCompleted;

          return Container(
            margin: const EdgeInsets.only(right: 4),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isCompleted
                    ? colors.draculaGreen
                    : isCurrent
                        ? colors.stackHabit
                        : colors.draculaComment.withOpacity(0.3),
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: colors.stackHabit, width: 1)
                    : null,
              ),
            ),
          );
        }).toList(),
        if (steps.length > maxStepsToShow) ...[
          const SizedBox(width: 4),
          Text(
            '+${steps.length - maxStepsToShow}',
            style: TextStyle(
              fontSize: 10,
              color: colors.draculaComment,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  String _buildSubtitleText(
      StackProgress progress, Habit? nextStep, bool isCompleted) {
    if (isCompleted) {
      return 'Stack Complete! ✅ +1 XP Bonus';
    }

    if (progress.total == 0) {
      return 'Empty stack - add some habits';
    }

    if (nextStep != null) {
      return 'Next: ${nextStep.displayName}';
    }

    return 'Stack · ${progress.completed}/${progress.total} steps';
  }

  Widget _buildTrailingWidget(
    BuildContext context,
    WidgetRef ref,
    Habit? nextStep,
    bool isCompleted,
  ) {
    final colors = ref.watchColors;

    if (isCompleted) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.completed,
          boxShadow: [
            BoxShadow(
              color: colors.completed.withOpacity(0.3),
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

    if (nextStep == null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.draculaComment.withOpacity(0.15),
          border: Border.all(
            color: colors.draculaComment,
            width: 2,
          ),
        ),
        child: Icon(
          Icons.add,
          color: colors.draculaComment,
          size: 20,
        ),
      );
    }

    return GestureDetector(
      onTap: () => _completeNextStep(context, ref, nextStep),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.draculaCurrentLine.withOpacity(0.15),
          border: Border.all(
            color: colors.stackHabit,
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
          Icons.play_arrow,
          color: colors.stackHabit,
          size: 24,
        ),
      ),
    );
  }

  Future<void> _completeNextStep(
      BuildContext context, WidgetRef ref, Habit nextStep) async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result = await habitsNotifier.completeHabit(nextStep.id);
    final colors = ref.watchColors;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Check if stack is now complete for bonus XP
      final stackService = StackService();
      final isNowComplete = stackService.isStackCompleted(habit, allHabits);
      final xpText = isNowComplete
          ? '+${nextStep.calculateXPReward()} XP + 1 XP Stack Bonus!'
          : '+${nextStep.calculateXPReward()} XP';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${nextStep.name} completed! $xpText'),
          backgroundColor: colors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
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
}
