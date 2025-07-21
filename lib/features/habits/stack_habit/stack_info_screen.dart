import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/theme_controller.dart';
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
            tooltip: 'Organize Stack',
          ),
          IconButton(
            onPressed: () => _showAddHabitDialog(context, ref),
            icon: Icon(Icons.add, color: colors.draculaGreen),
            tooltip: 'Add Habit',
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
              widget.stack.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.draculaPurple,
              ),
            ),
            const SizedBox(height: 16),
            
            // Description
            if (widget.stack.description.isNotEmpty) ...[
              Text(
                widget.stack.description,
                style: TextStyle(
                  fontSize: 16,
                  color: colors.draculaCyan,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Habit Type
            Text(
              'Type: Stack Habit',
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
              'Streak: ${currentStack.currentStreak} days',
              style: TextStyle(
                fontSize: 16,
                color: colors.draculaPink,
              ),
            ),
            const SizedBox(height: 16),
            
            // Coins award for next completion
            Text(
              'Coins award for next completion: ${_getCoinsForNextCompletion(currentStack)}',
              style: TextStyle(
                fontSize: 16,
                color: colors.draculaCyan,
              ),
            ),
            const SizedBox(height: 16),
            
            // Progress
            Text(
              'Progress: ${progress.completed}/${progress.total} steps completed',
              style: TextStyle(
                fontSize: 16,
                color: colors.draculaForeground,
              ),
            ),
            const SizedBox(height: 24),

            // Children List
            Expanded(
              child: children.isEmpty
                  ? Center(
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
                            'No habits in this stack yet',
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
                        final child = children[index];
                        final isChildCompleted = _isHabitCompletedToday(child);
                        final isCurrent = index == currentStack.currentChildIndex;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrent ? colors.draculaOrange : colors.draculaCyan.withOpacity(0.3),
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isChildCompleted ? colors.draculaGreen : colors.draculaComment.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: isChildCompleted
                                      ? Icon(Icons.check, color: Colors.white, size: 16)
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      child.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: colors.draculaPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Status: ${isChildCompleted ? 'Completed' : 'Not completed'}${isCurrent ? ' (Current)' : ''}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isChildCompleted ? colors.draculaGreen : colors.draculaOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeHabitFromStack(context, ref, child.id),
                                icon: Icon(Icons.remove_circle, color: colors.draculaRed),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
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
                'Organize Stack',
                style: TextStyle(color: colors.draculaPurple),
              ),
            ),
          ],
        ),
        content: Text(
          'Stack organization is not yet implemented. You can delete and recreate the stack if needed.',
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
            Expanded(child: Text('Add to ${widget.stack.name}')),
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
                    _addHabitToStack(context, ref, habit.id);
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

  Future<void> _addHabitToStack(
      BuildContext context, WidgetRef ref, String habitId) async {
    // This would need to be implemented in the habits provider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add to stack functionality not yet implemented'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _removeHabitFromStack(
      BuildContext context, WidgetRef ref, String habitId) async {
    // This would need to be implemented in the habits provider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Remove from stack functionality not yet implemented'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}