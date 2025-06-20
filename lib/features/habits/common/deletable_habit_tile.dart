import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/flexible_theme_system.dart';

/// A wrapper widget that adds delete functionality to any habit tile
class DeletableHabitTile extends ConsumerWidget {
  final Widget child;
  final Habit habit;

  const DeletableHabitTile({
    super.key,
    required this.child,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;

    return Dismissible(
      key: Key('delete_${habit.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _showDeleteConfirmation(context, ref),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.delete,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onLongPress: () => _showDeleteConfirmation(context, ref),
        child: child,
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, WidgetRef ref) async {
    final colors = ref.read(flexibleColorsProvider);
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.gruvboxBg,
        title: Text(
          'Delete Habit',
          style: TextStyle(
            color: colors.gruvboxFg,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Delete "${habit.name}" permanently?\n\nThis action cannot be undone.',
          style: TextStyle(
            color: colors.gruvboxFg,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.draculaComment),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await _deleteHabit(context, ref);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteHabit(BuildContext context, WidgetRef ref) async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final colors = ref.read(flexibleColorsProvider);
    
    final result = await habitsNotifier.removeHabit(habit.id);
    
    if (!context.mounted) return;
    
    if (result != null) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      // Show success with undo option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Habit "${habit.name}" deleted'),
          backgroundColor: colors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () => _undoDelete(ref),
          ),
        ),
      );
    }
  }

  Future<void> _undoDelete(WidgetRef ref) async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    await habitsNotifier.addHabit(habit);
  }
}