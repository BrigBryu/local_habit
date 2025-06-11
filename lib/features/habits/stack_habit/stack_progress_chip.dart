import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/stack_service.dart';
import '../../../core/theme/flexible_theme_system.dart';

/// Compact progress chip for showing stack progress in the top-right of the home page
class StackProgressChip extends ConsumerStatefulWidget {
  final Habit stack;
  final List<Habit> allHabits;
  final VoidCallback? onTap;

  const StackProgressChip({
    super.key,
    required this.stack,
    required this.allHabits,
    this.onTap,
  });

  @override
  ConsumerState<StackProgressChip> createState() => _StackProgressChipState();
}

class _StackProgressChipState extends ConsumerState<StackProgressChip>
    with SingleTickerProviderStateMixin {
  final _stackService = StackService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(StackProgressChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate when progress changes
    final oldProgress = _stackService.getStackProgress(oldWidget.stack, oldWidget.allHabits);
    final newProgress = _stackService.getStackProgress(widget.stack, widget.allHabits);
    
    if (oldProgress.completed != newProgress.completed) {
      _animateProgressChange();
    }
  }

  void _animateProgressChange() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _stackService.getStackProgress(widget.stack, widget.allHabits);
    final isCompleted = _stackService.isStackCompleted(widget.stack, widget.allHabits);
    final colors = ref.watchColors;

    // Update color animation based on completion state
    _colorAnimation = ColorTween(
      begin: colors.stackHabit,
      end: isCompleted ? colors.success : colors.stackHabit,
    ).animate(_animationController);

    if (progress.total == 0) {
      return _buildEmptyChip(colors);
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCompleted
                      ? [
                          colors.success.withOpacity(0.9),
                          colors.success.withOpacity(0.7),
                        ]
                      : [
                          colors.stackHabit.withOpacity(0.9),
                          colors.stackHabit.withOpacity(0.7),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted
                      ? colors.success.withOpacity(0.6)
                      : colors.stackHabit.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isCompleted ? colors.success : colors.stackHabit).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isCompleted
                        ? Icon(
                            Icons.check_circle,
                            key: const ValueKey('completed'),
                            size: 16,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.layers,
                            key: const ValueKey('progress'),
                            size: 16,
                            color: Colors.white,
                          ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      isCompleted ? 'Done' : _getProgressText(progress),
                      key: ValueKey(isCompleted ? 'done' : progress.toString()),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyChip(FlexibleColors colors) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.draculaComment.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.draculaComment.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.layers_clear,
              size: 16,
              color: colors.draculaComment,
            ),
            const SizedBox(width: 6),
            Text(
              'Empty',
              style: TextStyle(
                color: colors.draculaComment,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProgressText(StackProgress progress) {
    final remaining = progress.total - progress.completed;
    if (remaining == 1) {
      return '1 step left';
    }
    return '$remaining steps left';
  }
}

/// Multi-stack progress chip for showing multiple stacks
class MultiStackProgressChip extends ConsumerWidget {
  final List<Habit> stacks;
  final List<Habit> allHabits;
  final VoidCallback? onTap;

  const MultiStackProgressChip({
    super.key,
    required this.stacks,
    required this.allHabits,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stackService = StackService();
    final colors = ref.watchColors;
    
    if (stacks.isEmpty) return const SizedBox.shrink();

    // Calculate total progress across all stacks
    int totalCompleted = 0;
    int totalSteps = 0;
    int completedStacks = 0;

    for (final stack in stacks) {
      final progress = stackService.getStackProgress(stack, allHabits);
      totalCompleted += progress.completed;
      totalSteps += progress.total;
      
      if (stackService.isStackCompleted(stack, allHabits)) {
        completedStacks++;
      }
    }

    final allStacksComplete = completedStacks == stacks.length && stacks.isNotEmpty;
    final remainingSteps = totalSteps - totalCompleted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: allStacksComplete
                ? [
                    colors.success.withOpacity(0.9),
                    colors.success.withOpacity(0.7),
                  ]
                : [
                    colors.stackHabit.withOpacity(0.9),
                    colors.stackHabit.withOpacity(0.7),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: allStacksComplete
                ? colors.success.withOpacity(0.6)
                : colors.stackHabit.withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (allStacksComplete ? colors.success : colors.stackHabit).withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: allStacksComplete
                  ? Icon(
                      Icons.military_tech,
                      key: const ValueKey('all_completed'),
                      size: 16,
                      color: Colors.white,
                    )
                  : Icon(
                      Icons.layers,
                      key: const ValueKey('progress'),
                      size: 16,
                      color: Colors.white,
                    ),
            ),
            const SizedBox(width: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                allStacksComplete 
                    ? 'All Done!' 
                    : remainingSteps == 1 
                        ? '1 step left'
                        : '$remainingSteps steps left',
                key: ValueKey(allStacksComplete ? 'all_done' : remainingSteps),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}