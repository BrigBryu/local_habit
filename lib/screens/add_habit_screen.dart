import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/habit.dart';
import '../providers/habits_provider.dart';
import '../core/theme/theme_controller.dart';
import '../core/adapters/notification_adapter.dart';
import '../shared/notifications/notifications.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  HabitType _selectedType = HabitType.basic;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watchColors;
    // Initialize notification adapter
    ref.watch(notificationAdapterWatcherProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Habit'),
        backgroundColor: colors.draculaBackground,
        foregroundColor: colors.draculaForeground,
      ),
      backgroundColor: colors.draculaBackground,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: colors.draculaForeground),
              decoration: InputDecoration(
                labelText: 'Habit Name',
                labelStyle: TextStyle(color: colors.draculaComment),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors.draculaComment),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors.draculaPink),
                ),
                filled: true,
                fillColor: colors.draculaCurrentLine,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: TextStyle(color: colors.draculaForeground),
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: TextStyle(color: colors.draculaComment),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors.draculaComment),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors.draculaPink),
                ),
                filled: true,
                fillColor: colors.draculaCurrentLine,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<HabitType>(
              value: _selectedType,
              style: TextStyle(color: colors.draculaForeground),
              decoration: InputDecoration(
                labelText: 'Habit Type',
                labelStyle: TextStyle(color: colors.draculaComment),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors.draculaComment),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors.draculaPink),
                ),
                filled: true,
                fillColor: colors.draculaCurrentLine,
              ),
              dropdownColor: colors.draculaCurrentLine,
              items: [HabitType.basic].map((type) => DropdownMenuItem(
                value: type,
                child: Text(type.displayName,
                    style: TextStyle(color: colors.draculaForeground)),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveHabit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.draculaPink,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Create Habit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveHabit() async {
    if (_nameController.text.trim().isEmpty) {
      context.showError('Please enter a habit name');
      return;
    }

    final habit = Habit.create(
      name: _nameController.text.trim(),
      type: _selectedType,
    );
    habit.description = _descriptionController.text.trim();

    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    await habitsNotifier.addHabit(habit);

    Navigator.of(context).pop();
    context.showSuccess('Habit created successfully!');
  }
}
