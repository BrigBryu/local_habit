import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/stack_service.dart';
import '../../../core/theme/flexible_theme_system.dart';
import 'stack_order_view.dart';

/// Detailed information screen for habit stacks
class StackInfoScreen extends ConsumerWidget {
  final Habit stack;
  final List<Habit> allHabits;

  const StackInfoScreen({
    super.key,
    required this.stack,
    required this.allHabits,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stackService = StackService();
    final colors = ref.watchColors;
    final progress = stackService.getStackProgress(stack, allHabits);
    final steps = stackService.getStackSteps(stack, allHabits);
    final isCompleted = stackService.isStackCompleted(stack, allHabits);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          stack.name,
          style: TextStyle(color: colors.stackHabit),
        ),
        backgroundColor: colors.draculaCurrentLine,
        foregroundColor: colors.stackHabit,
        elevation: 0,
        actions: [
          if (steps.isNotEmpty)
            IconButton(
              onPressed: () => _navigateToOrderView(context),
              icon: Icon(Icons.reorder, color: colors.stackHabit),
              tooltip: 'Reorder Steps',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStackOverview(colors, progress, isCompleted),
            const SizedBox(height: 24),
            _buildStepsSection(context, ref, steps, colors, stackService),
          ],
        ),
      ),
    );
  }

  Widget _buildStackOverview(FlexibleColors colors, StackProgress progress, bool isCompleted) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.stackHabit.withOpacity(0.15),
            colors.stackHabit.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.stackHabit.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isCompleted ? Icons.military_tech : Icons.layers,
            size: 48,
            color: isCompleted ? colors.success : colors.stackHabit,
          ),
          const SizedBox(height: 12),
          Text(
            stack.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.stackHabit,
            ),
            textAlign: TextAlign.center,
          ),
          if (stack.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              stack.description,
              style: TextStyle(
                fontSize: 16,
                color: colors.draculaCyan,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                'Steps',
                '${progress.total}',
                Icons.format_list_numbered,
                colors.draculaPurple,
                colors,
              ),
              _buildStatCard(
                'Completed',
                '${progress.completed}',
                Icons.check_circle,
                colors.success,
                colors,
              ),
              _buildStatCard(
                'Remaining',
                '${progress.total - progress.completed}',
                Icons.pending_actions,
                colors.warning,
                colors,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: colors.draculaComment.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.total > 0 ? progress.completed / progress.total : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.stackHabit, colors.stackHabit.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCompleted 
                ? 'Stack Complete! 🎉'
                : '${((progress.completed / (progress.total > 0 ? progress.total : 1)) * 100).round()}% Complete',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isCompleted ? colors.success : colors.stackHabit,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, FlexibleColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colors.draculaComment,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection(BuildContext context, WidgetRef ref, List<Habit> steps, FlexibleColors colors, StackService stackService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.format_list_numbered, color: colors.stackHabit, size: 20),
            const SizedBox(width: 8),
            Text(
              'Steps (${steps.length})',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.stackHabit,
              ),
            ),
            const Spacer(),
            if (steps.isNotEmpty)
              TextButton.icon(
                onPressed: () => _navigateToOrderView(context),
                icon: Icon(Icons.reorder, size: 16, color: colors.draculaPink),
                label: Text(
                  'Reorder',
                  style: TextStyle(color: colors.draculaPink),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (steps.isEmpty)
          _buildEmptySteps(colors)
        else
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return _buildStepCard(step, index, colors, stackService);
          }),
      ],
    );
  }

  Widget _buildEmptySteps(FlexibleColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.draculaComment.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.draculaComment.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.layers_clear,
            size: 48,
            color: colors.draculaComment,
          ),
          const SizedBox(height: 12),
          Text(
            'No Steps Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.draculaComment,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add some habits to create your stack',
            style: TextStyle(
              fontSize: 14,
              color: colors.draculaComment.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(Habit step, int index, FlexibleColors colors, StackService stackService) {
    final isCompleted = _isHabitCompletedToday(step);
    final nextStep = stackService.getNextIncompleteStep(stack, allHabits);
    final isNext = nextStep?.id == step.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNext
              ? [colors.stackHabit.withOpacity(0.2), colors.stackHabit.withOpacity(0.1)]
              : isCompleted
                  ? [colors.success.withOpacity(0.2), colors.success.withOpacity(0.1)]
                  : [colors.draculaComment.withOpacity(0.1), colors.draculaComment.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNext
              ? colors.stackHabit.withOpacity(0.4)
              : isCompleted
                  ? colors.success.withOpacity(0.4)
                  : colors.draculaComment.withOpacity(0.3),
          width: isNext ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Step number
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isNext
                      ? [colors.stackHabit.withOpacity(0.3), colors.stackHabit.withOpacity(0.2)]
                      : isCompleted
                          ? [colors.success.withOpacity(0.3), colors.success.withOpacity(0.2)]
                          : [colors.draculaComment.withOpacity(0.2), colors.draculaComment.withOpacity(0.1)],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isNext
                      ? colors.stackHabit.withOpacity(0.5)
                      : isCompleted
                          ? colors.success.withOpacity(0.5)
                          : colors.draculaComment.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isNext
                        ? colors.stackHabit
                        : isCompleted
                            ? colors.success
                            : colors.draculaComment,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Step details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isNext
                                ? colors.stackHabit
                                : isCompleted
                                    ? colors.success
                                    : colors.draculaPurple,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      if (isNext)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.stackHabit.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Next',
                            style: TextStyle(
                              color: colors.stackHabit,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (step.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: TextStyle(
                        color: colors.draculaCyan,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Status icon
            Icon(
              isCompleted 
                  ? Icons.check_circle
                  : isNext 
                      ? Icons.play_circle_outline
                      : Icons.radio_button_unchecked,
              color: isCompleted 
                  ? colors.success
                  : isNext 
                      ? colors.stackHabit
                      : colors.draculaComment,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToOrderView(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StackOrderView(
          stack: stack,
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