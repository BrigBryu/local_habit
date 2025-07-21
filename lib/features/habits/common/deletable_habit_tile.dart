import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/habit.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/adapters/notification_adapter.dart';
import '../../../shared/notifications/notifications.dart';

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
    // Initialize notification adapter
    ref.watch(notificationAdapterWatcherProvider);

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
    final colors = ref.read(flexibleColorsProviderBridged);
    
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
    
    final result = await habitsNotifier.removeHabit(habit);
    
    if (!context.mounted) return;
    
    if (result != null) {
      // Show error notification
      Notifications.error(context, result);
    } else {
      // Show success notification with undo action
      Notifications.success(
        context,
        'Habit "${habit.name}" deleted',
        action: TextButton(
          onPressed: () {
            Notifications.dismiss();
            _undoDelete(ref);
          },
          child: const Text(
            'Undo',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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