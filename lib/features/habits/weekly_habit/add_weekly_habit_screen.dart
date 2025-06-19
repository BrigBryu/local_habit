import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/services/due_date_service.dart';
import '../shared/base_add_habit_screen.dart';
import '../basic_habit/add_basic_habit_screen.dart';
import '../avoidance_habit/add_avoidance_habit_screen.dart';
import '../bundle_habit/add_bundle_habit_screen.dart';
import '../stack_habit/add_stack_habit_screen.dart';
import '../interval_habit/add_interval_habit_screen.dart';
import '../../../core/theme/app_colors.dart';

class AddWeeklyHabitScreen extends BaseAddHabitScreen {
  const AddWeeklyHabitScreen({super.key});

  @override
  ConsumerState<AddWeeklyHabitScreen> createState() =>
      _AddWeeklyHabitScreenState();
}

class _AddWeeklyHabitScreenState
    extends BaseAddHabitScreenState<AddWeeklyHabitScreen> {
  final Set<int> _selectedWeekdays = <int>{};
  static const List<String> _dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  @override
  void initState() {
    super.initState();
    // Default to Monday and Friday
    _selectedWeekdays.addAll([1, 5]);
  }

  @override
  String get screenTitle => 'Add Weekly Habit';

  @override
  String get nameFieldHint => 'e.g., Take out garbage';

  @override
  HabitType get currentHabitType => HabitType.weekly;

  @override
  String get currentRoute => '/add-weekly-habit';

  @override
  bool get showHabitTypeSelector => true;

  @override
  Widget buildCustomContent(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                AppColors.gruvboxBlue.withOpacity(0.3),
                AppColors.gruvboxBlue.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppColors.gruvboxBlue.withOpacity(0.5),
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
                    Text(
                      '📅',
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColors.gruvboxBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Weekly Habit',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gruvboxBlue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• Only active on selected weekdays\n'
                  '• Grayed out on other days with "Due in X days"\n'
                  '• Earns same XP as basic habits (1 XP per completion)\n'
                  '• Perfect for weekly routines like garbage day',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gruvboxFg,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.gruvboxBg2,
            border: Border.all(
              color: AppColors.gruvboxBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Weekdays',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.gruvboxFg,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Choose which days of the week this habit should be active:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gruvboxFg.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                _buildWeekdaySelector(),
                const SizedBox(height: 12),
                if (_selectedWeekdays.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gruvboxRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.gruvboxRed.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: AppColors.gruvboxRed,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Please select at least one weekday',
                          style: TextStyle(
                            color: AppColors.gruvboxRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdaySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final isSelected = _selectedWeekdays.contains(index);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedWeekdays.remove(index);
              } else {
                _selectedWeekdays.add(index);
              }
            });
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.gruvboxBlue
                  : AppColors.gruvboxBg.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.gruvboxBlue
                    : AppColors.gruvboxBlue.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _dayNames[index].substring(0, 1),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppColors.gruvboxFg,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  bool validateCustomFields() {
    return _selectedWeekdays.isNotEmpty;
  }

  @override
  Future<void> performSave() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    
    if (_selectedWeekdays.isEmpty) {
      throw Exception('Please select at least one weekday');
    }

    final dueDateService = DueDateService();
    final weekdayMask = dueDateService.createWeekdayMask(_selectedWeekdays.toList());

    final habit = Habit.create(
      name: name,
      description: description,
      type: HabitType.weekly,
      weekdayMask: weekdayMask,
    );

    ref.read(habitsNotifierProvider.notifier).addHabit(habit);
  }

  @override
  String getSuccessMessage() {
    final dueDateService = DueDateService();
    final weekdayMask = dueDateService.createWeekdayMask(_selectedWeekdays.toList());
    final dayNames = dueDateService.getWeekdayNames(weekdayMask);
    
    return 'Weekly habit "${nameController.text.trim()}" created! '
        'Active on: ${dayNames.join(', ')}.';
  }

  @override
  void navigateToHabitType(String route) {
    Widget targetScreen;
    switch (route) {
      case '/add-weekly-habit':
        return; // Already on this screen
      case '/add-basic-habit':
        targetScreen = const AddBasicHabitScreen();
        break;
      case '/add-avoidance-habit':
        targetScreen = const AddAvoidanceHabitScreen();
        break;
      case '/add-bundle-habit':
        targetScreen = const AddBundleHabitScreen();
        break;
      case '/add-stack-habit':
        targetScreen = const AddStackHabitScreen();
        break;
      case '/add-interval-habit':
        targetScreen = const AddIntervalHabitScreen();
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