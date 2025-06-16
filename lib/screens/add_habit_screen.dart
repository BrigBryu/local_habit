import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../providers/habits_provider.dart';
import '../core/theme/app_colors.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Habit'),
        backgroundColor: AppColors.draculaBackground,
        foregroundColor: AppColors.draculaForeground,
      ),
      backgroundColor: AppColors.backgroundDark,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: AppColors.draculaForeground),
              decoration: InputDecoration(
                labelText: 'Habit Name',
                labelStyle: TextStyle(color: AppColors.draculaComment),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.draculaComment),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryPurple),
                ),
                filled: true,
                fillColor: AppColors.cardBackgroundDark,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: TextStyle(color: AppColors.draculaForeground),
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: TextStyle(color: AppColors.draculaComment),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.draculaComment),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryPurple),
                ),
                filled: true,
                fillColor: AppColors.cardBackgroundDark,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<HabitType>(
              value: _selectedType,
              style: TextStyle(color: AppColors.draculaForeground),
              decoration: InputDecoration(
                labelText: 'Habit Type',
                labelStyle: TextStyle(color: AppColors.draculaComment),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.draculaComment),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryPurple),
                ),
                filled: true,
                fillColor: AppColors.cardBackgroundDark,
              ),
              dropdownColor: AppColors.cardBackgroundDark,
              items: [
                DropdownMenuItem(
                  value: HabitType.basic,
                  child: Text('Basic Habit',
                      style: TextStyle(color: AppColors.draculaForeground)),
                ),
                DropdownMenuItem(
                  value: HabitType.avoidance,
                  child: Text('Avoidance Habit',
                      style: TextStyle(color: AppColors.draculaForeground)),
                ),
              ],
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
                backgroundColor: AppColors.primaryPurple,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name')),
      );
      return;
    }

    final habit = Habit.create(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
    );

    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final error = await habitsNotifier.addHabit(habit);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habit created successfully!')),
      );
    }
  }
}
