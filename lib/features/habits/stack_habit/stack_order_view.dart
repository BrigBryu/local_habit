import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/stack_service.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/flexible_theme_system.dart';

/// Order management screen for habit stack steps with drag and drop reordering
class StackOrderView extends ConsumerStatefulWidget {
  final Habit stack;
  final List<Habit> allHabits;

  const StackOrderView({
    super.key,
    required this.stack,
    required this.allHabits,
  });

  @override
  ConsumerState<StackOrderView> createState() => _StackOrderViewState();
}

class _StackOrderViewState extends ConsumerState<StackOrderView> {
  final _stackService = StackService();
  late List<Habit> _steps;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _steps = _stackService.getStackSteps(widget.stack, widget.allHabits);
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watchColors;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Reorder Steps',
          style: TextStyle(color: colors.draculaPurple),
        ),
        backgroundColor: colors.draculaCurrentLine,
        foregroundColor: colors.draculaPurple,
        elevation: 0,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveOrder,
              child: Text(
                'Save',
                style: TextStyle(
                  color: colors.stackHabit,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Header with instructions
          _buildHeader(colors),
          // Stack steps list
          Expanded(
            child: _steps.isEmpty
                ? _buildEmptyState(colors)
                : _buildReorderableList(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(FlexibleColors colors) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.stackHabit.withOpacity(0.1),
            colors.stackHabit.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.stackHabit.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.layers,
                color: colors.stackHabit,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.stack.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.stackHabit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Drag steps to reorder them. Steps will be completed from top to bottom.',
            style: TextStyle(
              color: colors.draculaCyan,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPositionLabel('Top', 'First', colors),
              const Spacer(),
              _buildPositionLabel('Bottom', 'Last', colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPositionLabel(String position, String order, FlexibleColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.draculaComment.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.draculaComment.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            position == 'Top' ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: colors.draculaComment,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '$position = $order',
            style: TextStyle(
              color: colors.draculaComment,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderableList(FlexibleColors colors) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _steps.length,
      onReorder: _onReorder,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.05,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                shadowColor: colors.stackHabit.withOpacity(0.3),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final step = _steps[index];
        final isFirst = index == 0;
        final isLast = index == _steps.length - 1;
        
        return _buildStepTile(step, index, isFirst, isLast, colors);
      },
    );
  }

  Widget _buildStepTile(Habit step, int index, bool isFirst, bool isLast, FlexibleColors colors) {
    final isCompleted = _isHabitCompletedToday(step);
    
    return Container(
      key: ValueKey(step.id),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            isCompleted
                ? colors.completedBackground.withOpacity(0.6)
                : colors.draculaCurrentLine.withOpacity(0.6),
            isCompleted
                ? colors.completedBackground.withOpacity(0.3)
                : colors.draculaCurrentLine.withOpacity(0.3),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            // Position indicator
            Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isFirst
                      ? [colors.success, colors.success.withOpacity(0.7)]
                      : isLast
                          ? [colors.error, colors.error.withOpacity(0.7)]
                          : [colors.stackHabit, colors.stackHabit.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Step number
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.stackHabit.withOpacity(0.2),
                            colors.stackHabit.withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.stackHabit.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: colors.stackHabit,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Step info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCompleted 
                                  ? colors.draculaGreen 
                                  : colors.draculaPurple,
                              decoration: isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                            ),
                          ),
                          if (step.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              step.description,
                              style: TextStyle(
                                color: colors.draculaCyan,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Status and position indicators
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCompleted)
                          Icon(
                            Icons.check_circle,
                            color: colors.draculaGreen,
                            size: 20,
                          )
                        else
                          Icon(
                            Icons.radio_button_unchecked,
                            color: colors.draculaComment,
                            size: 20,
                          ),
                        const SizedBox(height: 8),
                        if (isFirst)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.success.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'First',
                              style: TextStyle(
                                color: colors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (isLast)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.error.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Last',
                              style: TextStyle(
                                color: colors.error,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Drag handle
            Container(
              width: 40,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.draculaComment.withOpacity(0.1),
                    colors.draculaComment.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  left: BorderSide(
                    color: colors.draculaComment.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Icon(
                Icons.drag_handle,
                color: colors.draculaComment,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(FlexibleColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.layers_clear,
            size: 64,
            color: colors.draculaComment,
          ),
          const SizedBox(height: 16),
          Text(
            'No Steps in Stack',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.draculaComment,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some habits to this stack to reorder them',
            style: TextStyle(
              fontSize: 16,
              color: colors.draculaComment.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _steps.removeAt(oldIndex);
      _steps.insert(newIndex, item);
      _hasChanges = true;
    });
  }

  void _saveOrder() {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final colors = ref.watchColors;
    
    try {
      // Use the stack service to reorder steps
      final reorderedSteps = _stackService.reorderStackSteps(_steps, 0, 0);
      
      // Update habits through the provider
      for (final step in reorderedSteps) {
        habitsNotifier.updateHabit(step);
      }
      
      setState(() {
        _hasChanges = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Stack order saved successfully!'),
          backgroundColor: colors.success,
        ),
      );
      
      Navigator.of(context).pop();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving order: $e'),
          backgroundColor: colors.error,
        ),
      );
    }
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