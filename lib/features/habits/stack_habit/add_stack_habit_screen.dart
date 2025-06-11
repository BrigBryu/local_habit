import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import 'package:data_local/repositories/stack_service.dart';
import '../shared/base_add_habit_screen.dart';
import '../basic_habit/add_basic_habit_screen.dart';
import '../avoidance_habit/add_avoidance_habit_screen.dart';
import '../bundle_habit/add_bundle_habit_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/flexible_theme_system.dart';

class AddStackHabitScreen extends BaseAddHabitScreen {
  const AddStackHabitScreen({super.key});

  @override
  ConsumerState<AddStackHabitScreen> createState() => _AddStackHabitScreenState();
}

class _AddStackHabitScreenState extends BaseAddHabitScreenState<AddStackHabitScreen> {
  final List<String> _selectedHabitIds = [];
  final _stackService = StackService();
  
  // Get available habits in a stable order
  List<Habit> get _availableHabits {
    return _stackService.getAvailableHabitsForStack(ref.watch(habitsProvider));
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
  String get screenTitle => 'Create Stack Habit';

  @override
  HabitType get currentHabitType => HabitType.stack;

  @override
  String get currentRoute => '/add-stack-habit';

  @override
  String get nameFieldHint => 'Enter stack name (e.g., "Morning Routine")';

  @override
  String get descriptionFieldHint => 'Describe your step-by-step habit stack (e.g., "Complete my morning routine in order")';

  @override
  String get saveButtonText => 'Create Stack';

  @override
  void navigateToHabitType(String route) {
    Widget? screen;
    switch (route) {
      case '/add-basic-habit':
        screen = const AddBasicHabitScreen();
        break;
      case '/add-avoidance-habit':
        screen = const AddAvoidanceHabitScreen();
        break;
      case '/add-bundle-habit':
        screen = const AddBundleHabitScreen();
        break;
      case '/add-stack-habit':
        return; // Already on this screen
    }

    if (screen != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => screen!),
      );
    }
  }

  @override
  Future<void> performSave() async {
    final validationError = validateAdditionalFields();
    if (validationError != null) {
      throw Exception(validationError);
    }

    submitHabit();
  }

  @override
  Widget buildCustomContent(BuildContext context) {
    final colors = ref.watchColors;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        
        // Section header
        Row(
          children: [
            Icon(Icons.format_list_numbered, color: colors.stackHabit, size: 20),
            const SizedBox(width: 8),
            Text(
              'Stack Steps',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.stackHabit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select habits to include as steps. They will be completed in the order you add them.',
          style: TextStyle(
            color: colors.draculaCyan,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),

        // Selected habits (ordered)
        if (_selectedHabits.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.stackHabit.withOpacity(0.1),
                  colors.stackHabit.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.stackHabit.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.reorder, color: colors.stackHabit, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Steps Order (${_selectedHabits.length})',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.stackHabit,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedHabits.length,
                  onReorder: _reorderSteps,
                  itemBuilder: (context, index) {
                    final habit = _selectedHabits[index];
                    return _buildSelectedHabitTile(habit, index);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Available habits
        if (_unselectedHabits.isNotEmpty) ...[
          Text(
            'Available Habits',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.draculaPurple,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _unselectedHabits.length,
              itemBuilder: (context, index) {
                final habit = _unselectedHabits[index];
                return _buildAvailableHabitTile(habit);
              },
            ),
          ),
        ] else if (_selectedHabits.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.draculaComment.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.draculaComment.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.layers_clear,
                  size: 32,
                  color: colors.draculaComment,
                ),
                const SizedBox(height: 8),
                Text(
                  'No available habits',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.draculaComment,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create some individual habits first!',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.draculaComment,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCreateHabitButton(
                      'Basic Habit',
                      Icons.check_circle_outline,
                      AppColors.basicHabit,
                      () => _navigateToCreateHabit(HabitType.basic),
                    ),
                    _buildCreateHabitButton(
                      'Avoidance',
                      Icons.block,
                      AppColors.avoidanceHabit,
                      () => _navigateToCreateHabit(HabitType.avoidance),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSelectedHabitTile(Habit habit, int index) {
    final colors = ref.watchColors;
    
    return Container(
      key: ValueKey(habit.id),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.draculaCurrentLine.withOpacity(0.6),
            colors.draculaCurrentLine.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.stackHabit.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Step number
            Container(
              width: 24,
              height: 24,
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
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Habit type icon
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _getHabitTypeColor(habit.type).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getHabitTypeIcon(habit.type),
                color: _getHabitTypeColor(habit.type),
                size: 14,
              ),
            ),
          ],
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colors.draculaPurple,
          ),
        ),
        subtitle: habit.description.isNotEmpty 
            ? Text(
                habit.description,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.draculaCyan,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_handle, color: colors.draculaComment, size: 16),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () => _removeHabit(habit.id),
              icon: Icon(Icons.remove_circle_outline, color: colors.error, size: 20),
              tooltip: 'Remove from stack',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(maxWidth: 24, maxHeight: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableHabitTile(Habit habit) {
    final colors = ref.watchColors;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.draculaCurrentLine.withOpacity(0.4),
            colors.draculaCurrentLine.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getHabitTypeColor(habit.type).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _getHabitTypeColor(habit.type).withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: _getHabitTypeColor(habit.type).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            _getHabitTypeIcon(habit.type),
            color: _getHabitTypeColor(habit.type),
            size: 16,
          ),
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colors.draculaPurple,
          ),
        ),
        subtitle: habit.description.isNotEmpty 
            ? Text(
                habit.description,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.draculaCyan,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: IconButton(
          onPressed: () => _addHabit(habit.id),
          icon: Icon(Icons.add_circle_outline, color: colors.stackHabit, size: 20),
          tooltip: 'Add to stack',
        ),
        onTap: () => _addHabit(habit.id),
      ),
    );
  }

  Widget _buildCreateHabitButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 16),
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
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
        return Icons.folder_special;
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

  void _addHabit(String habitId) {
    setState(() {
      _selectedHabitIds.add(habitId);
    });
  }

  void _removeHabit(String habitId) {
    setState(() {
      _selectedHabitIds.remove(habitId);
    });
  }

  void _reorderSteps(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _selectedHabitIds.removeAt(oldIndex);
      _selectedHabitIds.insert(newIndex, item);
    });
  }

  void _navigateToCreateHabit(HabitType type) async {
    Widget screen;
    switch (type) {
      case HabitType.basic:
        screen = const AddBasicHabitScreen();
        break;
      case HabitType.avoidance:
        screen = const AddAvoidanceHabitScreen();
        break;
      default:
        return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  String? validateAdditionalFields() {
    if (_selectedHabitIds.isEmpty) {
      return 'Please select at least one habit for your stack';
    }
    
    if (_selectedHabitIds.length > 10) {
      return 'A stack can have at most 10 steps';
    }
    
    return null;
  }

  @override
  void submitHabit() {
    try {
      final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
      final result = habitsNotifier.addStack(
        nameController.text.trim(),
        descriptionController.text.trim(),
        _selectedHabitIds,
      );
      
      final colors = ref.watchColors;
      
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: colors.error,
          ),
        );
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stack "${nameController.text.trim()}" created successfully!'),
          backgroundColor: colors.success,
        ),
      );
      
      Navigator.of(context).pop();
      
    } catch (e) {
      final colors = ref.watchColors;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating stack: $e'),
          backgroundColor: colors.error,
        ),
      );
    }
  }
}