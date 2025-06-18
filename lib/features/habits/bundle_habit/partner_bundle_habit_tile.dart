import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../core/theme/flexible_theme_system.dart';
import 'providers.dart';

class PartnerBundleHabitTile extends ConsumerWidget {
  final Habit habit;
  final List<Habit> allHabits;

  const PartnerBundleHabitTile({
    super.key,
    required this.habit,
    required this.allHabits,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ExpandablePartnerBundleTile(
      habit: habit,
      allHabits: allHabits,
    );
  }
}

class _ExpandablePartnerBundleTile extends ConsumerWidget {
  final Habit habit;
  final List<Habit> allHabits;

  const _ExpandablePartnerBundleTile({
    required this.habit,
    required this.allHabits,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childHabits = habit.bundleChildIds
            ?.map((id) => allHabits.where((h) => h.id == id).firstOrNull)
            .where((h) => h != null)
            .cast<Habit>()
            .toList() ??
        [];

    final completedCount =
        childHabits.where((h) => _isHabitCompletedToday(h)).length;
    final totalCount = childHabits.length;
    final isCompleted = completedCount == totalCount && totalCount > 0;
    final progressPercentage =
        totalCount > 0 ? completedCount / totalCount : 0.0;
    final colors = ref.watchColors;

    // Use the same expansion provider pattern as the regular bundle tile
    final isExpanded = ref.watch(bundleExpandedProvider(habit.id));

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
              : colors.draculaCyan.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            _buildPartnerBundleHeader(context, ref, completedCount, totalCount,
                isCompleted, progressPercentage, childHabits),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: _buildChildrenSection(context, ref, childHabits),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerBundleHeader(
    BuildContext context,
    WidgetRef ref,
    int completedCount,
    int totalCount,
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
                ? colors.draculaGreen.withOpacity(0.12)
                : colors.draculaPurple.withOpacity(0.08),
            isCompleted
                ? colors.draculaGreen.withOpacity(0.06)
                : colors.draculaPurple.withOpacity(0.04),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          // Progress Ring
          _buildProgressRing(completedCount, totalCount, isCompleted,
              progressPercentage, context, ref, children),
          const SizedBox(width: 16),
          // Bundle Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Partner indicator
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 12,
                      color: colors.draculaComment.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Partner\'s Bundle',
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.draculaComment.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  habit.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted
                        ? colors.draculaGreen.withOpacity(0.9)
                        : colors.draculaPurple.withOpacity(0.9),
                  ),
                ),
                if (habit.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    habit.description,
                    style: TextStyle(
                      color: colors.draculaCyan.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Expand / collapse chevron (read-only, no completion buttons)
          IconButton(
            icon: Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: colors.draculaPink.withOpacity(0.7),
              size: 24,
            ),
            onPressed: () => _toggleExpansion(ref),
            tooltip: isExpanded ? 'Collapse bundle' : 'Expand bundle',
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(
      int completedCount,
      int totalCount,
      bool isCompleted,
      double progressPercentage,
      BuildContext context,
      WidgetRef ref,
      List<Habit> children) {
    final colors = ref.watchColors;

    // Build tooltip text with habit names and completion status
    String tooltipText = 'Partner\'s bundle habits:\n';
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
      tooltipText = 'No habits in this partner bundle yet';
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
              backgroundColor: colors.draculaComment.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(
                isCompleted
                    ? colors.draculaGreen.withOpacity(0.8)
                    : colors.draculaComment.withOpacity(0.8),
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
                  '$completedCount/$totalCount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? colors.draculaGreen.withOpacity(0.9)
                        : colors.draculaCyan.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
            'No habits in this partner bundle yet',
            style: TextStyle(
              color: colors.draculaComment.withOpacity(0.7),
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
                child: _buildNestedPartnerHabitTile(context, ref, child),
              )),
        ],
      ),
    );
  }

  Widget _buildNestedPartnerHabitTile(
      BuildContext context, WidgetRef ref, Habit habit) {
    // Read-only nested habit tile for partner bundle context
    final isCompleted = _isHabitCompletedToday(habit);
    final colors = ref.watchColors;

    return Container(
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: colors.draculaPurple.withOpacity(0.3),
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
                    color: colors.draculaPurple.withOpacity(0.8),
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
                          color: colors.draculaCyan.withOpacity(0.7),
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
        trailing: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted
              ? colors.draculaGreen.withOpacity(0.8)
              : colors.draculaComment.withOpacity(0.6),
          size: 20,
        ),
        // No onTap - this is read-only for partner habits
      ),
    );
  }

  void _toggleExpansion(WidgetRef ref) {
    final currentState = ref.read(bundleExpandedProvider(habit.id));
    ref.read(bundleExpandedProvider(habit.id).notifier).state = !currentState;
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
