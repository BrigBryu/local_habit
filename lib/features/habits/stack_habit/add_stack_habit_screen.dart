import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/services/stack_progress_service.dart';
import '../shared/base_add_habit_screen.dart';
import '../../../core/theme/flexible_theme_system.dart';

class AddStackHabitScreen extends BaseAddHabitScreen {
  const AddStackHabitScreen({super.key});

  @override
  ConsumerState<AddStackHabitScreen> createState() =>
      _AddStackHabitScreenState();
}

class _AddStackHabitScreenState
    extends BaseAddHabitScreenState<AddStackHabitScreen> {
  final List<String> _selectedHabitIds = [];
  final _stackService = StackProgressService();

  // Get available habits that can be added to a stack
  List<Habit> get _availableHabits {
    final habitsAsync = ref.watch(habitsProvider);
    final allHabits = habitsAsync.value ?? [];

    // Filter out bundles, stacks, and habits already in relationships
    return allHabits.where((habit) {
      // Don't allow bundles or other stacks
      if (habit.type == HabitType.bundle || habit.type == HabitType.stack) {
        return false;
      }

      // Don't allow habits already in bundles or stacks
      if (habit.parentBundleId != null || habit.stackedOnHabitId != null || habit.parentStackId != null) {
        return false;
      }

      // Don't allow habits already in another stack (new architecture)
      final existingStack = allHabits
          .where((h) =>
              h.type == HabitType.stack &&
              (h.stackChildIds?.contains(habit.id) ?? false))
          .firstOrNull;
      if (existingStack != null) {
        return false;
      }

      return true;
    }).toList();
  }

  // Get selected habits in the order they were selected
  List<Habit> get _selectedHabits {
    final availableHabits = _availableHabits;
    return _selectedHabitIds
        .map((id) {
          try {
            return availableHabits.firstWhere((habit) => habit.id == id);
          } catch (e) {
            return null;
          }
        })
        .where((habit) => habit != null)
        .cast<Habit>()
        .toList();
  }

  // Get unselected habits
  List<Habit> get _unselectedHabits {
    final availableHabits = _availableHabits;
    return availableHabits
        .where((habit) => !_selectedHabitIds.contains(habit.id))
        .toList();
  }

  @override
  String get screenTitle => 'Create Stack';

  @override
  String get nameFieldLabel => 'Stack Name';

  @override
  String get nameFieldHint => 'e.g., Learn Spanish Daily';

  @override
  String get descriptionFieldHint => 'Brief description of this habit sequence';

  @override
  String get saveButtonText => 'Create Stack';

  @override
  HabitType get currentHabitType => HabitType.stack;

  @override
  String get currentRoute => '/add-stack-habit';

  @override
  bool get showHabitTypeSelector =>
      true; // Enable dropdown to select habit types

  @override
  Widget buildCustomContent(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Info card about stacks
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colors.stackHabit.withOpacity(0.1),
            border: Border.all(
              color: colors.stackHabit.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: colors.stackHabit,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Stacks are sequential habit chains. Only the current step can be completed, and completing it unlocks the next. Complete all steps in one day for a +1 XP bonus!',
                  style: TextStyle(
                    color: colors.stackHabit,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Stack steps section
        Text(
          'Stack Steps',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.draculaPurple,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select habits to include in this stack. They will be completed in the order you select them.',
          style: TextStyle(
            color: colors.draculaCyan,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),

        // Selected habits (reorderable)
        if (_selectedHabits.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colors.draculaCurrentLine.withOpacity(0.3),
              border: Border.all(
                color: colors.stackHabit.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.layers,
                        color: colors.stackHabit,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Selected Steps (${_selectedHabits.length})',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colors.stackHabit,
                        ),
                      ),
                    ],
                  ),
                ),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedHabits.length,
                  onReorder: _reorderSelectedHabits,
                  itemBuilder: (context, index) {
                    final habit = _selectedHabits[index];
                    return _buildSelectedHabitTile(context, ref, habit, index);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Available habits to add
        if (_unselectedHabits.isNotEmpty) ...[
          Text(
            'Available Habits',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.draculaPurple,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.draculaComment.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ListView.builder(
              itemCount: _unselectedHabits.length,
              itemBuilder: (context, index) {
                final habit = _unselectedHabits[index];
                return _buildAvailableHabitTile(context, ref, habit);
              },
            ),
          ),
        ] else if (_availableHabits.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colors.draculaComment.withOpacity(0.1),
              border: Border.all(
                color: colors.draculaComment.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  color: colors.draculaComment,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Available Habits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.draculaComment,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create some basic or avoidance habits first, then come back to add them to a stack.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.draculaComment,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedHabitTile(
      BuildContext context, WidgetRef ref, Habit habit, int index) {
    final colors = ref.watchColors;

    return Container(
      key: ValueKey(habit.id),
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: colors.draculaCurrentLine.withOpacity(0.1),
        border: Border(
          left: BorderSide(
            color: colors.stackHabit,
            width: 3,
          ),
          bottom: index < _selectedHabits.length - 1
              ? BorderSide(
                  color: colors.draculaComment.withOpacity(0.1),
                  width: 0.5,
                )
              : BorderSide.none,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.stackHabit,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colors.draculaPurple,
          ),
        ),
        subtitle: habit.description.isNotEmpty
            ? Text(
                habit.description,
                style: TextStyle(
                  color: colors.draculaCyan,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.drag_handle,
              color: colors.draculaComment,
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _removeHabit(habit.id),
              icon: Icon(
                Icons.remove_circle_outline,
                color: colors.draculaRed,
              ),
              tooltip: 'Remove from stack',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableHabitTile(
      BuildContext context, WidgetRef ref, Habit habit) {
    final colors = ref.watchColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.draculaComment.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _getHabitTypeColor(habit.type, colors).withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: _getHabitTypeColor(habit.type, colors).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            _getHabitTypeIcon(habit.type),
            color: _getHabitTypeColor(habit.type, colors),
            size: 16,
          ),
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colors.draculaPurple,
          ),
        ),
        subtitle: habit.description.isNotEmpty
            ? Text(
                habit.description,
                style: TextStyle(
                  color: colors.draculaCyan,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: IconButton(
          onPressed: () => _addHabit(habit.id),
          icon: Icon(
            Icons.add_circle,
            color: colors.stackHabit,
          ),
          tooltip: 'Add to stack',
        ),
        onTap: () => _addHabit(habit.id),
      ),
    );
  }

  void _addHabit(String habitId) {
    if (!_selectedHabitIds.contains(habitId)) {
      setState(() {
        _selectedHabitIds.add(habitId);
      });
    }
  }

  void _removeHabit(String habitId) {
    setState(() {
      _selectedHabitIds.remove(habitId);
    });
  }

  void _reorderSelectedHabits(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _selectedHabitIds.removeAt(oldIndex);
      _selectedHabitIds.insert(newIndex, item);
    });
  }

  @override
  bool canSave() {
    return nameController.text.trim().isNotEmpty &&
        _selectedHabitIds.isNotEmpty &&
        _selectedHabitIds.length <= 10;
  }

  @override
  Future<void> performSave() async {
    if (_selectedHabitIds.isEmpty) {
      throw Exception('Please select at least one habit for the stack');
    }

    if (_selectedHabitIds.length > 10) {
      throw Exception('Stacks cannot have more than 10 steps');
    }

    // Validate using the stack service
    final allHabits = (ref.read(habitsProvider).value ?? []);
    final validationError = _stackService.validateStackCreation(_selectedHabitIds, allHabits);
    if (validationError != null) {
      throw Exception(validationError);
    }

    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);

    // Use addStack method to properly handle child habit updates
    final error = await habitsNotifier.addStack(name, description, _selectedHabitIds);
    if (error != null) {
      throw Exception(error);
    }
  }

  @override
  String getSuccessMessage() {
    return 'Stack "${nameController.text.trim()}" created with ${_selectedHabitIds.length} steps!';
  }

  Color _getHabitTypeColor(HabitType type, FlexibleColors colors) {
    switch (type) {
      case HabitType.basic:
        return colors.basicHabit;
      case HabitType.avoidance:
        return colors.avoidanceHabit;
      case HabitType.bundle:
        return colors.bundleHabit;
      case HabitType.stack:
        return colors.stackHabit;
      case HabitType.interval:
        return colors.basicHabit; // Use same color as basic for now
      case HabitType.weekly:
        return colors.basicHabit; // Use same color as basic for now
    }
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
        return Icons.schedule; // Clock icon for interval habits
      case HabitType.weekly:
        return Icons.date_range; // Calendar icon for weekly habits
    }
  }
}
