import 'package:flutter/material.dart';
import 'package:domain/use_cases/complete_bundle_use_case.dart';
import 'package:data_local/repositories/habit_service.dart';

/// Card widget for displaying bundle/routine habits with progress
class RoutineCard extends StatefulWidget {
  final BundleHabitWithChildren bundleData;
  final HabitService habitService;
  final VoidCallback? onUpdated;

  const RoutineCard({
    super.key,
    required this.bundleData,
    required this.habitService,
    this.onUpdated,
  });

  @override
  State<RoutineCard> createState() => _RoutineCardState();
}

class _RoutineCardState extends State<RoutineCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isCompleting = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _completeBundle() async {
    if (_isCompleting) return;

    setState(() => _isCompleting = true);

    try {
      await widget.habitService.completeBundle(widget.bundleData.bundleHabit.id);
      widget.onUpdated?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.bundleData.bundleHabit.name} completed!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bundle = widget.bundleData.bundleHabit;
    final progress = widget.bundleData.progress;
    final isCompleted = isHabitCompletedToday(bundle);
    final canComplete = bundle.canCompleteBundle();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: Column(
        children: [
          // Main bundle row
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Progress circle
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background circle
                        CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 4,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation(Colors.grey[300]!),
                        ),
                        // Progress circle
                        CircularProgressIndicator(
                          value: progress.percentage,
                          strokeWidth: 4,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(
                            isCompleted
                                ? Colors.green
                                : progress.isComplete
                                    ? Colors.orange
                                    : Colors.blue,
                          ),
                        ),
                        // Center text
                        Text(
                          progress.toString(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? Colors.green
                                : progress.isComplete
                                    ? Colors.orange
                                    : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Bundle info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bundle.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted
                                ? Colors.grey[600]
                                : null,
                          ),
                        ),
                        if (bundle.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            bundle.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.folder,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${progress.completed}/${progress.total} habits',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            if (bundle.currentStreak > 0) ...[
                              Icon(
                                Icons.local_fire_department,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${bundle.currentStreak}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action button
                  if (canComplete && !isCompleted)
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: _isCompleting
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : IconButton(
                              onPressed: _completeBundle,
                              icon: Icon(
                                progress.isComplete
                                    ? Icons.check_circle
                                    : Icons.play_circle_fill,
                                color: progress.isComplete
                                    ? Colors.green
                                    : Colors.blue,
                                size: 28,
                              ),
                              tooltip: progress.isComplete
                                  ? 'Complete bundle'
                                  : 'Complete all habits',
                            ),
                    )
                  else if (isCompleted)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 28,
                    ),

                  // Expand/collapse arrow
                  IconButton(
                    onPressed: _toggleExpanded,
                    icon: AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.expand_more),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded child habits
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Column(
                children: [
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Habit Tasks',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(
                          widget.bundleData.childHabits.length,
                          (index) {
                            final childHabit = widget.bundleData.childHabits[index];
                            final isChildCompleted = isHabitCompletedToday(childHabit);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    isChildCompleted
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isChildCompleted
                                        ? Colors.green
                                        : Colors.grey[400],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      childHabit.name,
                                      style: TextStyle(
                                        decoration: isChildCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: isChildCompleted
                                            ? Colors.grey[600]
                                            : null,
                                      ),
                                    ),
                                  ),
                                  if (childHabit.currentStreak > 0) ...[
                                    Icon(
                                      Icons.local_fire_department,
                                      size: 14,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${childHabit.currentStreak}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}