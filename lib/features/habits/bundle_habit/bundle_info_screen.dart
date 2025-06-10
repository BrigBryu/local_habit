import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/bundle_service.dart' as bundle_service;
import '../../../providers/habits_provider.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/app_colors.dart';

class BundleInfoScreen extends ConsumerStatefulWidget {
  final Habit bundle;
  final List<Habit> allHabits;

  const BundleInfoScreen({
    super.key,
    required this.bundle,
    required this.allHabits,
  });

  @override
  ConsumerState<BundleInfoScreen> createState() => _BundleInfoScreenState();
}

class _BundleInfoScreenState extends ConsumerState<BundleInfoScreen> {
  bool _isReorderMode = false;
  late List<String> _currentChildIds;

  @override
  void initState() {
    super.initState();
    _currentChildIds = List<String>.from(widget.bundle.bundleChildIds ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final bundleService = bundle_service.BundleService();
    final currentBundle = ref.watch(habitsProvider).firstWhere((h) => h.id == widget.bundle.id);
    final progress = bundleService.getBundleProgress(currentBundle, widget.allHabits);
    final isCompleted = bundleService.isBundleCompleted(currentBundle, widget.allHabits);
    final children = bundleService.getChildHabits(currentBundle, widget.allHabits);
    final progressPercentage = bundleService.getBundleProgressPercentage(currentBundle, widget.allHabits);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bundle.name),
        backgroundColor: AppColors.draculaCurrentLine,
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _isReorderMode = !_isReorderMode),
            icon: Icon(
              _isReorderMode ? Icons.check : Icons.reorder,
              color: _isReorderMode ? AppColors.draculaGreen : AppColors.draculaPink,
            ),
            label: Text(
              _isReorderMode ? 'Done reordering' : 'Reorder',
              style: TextStyle(
                color: _isReorderMode ? AppColors.draculaGreen : AppColors.draculaPink,
              ),
            ),
          ),
          if (!isCompleted)
            TextButton.icon(
              onPressed: () => _completeBundle(context, ref),
              icon: Icon(Icons.done_all, color: AppColors.draculaGreen),
              label: Text('Complete All', style: TextStyle(color: AppColors.draculaGreen)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bundle Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.bundle.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.draculaPurple,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bundle Habit',
                                style: TextStyle(
                                  color: AppColors.draculaCyan,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Progress Ring
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: progressPercentage,
                                backgroundColor: AppColors.borderLight,
                                valueColor: AlwaysStoppedAnimation(
                                  isCompleted 
                                    ? AppColors.draculaGreen 
                                    : AppColors.draculaCyan,
                                ),
                                strokeWidth: 6,
                              ),
                              Text(
                                '${progress.completed}/${progress.total}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted 
                                    ? AppColors.draculaGreen 
                                    : AppColors.draculaCyan,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.bundle.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        widget.bundle.description,
                        style: TextStyle(fontSize: 16, color: AppColors.draculaCyan),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // Habits List
            Text(
              'Habits in this Bundle (${children.length})',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.draculaPurple,
              ),
            ),
            const SizedBox(height: 16),

            if (children.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No habits in this bundle yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.draculaComment,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add some habits to get started',
                          style: TextStyle(
                            color: AppColors.draculaComment,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddHabitDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Habit'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_isReorderMode)
              _buildReorderableHabitsList(context, ref, _getOrderedChildren(currentBundle, widget.allHabits))
            else
              ...children.map((habit) => _buildHabitCard(context, ref, habit)),
          ],
        ),
      ),
    );
  }

  List<Habit> _getOrderedChildren(Habit bundle, List<Habit> allHabits) {
    final childIds = bundle.bundleChildIds ?? [];
    final childHabits = <Habit>[];
    
    // Get habits in the order specified by bundleChildIds
    for (final id in childIds) {
      try {
        final habit = allHabits.firstWhere((h) => h.id == id);
        childHabits.add(habit);
      } catch (e) {
        // Skip if habit not found
      }
    }
    
    return childHabits;
  }

  Widget _buildReorderableHabitsList(BuildContext context, WidgetRef ref, List<Habit> children) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.draculaPink.withOpacity(0.3),
          width: 2,
        ),
        gradient: LinearGradient(
          colors: [
            AppColors.draculaCurrentLine.withOpacity(0.2),
            AppColors.draculaCurrentLine.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.drag_indicator, color: AppColors.draculaPink),
              const SizedBox(width: 8),
              Text(
                'Drag to reorder habits:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.draculaPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            onReorder: (oldIndex, newIndex) => _onReorderHabits(oldIndex, newIndex, ref),
            itemBuilder: (context, index) {
              final habit = children[index];
              return Container(
                key: ValueKey(habit.id),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.draculaCurrentLine.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.draculaPink.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  leading: Icon(Icons.drag_handle, color: AppColors.draculaPink),
                  title: Text(
                    habit.displayName,
                    style: TextStyle(
                      color: AppColors.draculaPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: habit.description.isNotEmpty
                      ? Text(
                          habit.description,
                          style: TextStyle(color: AppColors.draculaCyan),
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _onReorderHabits(int oldIndex, int newIndex, WidgetRef ref) {
    if (newIndex > oldIndex) newIndex -= 1;
    
    // Get current bundle from provider to ensure we have latest state
    final currentBundle = ref.read(habitsProvider).firstWhere((h) => h.id == widget.bundle.id);
    final currentChildIds = List<String>.from(currentBundle.bundleChildIds ?? []);
    
    // Reorder the IDs
    final movedId = currentChildIds.removeAt(oldIndex);
    currentChildIds.insert(newIndex, movedId);
    
    // Update the bundle with new order
    final updatedBundle = Habit(
      id: currentBundle.id,
      name: currentBundle.name,
      description: currentBundle.description,
      type: currentBundle.type,
      stackedOnHabitId: currentBundle.stackedOnHabitId,
      bundleChildIds: currentChildIds,
      parentBundleId: currentBundle.parentBundleId,
      timeoutMinutes: currentBundle.timeoutMinutes,
      availableDays: currentBundle.availableDays,
      createdAt: currentBundle.createdAt,
      lastCompleted: currentBundle.lastCompleted,
      lastAlarmTriggered: currentBundle.lastAlarmTriggered,
      sessionStartTime: currentBundle.sessionStartTime,
      lastSessionStarted: currentBundle.lastSessionStarted,
      sessionCompletedToday: currentBundle.sessionCompletedToday,
      dailyCompletionCount: currentBundle.dailyCompletionCount,
      lastCompletionCountReset: currentBundle.lastCompletionCountReset,
      dailyFailureCount: currentBundle.dailyFailureCount,
      lastFailureCountReset: currentBundle.lastFailureCountReset,
      avoidanceSuccessToday: currentBundle.avoidanceSuccessToday,
      currentStreak: currentBundle.currentStreak,
    );
    
    ref.read(habitsProvider.notifier).updateHabit(updatedBundle);
  }

  Widget _buildHabitCard(BuildContext context, WidgetRef ref, Habit habit) {
    final isCompleted = _isHabitCompletedToday(habit);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted 
              ? Theme.of(context).completionColors.success.withOpacity(0.3)
              : AppColors.borderLight,
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCompleted 
                ? Theme.of(context).completionColors.success
                : AppColors.incompleteBackground,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted 
                  ? Theme.of(context).completionColors.success
                  : AppColors.borderMedium,
                width: 2,
              ),
            ),
            child: Icon(
              isCompleted ? Icons.check : _getHabitTypeIcon(habit.type),
              color: isCompleted 
                ? Colors.white 
                : AppColors.textSecondary,
              size: 24,
            ),
          ),
          title: Text(
            habit.displayName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted 
                ? AppColors.draculaComment 
                : AppColors.draculaPurple,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (habit.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  habit.description,
                  style: TextStyle(
                    color: AppColors.draculaCyan,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getHabitTypeColor(habit.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  habit.type.displayName,
                  style: TextStyle(
                    color: _getHabitTypeColor(habit.type),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          trailing: isCompleted 
            ? null 
            : habit.type != HabitType.avoidance 
              ? IconButton(
                  onPressed: () => _completeHabit(context, ref, habit),
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.draculaPink,
                  ),
                  tooltip: 'Complete ${habit.name}',
                )
              : null,
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
        return Icons.folder;
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

  bool _isHabitCompletedToday(Habit habit) {
    if (habit.lastCompleted == null) return false;
    final now = DateTime.now();
    final lastCompleted = habit.lastCompleted!;
    return now.year == lastCompleted.year &&
           now.month == lastCompleted.month &&
           now.day == lastCompleted.day;
  }

  void _completeHabit(BuildContext context, WidgetRef ref, Habit habit) {
    if (_isHabitCompletedToday(habit)) return;
    
    final habitsNotifier = ref.read(habitsProvider.notifier);
    final result = habitsNotifier.completeHabit(habit.id);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${habit.name} completed!')),
      );
    }
  }

  void _completeBundle(BuildContext context, WidgetRef ref) {
    final habitsNotifier = ref.read(habitsProvider.notifier);
    final result = habitsNotifier.completeBundle(widget.bundle.id);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Theme.of(context).completionColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final habitsNotifier = ref.read(habitsProvider.notifier);
    final availableHabits = habitsNotifier.getAvailableHabitsForBundle();
    
    if (availableHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No available habits to add. Create some individual habits first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.add_circle, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text('Add to ${widget.bundle.name}')),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: availableHabits.length,
            itemBuilder: (context, index) {
              final habit = availableHabits[index];
              return Card(
                child: ListTile(
                  leading: Icon(_getHabitTypeIcon(habit.type)),
                  title: Text(habit.displayName),
                  subtitle: Text(habit.description),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addHabitToBundle(context, ref, habit.id);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addHabitToBundle(BuildContext context, WidgetRef ref, String habitId) {
    final habitsNotifier = ref.read(habitsProvider.notifier);
    final result = habitsNotifier.addHabitToBundle(widget.bundle.id, habitId);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Theme.of(context).completionColors.success,
        ),
      );
    }
  }
}