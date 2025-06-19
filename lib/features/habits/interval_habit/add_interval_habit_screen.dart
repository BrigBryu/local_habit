import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../shared/base_add_habit_screen.dart';
import '../basic_habit/add_basic_habit_screen.dart';
import '../avoidance_habit/add_avoidance_habit_screen.dart';
import '../bundle_habit/add_bundle_habit_screen.dart';
import '../stack_habit/add_stack_habit_screen.dart';
import '../weekly_habit/add_weekly_habit_screen.dart';
import '../../../core/theme/app_colors.dart';

class AddIntervalHabitScreen extends BaseAddHabitScreen {
  const AddIntervalHabitScreen({super.key});

  @override
  ConsumerState<AddIntervalHabitScreen> createState() =>
      _AddIntervalHabitScreenState();
}

class _AddIntervalHabitScreenState
    extends BaseAddHabitScreenState<AddIntervalHabitScreen> {
  final TextEditingController _intervalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _intervalController.text = '3'; // Default to 3 days
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  @override
  String get screenTitle => 'Add Interval Habit';

  @override
  String get nameFieldHint => 'e.g., Clip fingernails';

  @override
  HabitType get currentHabitType => HabitType.interval;

  @override
  String get currentRoute => '/add-interval-habit';

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
                AppColors.gruvboxYellow.withOpacity(0.3),
                AppColors.gruvboxYellow.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppColors.gruvboxYellow.withOpacity(0.5),
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
                      '⟳',
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColors.gruvboxYellow,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Interval Habit',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gruvboxYellow,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• Only appears when due (every N days)\n'
                  '• Grayed out and non-tappable when not due\n'
                  '• Shows next due date when inactive\n'
                  '• Earns same XP as basic habits (1 XP per completion)',
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
              color: AppColors.gruvboxYellow.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interval Configuration',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.gruvboxFg,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Complete every',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gruvboxFg,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        controller: _intervalController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.gruvboxFg,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.gruvboxBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.gruvboxYellow.withOpacity(0.5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.gruvboxYellow.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.gruvboxYellow,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final days = int.tryParse(value);
                          if (days == null || days < 1) {
                            return 'Must be ≥ 1';
                          }
                          if (days > 365) {
                            return 'Must be ≤ 365';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'days',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gruvboxFg,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Examples: 3 days (trim beard), 7 days (laundry), 14 days (change sheets)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gruvboxFg.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Future<void> performSave() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final intervalDays = int.tryParse(_intervalController.text);

    if (intervalDays == null || intervalDays < 1) {
      throw Exception('Invalid interval days');
    }

    final habit = Habit.create(
      name: name,
      description: description,
      type: HabitType.interval,
      intervalDays: intervalDays,
    );

    ref.read(habitsNotifierProvider.notifier).addHabit(habit);
  }

  @override
  String getSuccessMessage() {
    final intervalDays = int.tryParse(_intervalController.text) ?? 0;
    return 'Interval habit "${nameController.text.trim()}" created! '
        'Due every $intervalDays days.';
  }

  @override
  void navigateToHabitType(String route) {
    Widget targetScreen;
    switch (route) {
      case '/add-interval-habit':
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
      case '/add-weekly-habit':
        targetScreen = const AddWeeklyHabitScreen();
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