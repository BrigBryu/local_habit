import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import 'package:data_local/repositories/bundle_service.dart';
import '../shared/base_add_habit_screen.dart';
import '../basic_habit/add_basic_habit_screen.dart';
import '../avoidance_habit/add_avoidance_habit_screen.dart';
import '../stack_habit/add_stack_habit_screen.dart';
import '../../../core/theme/app_colors.dart';

class AddBundleHabitScreen extends BaseAddHabitScreen {
  const AddBundleHabitScreen({super.key});

  @override
  ConsumerState<AddBundleHabitScreen> createState() =>
      _AddBundleHabitScreenState();
}

class _AddBundleHabitScreenState
    extends BaseAddHabitScreenState<AddBundleHabitScreen> {
  final List<String> _selectedHabitIds = [];
  final _bundleService = BundleService();

  // Get available habits in a stable order
  List<Habit> get _availableHabits {
    final habitsAsync = ref.watch(habitsProvider);
    return _bundleService.getAvailableHabitsForBundle(habitsAsync.value ?? []);
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
  String get screenTitle => 'Create Bundle';

  @override
  String get nameFieldLabel => 'Bundle Name';

  @override
  String get nameFieldHint => 'e.g., Morning Routine';

  @override
  String get descriptionFieldHint => 'Brief description of this routine';

  @override
  String get saveButtonText => 'Create Bundle';

  @override
  HabitType get currentHabitType => HabitType.bundle;

  @override
  String get currentRoute => '/add-bundle-habit';

  @override
  bool get showHabitTypeSelector =>
      true; // Enable dropdown to select habit types

  @override
  Widget buildCustomContent(BuildContext context, WidgetRef ref) {
    final availableHabits = _availableHabits;
    final selectedHabits = _selectedHabits;
    final unselectedHabits = _unselectedHabits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Text(
              'Select Habits (minimum 2)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.draculaPurple,
              ),
            ),
            const Spacer(),
            Text(
              '${availableHabits.length} available',
              style: TextStyle(color: AppColors.draculaCyan),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.draculaPurple.withOpacity(0.3),
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
          child: availableHabits.isEmpty
              ? SizedBox(
                  height: 200,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline,
                            size: 64, color: AppColors.draculaComment),
                        SizedBox(height: 16),
                        Text(
                          'No available habits',
                          style: TextStyle(
                              fontSize: 18, color: AppColors.draculaComment),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create some individual habits first',
                          style: TextStyle(color: AppColors.draculaComment),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selected habits section (reorderable)
                      if (selectedHabits.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                AppColors.draculaCurrentLine.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.draculaComment,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Selected habits:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.draculaCyan,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: ReorderableListView.builder(
                            itemCount: selectedHabits.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) newIndex -= 1;
                                final item =
                                    _selectedHabitIds.removeAt(oldIndex);
                                _selectedHabitIds.insert(newIndex, item);
                              });
                            },
                            itemBuilder: (context, index) {
                              final habit = selectedHabits[index];
                              return Container(
                                key: ValueKey(habit.id),
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.draculaCurrentLine
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.draculaPurple
                                        .withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.draculaPurple
                                          .withOpacity(0.1),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    habit.displayName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.draculaPurple,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove_circle,
                                            color: AppColors.draculaRed,
                                            size: 20),
                                        onPressed: () {
                                          setState(() {
                                            _selectedHabitIds.remove(habit.id);
                                          });
                                        },
                                      ),
                                      Icon(Icons.drag_handle,
                                          size: 20,
                                          color: AppColors.draculaComment),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Available habits section
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.draculaCurrentLine.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.draculaComment,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Available habits:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.draculaCyan,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: unselectedHabits.length,
                          itemBuilder: (context, index) {
                            final habit = unselectedHabits[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.draculaCurrentLine
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.draculaComment,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.draculaComment
                                        .withOpacity(0.2),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: CheckboxListTile(
                                dense: true,
                                value: false,
                                onChanged: (selected) {
                                  setState(() {
                                    _selectedHabitIds.add(habit.id);
                                  });
                                },
                                title: Text(
                                  habit.displayName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.draculaPurple,
                                  ),
                                ),
                                subtitle: Text(
                                  habit.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.draculaCyan,
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
        ),

        const SizedBox(height: 16),

        // Selected count
        if (_selectedHabitIds.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.draculaPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.draculaPurple.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppColors.draculaPurple,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_selectedHabitIds.length} habits selected',
                    style: TextStyle(
                      color: AppColors.draculaPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_selectedHabitIds.length >= 2)
                  Text(
                    'Combo bonus: +${_selectedHabitIds.length ~/ 2} XP',
                    style: TextStyle(
                      color: AppColors.draculaYellow,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget buildTipsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            AppColors.draculaCurrentLine.withOpacity(0.6),
            AppColors.draculaCurrentLine.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.draculaPurple.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_special, color: AppColors.draculaPurple),
                const SizedBox(width: 8),
                Text(
                  'Bundle Benefits',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.draculaPurple,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• Complete multiple habits with one action\n'
              '• Earn combo bonuses (+1 XP per 2 habits)\n'
              '• Perfect for routines like "Morning Routine" or "Workout Session"',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.draculaForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool canSave() {
    return nameController.text.trim().isNotEmpty &&
        _selectedHabitIds.length >= 2;
  }

  @override
  Future<void> performSave() async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final error = await habitsNotifier.addBundle(
      nameController.text.trim(),
      descriptionController.text.trim().isEmpty
          ? 'Bundle with ${_selectedHabitIds.length} habits'
          : descriptionController.text.trim(),
      _selectedHabitIds,
    );
    if (error != null) {
      throw Exception(error);
    }
  }

  @override
  String getSuccessMessage() {
    return 'Bundle "${nameController.text.trim()}" created with ${_selectedHabitIds.length} habits!';
  }

  @override
  void navigateToHabitType(String route) {
    Widget targetScreen;
    switch (route) {
      case '/add-bundle-habit':
        return; // Already on this screen
      case '/add-basic-habit':
        targetScreen = const AddBasicHabitScreen();
        break;
      case '/add-avoidance-habit':
        targetScreen = const AddAvoidanceHabitScreen();
        break;
      case '/add-stack-habit':
        targetScreen = const AddStackHabitScreen();
        break;
      default:
        super.navigateToHabitType(route);
        return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }
}
