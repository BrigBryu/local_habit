import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_local/repositories/habit_service.dart';
import 'package:domain/entities/habit.dart';
import '../../../../core/theme/flexible_theme_system.dart';

/// Bottom sheet for creating a new bundle habit
class CreateBundleSheet extends ConsumerStatefulWidget {
  final HabitService habitService;

  const CreateBundleSheet({
    super.key,
    required this.habitService,
  });

  @override
  ConsumerState<CreateBundleSheet> createState() => _CreateBundleSheetState();
}

class _CreateBundleSheetState extends ConsumerState<CreateBundleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Set<String> _selectedHabitIds = {};
  bool _isLoading = false;
  List<Habit> _availableHabits = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableHabits();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadAvailableHabits() {
    setState(() {
      _availableHabits = widget.habitService.getAvailableHabitsForBundling();
    });
  }

  void _toggleHabitSelection(String habitId) {
    setState(() {
      if (_selectedHabitIds.contains(habitId)) {
        _selectedHabitIds.remove(habitId);
      } else {
        _selectedHabitIds.add(habitId);
      }
    });
  }

  Future<void> _createBundle() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedHabitIds.length < 2) {
      _showError('Please select at least 2 habits for the bundle');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.habitService.createBundle(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        childHabitIds: _selectedHabitIds.toList(),
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ref.read(flexibleColorsProvider).error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ref.watchColors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: ref.watchColors.draculaComment.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.center,
              ),

              // Title
              Text(
                'Create Routine Bundle',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // Bundle name
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: ref.watchColors.draculaPurple),
                        decoration: InputDecoration(
                          labelText: 'Bundle Name',
                          labelStyle:
                              TextStyle(color: ref.watchColors.bundleHabit),
                          hintText: 'e.g., Morning Routine',
                          hintStyle:
                              TextStyle(color: ref.watchColors.draculaComment),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ref.watchColors.bundleHabit, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ref.watchColors.bundleHabit, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ref.watchColors.draculaPink, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a bundle name';
                          }
                          if (value.trim().length < 2) {
                            return 'Bundle name must be at least 2 characters';
                          }
                          if (value.trim().length > 50) {
                            return 'Bundle name cannot exceed 50 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Bundle description
                      TextFormField(
                        controller: _descriptionController,
                        style: TextStyle(color: ref.watchColors.draculaPurple),
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          labelStyle:
                              TextStyle(color: ref.watchColors.bundleHabit),
                          hintText: 'Describe your routine bundle',
                          hintStyle:
                              TextStyle(color: ref.watchColors.draculaComment),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ref.watchColors.bundleHabit, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ref.watchColors.bundleHabit, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ref.watchColors.draculaPink, width: 2),
                          ),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value != null && value.trim().length > 200) {
                            return 'Description cannot exceed 200 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Available habits section
                      Text(
                        'Select Habits (${_selectedHabitIds.length} selected)',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),

                      if (_availableHabits.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ref.watchColors.draculaCurrentLine
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: ref.watchColors.draculaComment,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No habits available for bundling',
                                style: TextStyle(
                                    color: ref.watchColors.draculaComment),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Create some individual habits first',
                                style: TextStyle(
                                  color: ref.watchColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        // Habits list
                        ...List.generate(_availableHabits.length, (index) {
                          final habit = _availableHabits[index];
                          final isSelected =
                              _selectedHabitIds.contains(habit.id);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: CheckboxListTile(
                              title: Text(habit.name),
                              subtitle: habit.description.isNotEmpty
                                  ? Text(habit.description)
                                  : null,
                              value: isSelected,
                              onChanged: (_) => _toggleHabitSelection(habit.id),
                              secondary: CircleAvatar(
                                backgroundColor: isSelected
                                    ? ref.watchColors.success
                                    : ref.watchColors.draculaCurrentLine,
                                child: Icon(
                                  _getHabitIcon(habit.type),
                                  color: isSelected
                                      ? Colors.white
                                      : ref.watchColors.draculaComment,
                                  size: 20,
                                ),
                              ),
                            ),
                          );
                        }),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Action buttons
              SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading || _selectedHabitIds.length < 2
                            ? null
                            : _createBundle,
                        child: _isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Create Bundle'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getHabitIcon(HabitType type) {
    switch (type) {
      case HabitType.basic:
        return Icons.check_circle_outline;
      case HabitType.avoidance:
        return Icons.block;
      case HabitType.stack:
        return Icons.layers;
      case HabitType.bundle:
        return Icons.folder;
      // TODO: Re-enable when time-based habits are ready
      // case HabitType.alarmHabit:
      //   return Icons.alarm;
      // case HabitType.timedSession:
      //   return Icons.timer;
      // case HabitType.timeWindow:
      //   return Icons.schedule;
      // case HabitType.dailyTimeWindow:
      //   return Icons.calendar_today;
    }
  }
}
