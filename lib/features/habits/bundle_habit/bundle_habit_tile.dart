import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/bundle_service.dart' as bundle_service;
import '../../../providers/habits_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import 'providers.dart';
import 'bundle_info_screen.dart';

const Duration kExpandDuration = Duration(milliseconds: 200);

/// Smart bundle card that shows nested children with proper hierarchy
class BundleHabitTile extends ConsumerWidget {
  final Habit habit;
  final List<Habit> allHabits;

  const BundleHabitTile(
      {super.key, required this.habit, required this.allHabits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ExpandableBundleTile(
      habit: habit,
      allHabits: allHabits,
    );
  }
}

class _ExpandableBundleTile extends ConsumerWidget {
  final Habit habit;
  final List<Habit> allHabits;
  final _bundleService = bundle_service.BundleService();

  _ExpandableBundleTile({required this.habit, required this.allHabits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = _bundleService.getBundleProgress(habit, allHabits);
    final isCompleted = _bundleService.isBundleCompleted(habit, allHabits);
    final children = _bundleService.getChildHabits(habit, allHabits);
    final progressPercentage =
        _bundleService.getBundleProgressPercentage(habit, allHabits);
    final isExpanded = ref.watch(bundleExpandedProvider(habit.id));
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
          onTap: () => _navigateToBundleInfo(context),
          child: Column(
            children: [
              _buildBundleHeader(context, ref, progress, isCompleted,
                  progressPercentage, children),
              AnimatedCrossFade(
                duration: kExpandDuration,
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: _buildChildrenSection(context, ref, children),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBundleHeader(
    BuildContext context,
    WidgetRef ref,
    bundle_service.BundleProgress progress,
    bool isCompleted,
    double progressPercentage,
    List<Habit> children,
  ) {
    final isExpanded = ref.watch(bundleExpandedProvider(habit.id));
    final colors = ref.watchColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isCompleted
                ? colors.draculaGreen.withOpacity(0.15)
                : colors.draculaPurple.withOpacity(0.1),
            isCompleted
                ? colors.draculaGreen.withOpacity(0.08)
                : colors.draculaPurple.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          // Progress Ring
          _buildProgressRing(
              progress, isCompleted, progressPercentage, context, ref),
          const SizedBox(width: 16),
          // Bundle Info
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
                    color: isCompleted
                        ? colors.draculaGreen
                        : colors.draculaPurple,
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
            tooltip: isExpanded ? 'Collapse bundle' : 'Expand bundle',
          ),
          // Action Buttons (complete all, add habit)
          _buildActionButtons(context, ref, isCompleted, children),
        ],
      ),
    );
  }

  Widget _buildProgressRing(
      bundle_service.BundleProgress progress,
      bool isCompleted,
      double progressPercentage,
      BuildContext context,
      WidgetRef ref) {
    final children = _bundleService.getChildHabits(habit, allHabits);
    final colors = ref.watchColors;

    // Build tooltip text with habit names and completion status
    String tooltipText = 'Habits in this bundle:\n';
    for (final child in children) {
      final childCompleted = _isHabitCompletedToday(child);
      final name = child.displayName;
      if (childCompleted) {
        tooltipText += '✓ $name (completed)\n';
      } else {
        tooltipText += '○ $name\n';
      }
    }
    if (children.isEmpty) {
      tooltipText = 'No habits in this bundle yet';
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
                isCompleted ? colors.draculaGreen : colors.draculaComment,
              ),
              strokeWidth: 5,
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.15),
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
                    color:
                        isCompleted ? colors.draculaGreen : colors.draculaCyan,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref,
      bool isCompleted, List<Habit> children) {
    final colors = ref.watchColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _showAddHabitDialog(context, ref),
          icon: Icon(
            Icons.add_circle_outline,
            color: colors.draculaPink,
          ),
          tooltip: 'Add Habit to Bundle',
        ),
        const SizedBox(width: 8),
        if (!isCompleted)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.draculaPink,
                  colors.draculaPink.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.draculaPink.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _completeBundle(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Complete All', style: TextStyle(fontSize: 12)),
            ),
          ),
      ],
    );
  }

  Widget _buildChildrenSection(
      BuildContext context, WidgetRef ref, List<Habit> children) {
    final colors = ref.watchColors;
    if (children.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No habits in this bundle yet',
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
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.08),
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
          ...children.map((child) => Container(
                margin: const EdgeInsets.only(bottom: 1),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.05),
                  border: Border(
                    bottom: BorderSide(
                      color: colors.draculaComment.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                ),
                child: _buildNestedHabitTile(context, ref, child),
              )),
        ],
      ),
    );
  }

  Widget _buildNestedHabitTile(
      BuildContext context, WidgetRef ref, Habit habit) {
    // Simplified nested habit tile for bundle context
    final isCompleted = _isHabitCompletedToday(habit);
    final colors = ref.watchColors;

    return Container(
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 3,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.draculaPurple,
                  ),
                  children: [
                    TextSpan(text: habit.displayName),
                    if (habit.description.isNotEmpty) ...[
                      TextSpan(text: ' - '),
                      TextSpan(
                        text: habit.description,
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
          ],
        ),
        trailing: isCompleted
            ? Icon(Icons.check_circle, color: colors.draculaGreen, size: 20)
            : Icon(Icons.check_box_outline_blank,
                color: colors.draculaComment, size: 20),
        onTap: habit.type == HabitType.avoidance
            ? null
            : () => _handleNestedHabitTap(context, ref, habit),
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

  Future<void> _handleNestedHabitTap(
      BuildContext context, WidgetRef ref, Habit habit) async {
    if (_isHabitCompletedToday(habit)) return; // Already completed

    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result = await habitsNotifier.completeHabit(habit.id);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: ref.read(flexibleColorsProvider).error,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${habit.name} completed!'),
          backgroundColor: ref.read(flexibleColorsProvider).success,
        ),
      );
    }
  }

  void _toggleExpansion(WidgetRef ref) {
    final currentState = ref.read(bundleExpandedProvider(habit.id));
    ref.read(bundleExpandedProvider(habit.id).notifier).state = !currentState;
  }

  Future<void> _completeBundle(BuildContext context, WidgetRef ref) async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result = await habitsNotifier.completeBundle(habit.id);
    final colors = ref.watchColors;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: colors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final allAvailableHabits = habitsNotifier.getAvailableHabitsForBundle();
    final colors = ref.watchColors;

    // Filter out habits that are already in this bundle
    final currentBundleChildIds = habit.bundleChildIds ?? [];
    final availableHabits = allAvailableHabits
        .where((h) => !currentBundleChildIds.contains(h.id))
        .toList();

    if (availableHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(allAvailableHabits.isEmpty
              ? 'No available habits to add. Create some individual habits first!'
              : 'No more habits available to add to this bundle.'),
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
            Icon(Icons.add_circle, color: colors.draculaPink),
            const SizedBox(width: 8),
            Expanded(
                child: Text('Add to ${habit.name}',
                    style: TextStyle(color: colors.draculaPurple))),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a habit to add to this bundle:',
                style: TextStyle(color: colors.draculaCyan),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: availableHabits.length,
                  itemBuilder: (context, index) {
                    final habitToAdd = availableHabits[index];
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
                          color: colors.draculaCyan.withOpacity(0.4),
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
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.of(context).pop();
                            _addHabitToBundle(context, ref, habitToAdd.id);
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
                                    color: _getHabitTypeColor(habitToAdd.type)
                                        .withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _getHabitTypeColor(habitToAdd.type)
                                          .withOpacity(0.3),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      if (habitToAdd
                                          .description.isNotEmpty) ...[
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
                                  color: colors.draculaPink,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:
                Text('Cancel', style: TextStyle(color: colors.draculaComment)),
          ),
        ],
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
        return AppColors.basicHabit; // Use same color as basic for now
      case HabitType.weekly:
        return AppColors.basicHabit; // Use same color as basic for now
    }
  }

  Future<void> _addHabitToBundle(
      BuildContext context, WidgetRef ref, String habitId) async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result = await habitsNotifier.addHabitToBundle(habit.id, habitId);
    final colors = ref.watchColors;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: colors.success,
        ),
      );
    }
  }

  void _navigateToBundleInfo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BundleInfoScreen(
          bundle: habit,
          allHabits: allHabits,
        ),
      ),
    );
  }
}
