import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../shared/base_add_habit_screen.dart';
import '../avoidance_habit/add_avoidance_habit_screen.dart';
import '../bundle_habit/add_bundle_habit_screen.dart';
import '../stack_habit/add_stack_habit_screen.dart';
import '../../../core/theme/app_colors.dart';

class AddBasicHabitScreen extends BaseAddHabitScreen {
  const AddBasicHabitScreen({super.key});

  @override
  ConsumerState<AddBasicHabitScreen> createState() => _AddBasicHabitScreenState();
}

class _AddBasicHabitScreenState extends BaseAddHabitScreenState<AddBasicHabitScreen> {
  @override
  String get screenTitle => 'Add Basic Habit';

  @override
  String get nameFieldHint => 'e.g., Drink 8 glasses of water';

  @override
  HabitType get currentHabitType => HabitType.basic;

  @override
  String get currentRoute => '/add-basic-habit';

  @override
  bool get showHabitTypeSelector => true; // Enable dropdown to select habit types

  @override
  Widget buildCustomContent(BuildContext context) {
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
          color: AppColors.draculaCyan.withOpacity(0.3),
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
                Icon(Icons.check_circle_outline, color: AppColors.draculaCyan),
                const SizedBox(width: 8),
                Text(
                  'Basic Habit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.draculaCyan,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• Can be completed multiple times per day\n'
              '• Earns XP with diminishing returns (1st = 1 XP, 2nd = 0.5 XP, 3rd+ = 0.25 XP)\n'
              '• Perfect for building consistent daily routines',
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
  Future<void> performSave() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    // Create the habit
    final habit = Habit.create(
      name: name,
      description: description,
      type: HabitType.basic,
    );

    // Add to Riverpod state
    ref.read(habitsProvider.notifier).addHabit(habit);
  }

  @override
  String getSuccessMessage() {
    return 'Basic habit "${nameController.text.trim()}" created!';
  }

  @override
  void navigateToHabitType(String route) {
    Widget targetScreen;
    switch (route) {
      case '/add-basic-habit':
        return; // Already on this screen
      case '/add-avoidance-habit':
        targetScreen = const AddAvoidanceHabitScreen();
        break;
      case '/add-bundle-habit':
        targetScreen = const AddBundleHabitScreen();
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