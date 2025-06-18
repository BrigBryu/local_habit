import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/flexible_theme_system.dart';
import '../../../core/services/stack_progress_service.dart';

class StackInfoScreen extends ConsumerStatefulWidget {
  final Habit stack;
  final List<Habit> allHabits;

  const StackInfoScreen({
    super.key,
    required this.stack,
    required this.allHabits,
  });

  @override
  ConsumerState<StackInfoScreen> createState() => _StackInfoScreenState();
}

class _StackInfoScreenState extends ConsumerState<StackInfoScreen> {
  final _stackService = StackProgressService();

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final currentStack =
        habitsAsync.value?.firstWhere((h) => h.id == widget.stack.id) ??
            widget.stack;
    final progress =
        _stackService.getStackProgress(currentStack, widget.allHabits);
    final isCompleted =
        _stackService.isStackComplete(currentStack, widget.allHabits);
    final children =
        _stackService.getStackChildren(currentStack, widget.allHabits);
    final currentChild =
        _stackService.getCurrentChild(currentStack, widget.allHabits);
    final colors = ref.watchColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.stack.name,
          style: TextStyle(color: colors.draculaForeground),
        ),
        backgroundColor: colors.draculaCurrentLine,
        iconTheme: IconThemeData(color: colors.draculaForeground),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: colors.draculaPink),
            onPressed: () => _showEditDialog(),
            tooltip: 'Edit Stack',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.draculaBackground,
              colors.draculaCurrentLine.withOpacity(0.5),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStackHeader(currentStack, progress, isCompleted, colors),
              const SizedBox(height: 24),
              _buildProgressSection(
                  progress, isCompleted, currentChild, colors),
              const SizedBox(height: 24),
              _buildChildrenSection(children, currentStack, colors),
              if (children.isEmpty) ...[
                const SizedBox(height: 24),
                _buildEmptyState(colors),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStackHeader(Habit stack, StackProgress progress,
      bool isCompleted, FlexibleColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            isCompleted
                ? colors.draculaGreen.withOpacity(0.15)
                : colors.stackHabit.withOpacity(0.1),
            isCompleted
                ? colors.draculaGreen.withOpacity(0.08)
                : colors.stackHabit.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isCompleted ? colors.draculaGreen : colors.stackHabit,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colors.stackHabit.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.stackHabit.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.layers,
                  color: colors.stackHabit,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stack.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isCompleted
                            ? colors.draculaGreen
                            : colors.draculaPurple,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (stack.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        stack.description,
                        style: TextStyle(
                          color: colors.draculaCyan,
                          fontSize: 16,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      _stackService.getStackStatus(stack, widget.allHabits),
                      style: TextStyle(
                        color: isCompleted
                            ? colors.draculaGreen
                            : colors.stackHabit,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(StackProgress progress, bool isCompleted,
      Habit? currentChild, FlexibleColors colors) {
    final progressPercent =
        progress.total > 0 ? progress.completed / progress.total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.draculaCurrentLine.withOpacity(0.3),
        border: Border.all(
          color: colors.draculaComment.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.draculaPurple,
                ),
              ),
              Text(
                '${progress.completed}/${progress.total}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.stackHabit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressPercent,
            backgroundColor: colors.draculaComment.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(
              isCompleted ? colors.draculaGreen : colors.stackHabit,
            ),
            minHeight: 8,
          ),
          if (currentChild != null && !isCompleted) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colors.stackHabit.withOpacity(0.1),
                border: Border.all(
                  color: colors.stackHabit.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: colors.stackHabit,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Current: ${currentChild.name}',
                      style: TextStyle(
                        color: colors.stackHabit,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _completeCurrentChild(currentChild),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.stackHabit,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Complete'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChildrenSection(
      List<Habit> children, Habit stack, FlexibleColors colors) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.draculaCurrentLine.withOpacity(0.3),
        border: Border.all(
          color: colors.draculaComment.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stack Steps',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.draculaPurple,
                  ),
                ),
                Text(
                  '${children.length} steps',
                  style: TextStyle(
                    color: colors.draculaComment,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ...children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;
            final isCompleted = isHabitCompletedToday(child);
            final isCurrent = index == stack.currentChildIndex;
            final isPastCurrent = index < stack.currentChildIndex;

            return Container(
              margin: const EdgeInsets.only(bottom: 1),
              decoration: BoxDecoration(
                color: isCurrent
                    ? colors.stackHabit.withOpacity(0.1)
                    : isPastCurrent
                        ? colors.draculaGreen.withOpacity(0.05)
                        : colors.draculaCurrentLine.withOpacity(0.05),
                border: Border(
                  left: BorderSide(
                    color: isCurrent
                        ? colors.stackHabit
                        : isPastCurrent
                            ? colors.draculaGreen
                            : colors.draculaComment.withOpacity(0.3),
                    width: 4,
                  ),
                  bottom: index < children.length - 1
                      ? BorderSide(
                          color: colors.draculaComment.withOpacity(0.1),
                          width: 0.5,
                        )
                      : BorderSide.none,
                ),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? colors.draculaGreen
                        : isCurrent
                            ? colors.stackHabit
                            : colors.draculaComment.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                title: Text(
                  child.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? colors.draculaGreen
                        : isCurrent
                            ? colors.stackHabit
                            : colors.draculaPurple,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: child.description.isNotEmpty
                    ? Text(
                        child.description,
                        style: TextStyle(
                          color: colors.draculaCyan,
                          fontSize: 12,
                        ),
                      )
                    : null,
                trailing: isCurrent && !isCompleted
                    ? IconButton(
                        onPressed: () => _completeCurrentChild(child),
                        icon: Icon(
                          Icons.play_circle_filled,
                          color: colors.stackHabit,
                          size: 28,
                        ),
                        tooltip: 'Complete this step',
                      )
                    : isCompleted
                        ? Icon(
                            Icons.check_circle,
                            color: colors.draculaGreen,
                            size: 24,
                          )
                        : Icon(
                            Icons.radio_button_unchecked,
                            color: colors.draculaComment,
                            size: 24,
                          ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(FlexibleColors colors) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.draculaCurrentLine.withOpacity(0.3),
        border: Border.all(
          color: colors.draculaComment.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.layers_clear,
            color: colors.draculaComment,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Empty Stack',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.draculaComment,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This stack has no steps yet. Add some habits to get started!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.draculaComment,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showEditDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Steps'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.stackHabit,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeCurrentChild(Habit child) async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result = await habitsNotifier.completeHabit(child.id);
    final colors = ref.read(flexibleColorsProvider);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Check if stack is now complete for bonus XP
      final isNowComplete =
          _stackService.isStackComplete(widget.stack, widget.allHabits);
      final xpText = isNowComplete
          ? '+${child.calculateXPReward()} XP + 1 XP Stack Bonus!'
          : '+${child.calculateXPReward()} XP';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${child.name} completed! $xpText'),
          backgroundColor: colors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showEditDialog() {
    final colors = ref.read(flexibleColorsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.draculaCurrentLine,
        title: Row(
          children: [
            Icon(Icons.edit, color: colors.draculaPink),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Edit Stack',
                style: TextStyle(color: colors.draculaPurple),
              ),
            ),
          ],
        ),
        content: Text(
          'Stack editing is not yet implemented. You can delete and recreate the stack if needed.',
          style: TextStyle(color: colors.draculaCyan),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: colors.draculaComment)),
          ),
        ],
      ),
    );
  }
}

/// Helper function to check if habit was completed today
bool isHabitCompletedToday(Habit habit) {
  if (habit.lastCompleted == null) return false;

  final now = DateTime.now();
  final lastCompleted = habit.lastCompleted!;
  return now.year == lastCompleted.year &&
      now.month == lastCompleted.month &&
      now.day == lastCompleted.day;
}
