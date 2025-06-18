import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../core/theme/flexible_theme_system.dart';
import '../../../core/services/stack_progress_service.dart';

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
    final stackService = StackProgressService();
    final progress = stackService.getStackProgress(habit, allHabits);
    final isCompleted = stackService.isStackComplete(habit, allHabits);
    final currentChild = stackService.getCurrentChild(habit, allHabits);
    final children = stackService.getStackChildren(habit, allHabits);
    final progressPercentage =
        progress.total > 0 ? progress.completed / progress.total : 0.0;
    final colors = ref.watchColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            isCompleted
                ? colors.completedBackground.withOpacity(0.6)
                : colors.draculaCurrentLine.withOpacity(0.4),
            isCompleted
                ? colors.completedBackground.withOpacity(0.3)
                : colors.draculaCurrentLine.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isCompleted
              ? colors.completedBorder.withOpacity(0.6)
              : colors.stackHabit.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _showStackDetails(context, ref),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Partner indicator + progress visualization
                _buildPartnerProgressIndicator(
                    context, ref, progress, progressPercentage, isCompleted),
                const SizedBox(width: 16),
                // Stack info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: colors.draculaComment,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              habit.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isCompleted
                                    ? colors.completedTextOnGreen
                                    : colors.draculaPurple,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _buildPartnerSubtitleText(
                            progress, currentChild, isCompleted),
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
                      // Show mini step indicator for partner
                      if (children.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildPartnerMiniStepIndicator(
                            context, ref, children, progress),
                      ],
                    ],
                  ),
                ),
                // Partner status indicator
                _buildPartnerStatusIndicator(context, ref, isCompleted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerProgressIndicator(
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
        color: colors.stackHabit.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.stackHabit.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress ring - slightly dimmed for partner view
          CircularProgressIndicator(
            value: progressPercentage,
            backgroundColor: colors.draculaComment.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(
              isCompleted
                  ? colors.draculaGreen.withOpacity(0.7)
                  : colors.stackHabit.withOpacity(0.7),
            ),
            strokeWidth: 3,
          ),
          // Layers icon with progress text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.layers,
                color: colors.stackHabit.withOpacity(0.8),
                size: 16,
              ),
              Text(
                '${progress.completed}/${progress.total}',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? colors.draculaGreen.withOpacity(0.8)
                      : colors.stackHabit.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerMiniStepIndicator(
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
          final isCurrent = index == progress.currentIndex && !isCompleted;

          return Container(
            margin: const EdgeInsets.only(right: 4),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isCompleted
                    ? colors.draculaGreen.withOpacity(0.8)
                    : isCurrent
                        ? colors.stackHabit.withOpacity(0.8)
                        : colors.draculaComment.withOpacity(0.2),
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(
                        color: colors.stackHabit.withOpacity(0.8), width: 1)
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
              color: colors.draculaComment.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  String _buildPartnerSubtitleText(
      StackProgress progress, Habit? currentChild, bool isCompleted) {
    if (isCompleted) {
      return 'Partner\'s Stack Complete! ✅';
    }

    if (progress.total == 0) {
      return 'Partner\'s empty stack';
    }

    if (currentChild != null) {
      return 'Partner working on: ${currentChild.name}';
    }

    return 'Partner\'s Stack · ${progress.completed}/${progress.total} steps';
  }

  Widget _buildPartnerStatusIndicator(
      BuildContext context, WidgetRef ref, bool isCompleted) {
    final colors = ref.watchColors;

    if (isCompleted) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.completed.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: colors.completed.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 20,
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.draculaComment.withOpacity(0.1),
        border: Border.all(
          color: colors.draculaComment.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.visibility,
        color: colors.draculaComment.withOpacity(0.8),
        size: 16,
      ),
    );
  }

  void _showStackDetails(BuildContext context, WidgetRef ref) {
    final colors = ref.read(flexibleColorsProvider);
    final stackService = StackProgressService();
    final children = stackService.getStackChildren(habit, allHabits);
    final progress = stackService.getStackProgress(habit, allHabits);
    final currentChild = stackService.getCurrentChild(habit, allHabits);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.draculaCurrentLine,
        title: Row(
          children: [
            Icon(Icons.person, color: colors.draculaComment),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Partner\'s ${habit.name}',
                style: TextStyle(color: colors.draculaPurple),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colors.stackHabit.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.layers,
                      color: colors.stackHabit,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stackService.getStackStatus(habit, allHabits),
                        style: TextStyle(
                          color: colors.stackHabit,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${progress.completed}/${progress.total}',
                      style: TextStyle(
                        color: colors.stackHabit,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (children.isNotEmpty) ...[
                Text(
                  'Stack Steps:',
                  style: TextStyle(
                    color: colors.draculaCyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      final child = children[index];
                      final isCompleted = isHabitCompletedToday(child);
                      final isCurrent = index == progress.currentIndex;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: isCurrent
                              ? colors.stackHabit.withOpacity(0.1)
                              : Colors.transparent,
                          border: isCurrent
                              ? Border.all(
                                  color: colors.stackHabit.withOpacity(0.3),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? colors.draculaGreen
                                    : isCurrent
                                        ? colors.stackHabit
                                        : colors.draculaComment
                                            .withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: isCompleted
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 12,
                                      )
                                    : Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                child.name,
                                style: TextStyle(
                                  color: isCompleted
                                      ? colors.draculaGreen
                                      : isCurrent
                                          ? colors.stackHabit
                                          : colors.draculaPurple,
                                  fontWeight: FontWeight.w500,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                Center(
                  child: Text(
                    'No steps in this stack yet',
                    style: TextStyle(
                      color: colors.draculaComment,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: colors.draculaComment),
            ),
          ),
        ],
      ),
    );
  }
}

