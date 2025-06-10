import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../providers/habits_provider.dart';
import '../shared/base_add_habit_screen.dart';
import '../basic_habit/add_basic_habit_screen.dart';
import '../bundle_habit/add_bundle_habit_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/flexible_theme_system.dart';

class AddAvoidanceHabitScreen extends BaseAddHabitScreen {
  const AddAvoidanceHabitScreen({super.key});

  @override
  ConsumerState<AddAvoidanceHabitScreen> createState() => _AddAvoidanceHabitScreenState();
}

class _AddAvoidanceHabitScreenState extends BaseAddHabitScreenState<AddAvoidanceHabitScreen> {
  @override
  String get screenTitle => 'Add Avoidance Habit';

  @override
  String get nameFieldHint => 'e.g., Avoid social media';

  @override
  HabitType get currentHabitType => HabitType.avoidance;

  @override
  String get currentRoute => '/add-avoidance-habit';

  @override
  bool get showHabitTypeSelector => true; // Enable dropdown to select habit types

  @override
  Widget buildCustomContent(BuildContext context) {
    final colors = ref.watchColors;
    return Card(
      color: colors.draculaRed.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.block, color: colors.draculaRed),
                const SizedBox(width: 8),
                Text(
                  'Avoidance Habit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.draculaRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• Track things you want to avoid or stop doing\n'
              '• Mark failures when you slip up\n'
              '• Complete successfully when you avoid the behavior all day\n'
              '• Breaks streak on first failure, but you can still mark success',
              style: TextStyle(
                fontSize: 14,
                color: colors.draculaForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildTipsSection(BuildContext context) {
    final colors = ref.watchColors;
    return Card(
      color: colors.draculaOrange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: colors.draculaOrange),
                const SizedBox(width: 8),
                Text(
                  'Avoidance Tips',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.draculaOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• Replace bad habits with good ones\n'
              '• Identify triggers that lead to the behavior\n'
              '• Be honest about failures - tracking helps awareness',
              style: TextStyle(
                fontSize: 14,
                color: colors.draculaForeground,
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
      type: HabitType.avoidance,
    );

    // Add to Riverpod state
    ref.read(habitsProvider.notifier).addHabit(habit);
  }

  @override
  String getSuccessMessage() {
    return 'Avoidance habit "${nameController.text.trim()}" created!';
  }

  @override
  void navigateToHabitType(String route) {
    Widget targetScreen;
    switch (route) {
      case '/add-avoidance-habit':
        return; // Already on this screen
      case '/add-basic-habit':
        targetScreen = const AddBasicHabitScreen();
        break;
      case '/add-bundle-habit':
        targetScreen = const AddBundleHabitScreen();
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