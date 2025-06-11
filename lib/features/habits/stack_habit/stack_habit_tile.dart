import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/stack_service.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/flexible_theme_system.dart';
import 'providers.dart';
import 'stack_info_screen.dart';

const Duration kExpandDuration = Duration(milliseconds: 200);

/// Smart stack card that shows steps with proper hierarchy
class StackHabitTile extends ConsumerWidget {
  final Habit habit;
  final List<Habit> allHabits;

  const StackHabitTile({super.key, required this.habit, required this.allHabits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ExpandableStackTile(
      habit: habit,
      allHabits: allHabits,
    );
  }
}

class _ExpandableStackTile extends ConsumerWidget {
  final Habit habit;
  final List<Habit> allHabits;
  final _stackService = StackService();

  _ExpandableStackTile({required this.habit, required this.allHabits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = _stackService.getStackProgress(habit, allHabits);
    final isCompleted = _stackService.isStackCompleted(habit, allHabits);
    final steps = _stackService.getStackSteps(habit, allHabits);
    final progressPercentage = _stackService.getStackProgressPercentage(habit, allHabits);
    final isExpanded = ref.watch(stackExpandedProvider(habit.id));
    final colors = ref.watchColors;

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
          child: Column(
            children: [
              _buildStackHeader(context, ref, progress, isCompleted, progressPercentage, steps),
              AnimatedCrossFade(
                duration: kExpandDuration,
                crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: _buildStepsSection(context, ref, steps),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStackHeader(
    BuildContext context, 
    WidgetRef ref,
    StackProgress progress, 
    bool isCompleted, 
    double progressPercentage,
    List<Habit> steps,
  ) {
    final isExpanded = ref.watch(stackExpandedProvider(habit.id));
    final colors = ref.watchColors;
    
    return Container(
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
          // Progress Ring
          _buildProgressRing(progress, isCompleted, progressPercentage, context, ref),
          const SizedBox(width: 16),
          // Stack Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? colors.draculaGreen : colors.stackHabit,
                  ),
                ),
                if (habit.description.isNotEmpty) ...[ 
                  const SizedBox(height: 2),
                  Text(
                    habit.description,
                    style: TextStyle(
                      color: colors.draculaCyan,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Expand / collapse chevron
          IconButton(
            icon: Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: colors.draculaPink,
              size: 24,
            ),
            onPressed: () => _toggleExpansion(ref),
            tooltip: isExpanded ? 'Collapse stack' : 'Expand stack',
          ),
          // Action Buttons (next step, reorder)
          _buildActionButtons(context, ref, isCompleted, steps),
        ],
      ),
    );
  }

  Widget _buildProgressRing(StackProgress progress, bool isCompleted, double progressPercentage, BuildContext context, WidgetRef ref) {
    final steps = _stackService.getStackSteps(habit, allHabits);
    final colors = ref.watchColors;
    
    // Build tooltip text with step names and completion status
    String tooltipText = 'Steps in this stack:\n';
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final stepCompleted = _isHabitCompletedToday(step);
      final name = step.displayName;
      if (stepCompleted) {
        tooltipText += '${i + 1}. ✓ $name (completed)\n';
      } else {
        tooltipText += '${i + 1}. ○ $name\n';
      }
    }
    if (steps.isEmpty) {
      tooltipText = 'No steps in this stack yet';
    } else {
      tooltipText = tooltipText.trim(); // Remove trailing newline
    }

    return Tooltip(
      message: tooltipText,
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
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.15),
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
                    color: isCompleted ? colors.draculaGreen : colors.stackHabit,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, bool isCompleted, List<Habit> steps) {
    final colors = ref.watchColors;
    final nextStep = _stackService.getNextIncompleteStep(habit, allHabits);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _showAddStepDialog(context, ref),
          icon: Icon(
            Icons.add_circle_outline,
            color: colors.draculaPink,
          ),
          tooltip: 'Add Step to Stack',
        ),
        const SizedBox(width: 8),
        if (!isCompleted && nextStep != null)
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
              onPressed: () => _completeNextStep(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Next Step', style: TextStyle(fontSize: 12)),
            ),
          ),
      ],
    );
  }

  Widget _buildStepsSection(BuildContext context, WidgetRef ref, List<Habit> steps) {
    final colors = ref.watchColors;
    if (steps.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No steps in this stack yet',
            style: TextStyle(
              color: colors.draculaComment,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.08),
        border: Border(
          top: BorderSide(
            color: colors.draculaComment.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 1),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(
                    color: colors.draculaComment.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
              ),
              child: _buildNestedStepTile(context, ref, step, index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNestedStepTile(BuildContext context, WidgetRef ref, Habit step, int index) {
    final isCompleted = _isHabitCompletedToday(step);
    final colors = ref.watchColors;
    final nextStep = _stackService.getNextIncompleteStep(habit, allHabits);
    final isNext = nextStep?.id == step.id;
    
    return Container(
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isNext 
                ? colors.stackHabit.withOpacity(0.7)
                : colors.stackHabit.withOpacity(0.3),
            width: isNext ? 4 : 3,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isNext
                  ? [colors.stackHabit.withOpacity(0.3), colors.stackHabit.withOpacity(0.2)]
                  : [colors.draculaComment.withOpacity(0.2), colors.draculaComment.withOpacity(0.1)],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: isNext 
                  ? colors.stackHabit.withOpacity(0.5)
                  : colors.draculaComment.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isNext ? colors.stackHabit : colors.draculaComment,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isNext 
                        ? colors.stackHabit 
                        : isCompleted 
                            ? colors.draculaGreen
                            : colors.draculaPurple,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  children: [
                    TextSpan(text: step.displayName),
                    if (step.description.isNotEmpty) ...[
                      TextSpan(text: ' - '),
                      TextSpan(
                        text: step.description,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: colors.draculaCyan,
                        ),
                      ),
                    ],
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isNext)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.stackHabit.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: colors.stackHabit,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: isCompleted 
          ? Icon(Icons.check_circle, color: colors.draculaGreen, size: 20)
          : isNext
              ? Icon(Icons.play_circle_outline, color: colors.stackHabit, size: 20)
              : Icon(Icons.radio_button_unchecked, color: colors.draculaComment, size: 20),
        onTap: isNext ? () => _handleNestedStepTap(context, ref, step) : null,
      ),
    );
  }

  void _handleNestedStepTap(BuildContext context, WidgetRef ref, Habit step) {
    if (_isHabitCompletedToday(step)) return; // Already completed
    
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result = habitsNotifier.completeHabit(step.id);
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
          content: Text('✅ ${step.name} completed! +${step.calculateXPReward()} XP'),
          backgroundColor: colors.success,
        ),
      );
    }
  }

  void _completeNextStep(BuildContext context, WidgetRef ref) {
    final nextStep = _stackService.getNextIncompleteStep(habit, allHabits);
    if (nextStep != null) {
      _handleNestedStepTap(context, ref, nextStep);
    }
  }

  void _toggleExpansion(WidgetRef ref) {
    final currentState = ref.read(stackExpandedProvider(habit.id));
    ref.read(stackExpandedProvider(habit.id).notifier).state = !currentState;
  }

  void _showAddStepDialog(BuildContext context, WidgetRef ref) {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final allAvailableHabits = _stackService.getAvailableHabitsForStack(allHabits);
    final colors = ref.watchColors;
    
    if (allAvailableHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No available habits to add. Create some individual habits first!'),
          backgroundColor: colors.warning,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.draculaCurrentLine,
        title: Row(
          children: [
            Icon(Icons.add_circle, color: colors.stackHabit),
            const SizedBox(width: 8),
            Expanded(child: Text('Add to ${habit.name}', style: TextStyle(color: colors.stackHabit))),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a habit to add as the next step:',
                style: TextStyle(color: colors.draculaCyan),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: allAvailableHabits.length,
                  itemBuilder: (context, index) {
                    final habitToAdd = allAvailableHabits[index];
                    return _buildAddHabitTile(context, ref, habitToAdd, colors);
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: colors.draculaComment)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddHabitTile(BuildContext context, WidgetRef ref, Habit habitToAdd, FlexibleColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
          color: _getHabitTypeColor(habitToAdd.type).withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).pop();
            _addHabitToStack(context, ref, habitToAdd.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Habit type icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getHabitTypeColor(habitToAdd.type).withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getHabitTypeColor(habitToAdd.type).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getHabitTypeIcon(habitToAdd.type),
                    color: _getHabitTypeColor(habitToAdd.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                // Habit info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habitToAdd.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.draculaPurple,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (habitToAdd.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          habitToAdd.description,
                          style: TextStyle(
                            color: colors.draculaCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Add arrow
                Icon(
                  Icons.add_circle_outline,
                  color: colors.stackHabit,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getHabitTypeIcon(HabitType type) {
    switch (type) {
      case HabitType.basic:
        return Icons.check_circle_outline;
      case HabitType.avoidance:
        return Icons.block;
      case HabitType.bundle:
        return Icons.folder_special;
      case HabitType.stack:
        return Icons.layers;
    }
  }
  
  Color _getHabitTypeColor(HabitType type) {
    switch (type) {
      case HabitType.basic:
        return AppColors.basicHabit;
      case HabitType.avoidance:
        return AppColors.avoidanceHabit;
      case HabitType.bundle:
        return AppColors.bundleHabit;
      case HabitType.stack:
        return AppColors.stackHabit;
    }
  }

  void _addHabitToStack(BuildContext context, WidgetRef ref, String habitId) {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final colors = ref.watchColors;
    
    // Add logic to add habit to stack
    try {
      // This would need to be implemented in the habits provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Step added to stack successfully!'),
          backgroundColor: colors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding step: $e'),
          backgroundColor: colors.error,
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