import 'package:flutter/material.dart';
import 'package:domain/domain.dart';

/// Demo bundle card that shows nested habits properly
class DemoBundleCard extends StatefulWidget {
  final Habit bundleHabit;
  final List<Habit> allHabits;
  
  const DemoBundleCard({super.key, required this.bundleHabit, required this.allHabits});

  @override
  State<DemoBundleCard> createState() => _DemoBundleCardState();
}

class _DemoBundleCardState extends State<DemoBundleCard> {
  bool _isExpanded = true; // Start expanded to show the concept

  List<Map<String, dynamic>> get _nestedHabits {
    // First try to get real nested habits
    if (widget.bundleHabit.bundleChildIds != null && widget.bundleHabit.bundleChildIds!.isNotEmpty) {
      return widget.bundleHabit.bundleChildIds!.map((childId) {
        final childHabit = widget.allHabits.firstWhere(
          (h) => h.id == childId,
          orElse: () => Habit.create(name: 'Missing Habit', description: 'Habit not found', type: HabitType.basic),
        );
        return {
          'id': childHabit.id,
          'name': childHabit.name,
          'description': childHabit.description,
          'completed': _isHabitCompletedToday(childHabit),
        };
      }).toList();
    }
    
    // Fallback to demo habits to show the concept
    return [
      {
        'id': 'demo1',
        'name': 'defaultbundlehabit1',
        'description': 'First nested habit in bundle (demo)',
        'completed': false,
      },
      {
        'id': 'demo2', 
        'name': 'defaultbundlehabit2',
        'description': 'Second nested habit in bundle (demo)',
        'completed': true,
      },
    ];
  }

  bool _isHabitCompletedToday(Habit habit) {
    if (habit.lastCompleted == null) return false;
    final now = DateTime.now();
    final lastCompleted = habit.lastCompleted!;
    return now.year == lastCompleted.year &&
           now.month == lastCompleted.month &&
           now.day == lastCompleted.day;
  }

  @override
  Widget build(BuildContext context) {
    final nestedHabits = _nestedHabits;
    final completedCount = nestedHabits.where((h) => h['completed'] as bool).length;
    final totalCount = nestedHabits.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final isAllCompleted = completedCount == totalCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(
          color: isAllCompleted ? Colors.green : Colors.blue,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Bundle Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isAllCompleted ? Colors.green : Colors.blue).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                // Progress Circle
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: isAllCompleted ? Colors.green : Colors.blue,
                      width: 3,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Progress indicator
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation(
                            isAllCompleted ? Colors.green : Colors.blue,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      // Progress text
                      Center(
                        child: Text(
                          '$completedCount/$totalCount',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isAllCompleted ? Colors.green : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Bundle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.folder_special,
                            color: isAllCompleted ? Colors.green : Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.bundleHabit.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isAllCompleted ? Colors.green : Colors.blue,
                                decoration: isAllCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAllCompleted ? 'All complete! ✅' : '$completedCount of $totalCount complete',
                        style: TextStyle(
                          color: isAllCompleted ? Colors.green : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.bundleHabit.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.bundleHabit.description,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isAllCompleted)
                      ElevatedButton.icon(
                        onPressed: _completeAllHabits,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        icon: const Icon(Icons.done_all, size: 16),
                        label: const Text('Complete All', style: TextStyle(fontSize: 12)),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      tooltip: _isExpanded ? 'Collapse' : 'Show Nested Habits',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Nested Habits Section (animated)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 0,
            child: _isExpanded ? _buildNestedHabitsSection() : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNestedHabitsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.list_alt, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Nested Habits (${nestedHabits.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  'Tap to complete individually',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          
          // Nested Habit Items
          ...(nestedHabits.asMap().entries.map((entry) {
            final index = entry.key;
            final habit = entry.value;
            return _buildNestedHabitTile(habit, index);
          })),
        ],
      ),
    );
  }

  Widget _buildNestedHabitTile(Map<String, dynamic> habit, int index) {
    final isCompleted = habit['completed'] as bool;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
          left: BorderSide(color: Colors.blue.withOpacity(0.3), width: 3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 20, right: 16, top: 4, bottom: 4),
        leading: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? Colors.green : Colors.grey[400],
          ),
        ),
        title: Text(
          habit['name'] as String,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey[600] : Colors.black87,
          ),
        ),
        subtitle: Text(
          habit['description'] as String,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
        trailing: GestureDetector(
          onTap: () => _toggleHabitCompletion(index),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? Colors.green : Colors.grey[200],
              border: Border.all(
                color: isCompleted ? Colors.green : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.check,
              size: 16,
              color: isCompleted ? Colors.white : Colors.grey[400],
            ),
          ),
        ),
        onTap: () => _toggleHabitCompletion(index),
      ),
    );
  }

  void _toggleHabitCompletion(int index) {
    final nestedHabits = _nestedHabits;
    if (index >= 0 && index < nestedHabits.length) {
      // For demo purposes, just show feedback
      final habitName = nestedHabits[index]['name'] as String;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$habitName clicked! (Demo - real completion coming soon)'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _completeAllHabits() {
    setState(() {
      for (var habit in _demoNestedHabits) {
        habit['completed'] = true;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All nested habits completed! 🎉'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}