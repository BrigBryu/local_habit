import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/bundle_service.dart' as bundle_service;
import '../../../providers/habits_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/flexible_theme_system.dart';

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

  @override
  Widget build(BuildContext context) {
    final bundleService = bundle_service.BundleService();
    final habitsAsync = ref.watch(habitsProvider);
    final currentBundle =
        habitsAsync.value?.firstWhere((h) => h.id == widget.bundle.id) ??
            widget.bundle;
    final progress =
        bundleService.getBundleProgress(currentBundle, widget.allHabits);
    final isCompleted =
        bundleService.isBundleCompleted(currentBundle, widget.allHabits);
    final children =
        bundleService.getChildHabits(currentBundle, widget.allHabits);
    final progressPercentage = bundleService.getBundleProgressPercentage(
        currentBundle, widget.allHabits);
    final colors = ref.watchColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bundle.name,
          style: TextStyle(color: colors.draculaForeground),
        ),
        backgroundColor: colors.draculaCurrentLine,
        iconTheme: IconThemeData(color: colors.draculaForeground),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _isReorderMode = !_isReorderMode),
            icon: Icon(
              _isReorderMode ? Icons.check : Icons.reorder,
              color: _isReorderMode ? colors.draculaGreen : colors.draculaPink,
            ),
            label: Text(
              _isReorderMode ? 'Done reordering' : 'Reorder',
              style: TextStyle(
                color:
                    _isReorderMode ? colors.draculaGreen : colors.draculaPink,
              ),
            ),
          ),
          if (!isCompleted)
            TextButton.icon(
              onPressed: () => _completeBundle(context, ref),
              icon: Icon(Icons.done_all, color: colors.draculaGreen),
              label: Text('Complete All',
                  style: TextStyle(color: colors.draculaGreen)),
            ),
        ],
      ),
      backgroundColor: colors.draculaBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bundle Header Card
            Container(
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
                  color: colors.draculaPurple.withOpacity(0.3),
                  width: 2,
                ),
              ),
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
                                  color: colors.draculaPurple,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bundle Habit',
                                style: TextStyle(
                                  color: colors.draculaCyan,
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
                                backgroundColor:
                                    colors.draculaComment.withOpacity(0.3),
                                valueColor: AlwaysStoppedAnimation(
                                  isCompleted
                                      ? colors.draculaGreen
                                      : colors.draculaCyan,
                                ),
                                strokeWidth: 6,
                              ),
                              Text(
                                '${progress.completed}/${progress.total}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted
                                      ? colors.draculaGreen
                                      : colors.draculaCyan,
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
                        style:
                            TextStyle(fontSize: 16, color: colors.draculaCyan),
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
                color: colors.draculaPurple,
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
                          color: colors.draculaComment,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No habits in this bundle yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: colors.draculaComment,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add some habits to get started',
                          style: TextStyle(
                            color: colors.draculaComment,
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
              _buildReorderableHabitsList(context, ref,
                  _getOrderedChildren(currentBundle, widget.allHabits))
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

  Widget _buildReorderableHabitsList(
      BuildContext context, WidgetRef ref, List<Habit> children) {
    final colors = ref.watchColors;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.draculaPink.withOpacity(0.3),
          width: 2,
        ),
        gradient: LinearGradient(
          colors: [
            colors.draculaCurrentLine.withOpacity(0.2),
            colors.draculaCurrentLine.withOpacity(0.1),
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
              Icon(Icons.drag_indicator, color: colors.draculaPink),
              const SizedBox(width: 8),
              Text(
                'Drag to reorder habits:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.draculaPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            onReorder: (oldIndex, newIndex) =>
                _onReorderHabits(oldIndex, newIndex, ref),
            itemBuilder: (context, index) {
              final habit = children[index];
              return Container(
                key: ValueKey(habit.id),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: colors.draculaCurrentLine.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors.draculaPink.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  leading: Icon(Icons.drag_handle, color: colors.draculaPink),
                  title: Text(
                    habit.displayName,
                    style: TextStyle(
                      color: colors.draculaPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: habit.description.isNotEmpty
                      ? Text(
                          habit.description,
                          style: TextStyle(color: colors.draculaCyan),
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
    final habitsAsync = ref.read(habitsProvider);
    final currentBundle =
        habitsAsync.value?.firstWhere((h) => h.id == widget.bundle.id) ??
            widget.bundle;
    final currentChildIds =
        List<String>.from(currentBundle.bundleChildIds ?? []);

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

    ref.read(habitsNotifierProvider.notifier).updateHabit(updatedBundle);
  }

  Widget _buildHabitCard(BuildContext context, WidgetRef ref, Habit habit) {
    final isCompleted = _isHabitCompletedToday(habit);
    final colors = ref.watchColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              : colors.draculaCyan.withOpacity(0.4),
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
          onTap: habit.type != HabitType.avoidance && !isCompleted
              ? () => _completeHabit(context, ref, habit)
              : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Habit type icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getHabitTypeColor(habit.type).withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getHabitTypeColor(habit.type).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getHabitTypeIcon(habit.type),
                    color: _getHabitTypeColor(habit.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Habit info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted
                              ? colors.draculaGreen
                              : colors.draculaPurple,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (habit.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          habit.description,
                          style: TextStyle(
                            color: isCompleted
                                ? colors.draculaGreen.withOpacity(0.8)
                                : colors.draculaCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getThemeAwareHabitTypeColor(habit.type)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          habit.type.displayName,
                          style: TextStyle(
                            color: _getThemeAwareHabitTypeColor(habit.type),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Completion indicator - subtle and consistent
                if (isCompleted)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.draculaGreen,
                      boxShadow: [
                        BoxShadow(
                          color: colors.draculaGreen.withOpacity(0.3),
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
                  )
                else if (habit.type != HabitType.avoidance)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.draculaCurrentLine.withOpacity(0.15),
                      border: Border.all(
                        color: colors.draculaPink,
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
                      Icons.circle_outlined,
                      color: colors.draculaPink,
                      size: 24,
                    ),
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
        return Icons.folder;
      case HabitType.stack:
        return Icons.layers;
      case HabitType.interval:
        return Icons.schedule;
      case HabitType.weekly:
        return Icons.date_range;
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
      case HabitType.interval:
        return AppColors.basicHabit;
      case HabitType.weekly:
        return AppColors.basicHabit;
    }
  }

  Color _getThemeAwareHabitTypeColor(HabitType type) {
    final colors = ref.watchColors;
    switch (type) {
      case HabitType.basic:
        return colors.basicHabit; // Uses theme-aware cyan (dark in light mode)
      case HabitType.avoidance:
        return colors.avoidanceHabit; // Uses theme-aware red
      case HabitType.bundle:
        return colors.bundleHabit; // Uses theme-aware purple
      case HabitType.stack:
        return colors.stackHabit; // Uses theme-aware orange
      case HabitType.interval:
        return colors.basicHabit; // Use same as basic for now
      case HabitType.weekly:
        return colors.basicHabit; // Use same as basic for now
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

  Future<void> _completeHabit(
      BuildContext context, WidgetRef ref, Habit habit) async {
    if (_isHabitCompletedToday(habit)) return;

    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result = await habitsNotifier.completeHabit(habit.id);

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

  Future<void> _completeBundle(BuildContext context, WidgetRef ref) async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result = await habitsNotifier.completeBundle(widget.bundle.id);
    final colors = ref.watchColors;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: colors.draculaGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final availableHabits = habitsNotifier.getAvailableHabitsForBundle();

    if (availableHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No available habits to add. Create some individual habits first!'),
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

  Future<void> _addHabitToBundle(
      BuildContext context, WidgetRef ref, String habitId) async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result =
        await habitsNotifier.addHabitToBundle(widget.bundle.id, habitId);
    final colors = ref.watchColors;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: colors.draculaGreen,
        ),
      );
    }
  }
}
