import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/bundle_service.dart' as bundle_service;
import '../../../providers/habits_provider.dart';
import '../../../core/theme/theme_controller.dart';

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
              _isReorderMode ? 'Done reordering' : 'Organize',
              style: TextStyle(
                color:
                    _isReorderMode ? colors.draculaGreen : colors.draculaPink,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showAddHabitDialog(context, ref),
            icon: Icon(Icons.add, color: colors.draculaGreen),
          ),
        ],
      ),
      backgroundColor: colors.draculaBackground,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            Text(
              widget.bundle.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.draculaPurple,
              ),
            ),
            const SizedBox(height: 16),
            
            // Description
            if (widget.bundle.description.isNotEmpty) ...[
              Text(
                widget.bundle.description,
                style: TextStyle(
                  fontSize: 16,
                  color: colors.draculaCyan,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Habit Type
            Text(
              'Type: Bundle Habit',
              style: TextStyle(
                fontSize: 16,
                color: colors.draculaYellow,
              ),
            ),
            const SizedBox(height: 16),
            
            // Status
            Text(
              'Status: ${isCompleted ? 'Completed' : 'Not completed'}',
              style: TextStyle(
                fontSize: 16,
                color: isCompleted ? colors.draculaGreen : colors.draculaOrange,
              ),
            ),
            const SizedBox(height: 16),
            
            // Streak
            Text(
              'Streak: ${currentBundle.currentStreak} days',
              style: TextStyle(
                fontSize: 16,
                color: colors.draculaPink,
              ),
            ),
            const SizedBox(height: 16),
            
            // Coins award for next completion
            Text(
              'Coins award for next completion: ${_getCoinsForNextCompletion(currentBundle)}',
              style: TextStyle(
                fontSize: 16,
                color: colors.draculaCyan,
              ),
            ),
            const SizedBox(height: 24),
            
            // Progress
            Text(
              'Progress: ${progress.completed}/${progress.total} habits completed',
              style: TextStyle(
                fontSize: 16,
                color: colors.draculaForeground,
              ),
            ),
            const SizedBox(height: 24),

            // Habits List
            if (_isReorderMode)
              Expanded(
                child: _buildReorderableHabitsList(context, ref,
                    _getOrderedChildren(currentBundle, widget.allHabits))
              )
            else
              Expanded(
                child: children.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: children.length,
                        itemBuilder: (context, index) {
                          final habit = children[index];
                          return _buildSimpleHabitCard(context, ref, habit);
                        },
                      ),
              ),
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

  Widget _buildSimpleHabitCard(BuildContext context, WidgetRef ref, Habit habit) {
    final isCompleted = _isHabitCompletedToday(habit);
    final colors = ref.watchColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.draculaCyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.draculaPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: ${isCompleted ? 'Completed' : 'Not completed'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted ? colors.draculaGreen : colors.draculaOrange,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeHabitFromBundle(context, ref, habit.id),
            icon: Icon(Icons.remove_circle, color: colors.draculaRed),
          ),
        ],
      ),
    );
  }

  int _getCoinsForNextCompletion(Habit habit) {
    // Calculate coins based on streak length + 1 (capped at 30)
    final nextStreak = habit.currentStreak + 1;
    final baseAward = nextStreak.clamp(1, 30);
    
    // Calculate milestone bonuses
    int milestoneBonus = 0;
    if (nextStreak == 7) {
      milestoneBonus = 10;
    } else if (nextStreak == 30) {
      milestoneBonus = 25;
    } else if (nextStreak == 100) {
      milestoneBonus = 75;
    }
    
    return baseAward + milestoneBonus;
  }

  bool _isHabitCompletedToday(Habit habit) {
    if (habit.lastCompleted == null) return false;
    final now = DateTime.now();
    final lastCompleted = habit.lastCompleted!;
    return now.year == lastCompleted.year &&
        now.month == lastCompleted.month &&
        now.day == lastCompleted.day;
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

  Future<void> _removeHabitFromBundle(
      BuildContext context, WidgetRef ref, String habitId) async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result =
        await habitsNotifier.removeHabitFromBundle(widget.bundle.id, habitId);
    final colors = ref.watchColors;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: colors.draculaRed,
        ),
      );
    }
  }
}
