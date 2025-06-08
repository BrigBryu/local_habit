import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../providers/habits_provider.dart';
import 'package:data_local/repositories/bundle_service.dart';

class CreateBundleScreen extends ConsumerStatefulWidget {
  const CreateBundleScreen({super.key});

  @override
  ConsumerState<CreateBundleScreen> createState() => _CreateBundleScreenState();
}

class _CreateBundleScreenState extends ConsumerState<CreateBundleScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _selectedHabitIds = [];
  final _bundleService = BundleService();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableHabits = _bundleService.getAvailableHabitsForBundle(ref.watch(habitsProvider));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Bundle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _canCreateBundle() ? _createBundle : null,
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bundle Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Bundle Name',
                hintText: 'e.g., Morning Routine',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            
            const SizedBox(height: 16),
            
            // Bundle Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Brief description of this routine',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 24),
            
            // Section Header
            Row(
              children: [
                const Text(
                  'Select Habits (minimum 2)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${availableHabits.length} available',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            if (availableHabits.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No available habits',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create some individual habits first',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: availableHabits.length,
                  onReorder: (oldIndex, newIndex) {
                    // Handle reordering of selected habits in UI
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = availableHabits.removeAt(oldIndex);
                      availableHabits.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final habit = availableHabits[index];
                    final isSelected = _selectedHabitIds.contains(habit.id);
                    
                    return Card(
                      key: ValueKey(habit.id),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedHabitIds.add(habit.id);
                            } else {
                              _selectedHabitIds.remove(habit.id);
                            }
                          });
                        },
                        title: Text(habit.displayName),
                        subtitle: Text(habit.description),
                        secondary: const Icon(Icons.drag_handle),
                      ),
                    );
                  },
                ),
              ),
            
            // Selected count
            if (_selectedHabitIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_selectedHabitIds.length} habits selected',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_selectedHabitIds.length >= 2)
                        Text(
                          'Combo bonus: +${_selectedHabitIds.length ~/ 2} XP',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _canCreateBundle() {
    return _nameController.text.trim().isNotEmpty && _selectedHabitIds.length >= 2;
  }

  void _createBundle() {
    try {
      final habitsNotifier = ref.read(habitsProvider.notifier);
      habitsNotifier.addBundle(
        _nameController.text.trim(),
        _descriptionController.text.trim().isEmpty 
            ? 'Bundle with ${_selectedHabitIds.length} habits'
            : _descriptionController.text.trim(),
        _selectedHabitIds,
      );
      
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bundle "${_nameController.text.trim()}" created!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}