import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/flexible_theme_system.dart';

class DayDetailBottomSheet extends ConsumerWidget {
  final DateTime date;
  final String? habitFilter;

  const DayDetailBottomSheet({
    super.key,
    required this.date,
    this.habitFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.6,
      decoration: BoxDecoration(
        color: colors.draculaBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.draculaComment,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: colors.primaryPurple,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(date),
                        style: TextStyle(
                          color: colors.draculaForeground,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (habitFilter != null)
                        Text(
                          'Filtered: $habitFilter',
                          style: TextStyle(
                            color: colors.draculaComment,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: colors.draculaComment,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 1,
            color: colors.draculaCurrentLine,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // My habits section
                  _buildSection(
                    context,
                    ref,
                    'Me',
                    _getMyHabitsForDate(date, habitFilter),
                    colors.primaryPurple,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Partner habits section
                  _buildSection(
                    context,
                    ref,
                    'Partner',
                    _getPartnerHabitsForDate(date, habitFilter),
                    colors.purpleAccent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<HabitDetail> habits,
    Color accentColor,
  ) {
    final colors = ref.watchColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: accentColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                title == 'Me' ? Icons.person : Icons.people,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${habits.length} habits',
                style: TextStyle(
                  color: colors.draculaComment,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Habits list
        if (habits.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.draculaCurrentLine.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.draculaCurrentLine,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                'No habits for this day',
                style: TextStyle(
                  color: colors.draculaComment,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ...habits.map((habit) => _buildHabitItem(context, ref, habit)),
      ],
    );
  }

  Widget _buildHabitItem(BuildContext context, WidgetRef ref, HabitDetail habit) {
    final colors = ref.watchColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: habit.isCompleted
            ? colors.completedBackground.withOpacity(0.1)
            : colors.draculaCurrentLine.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: habit.isCompleted
              ? colors.completedBorder.withOpacity(0.5)
              : colors.draculaCurrentLine,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Habit icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: habit.typeColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: habit.typeColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              habit.icon ?? Icons.task_alt,
              color: habit.typeColor,
              size: 18,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Habit details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: TextStyle(
                    color: habit.isCompleted
                        ? colors.completedTextOnGreen
                        : colors.draculaForeground,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: habit.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (habit.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    habit.description,
                    style: TextStyle(
                      color: colors.draculaComment,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Completion status
          Icon(
            habit.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: habit.isCompleted ? colors.completed : colors.draculaComment,
            size: 20,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    final dayName = days[date.weekday - 1];
    final month = months[date.month - 1];
    
    return '$dayName • $month ${date.day}';
  }

  List<HabitDetail> _getMyHabitsForDate(DateTime date, String? habitFilter) {
    // Mock data - replace with actual data provider
    final allHabits = [
      HabitDetail(
        id: '1',
        name: 'Morning Exercise',
        description: '30 minutes workout',
        isCompleted: true,
        typeColor: const Color(0xFF8BE9FD),
        icon: Icons.fitness_center,
      ),
      HabitDetail(
        id: '2',
        name: 'Read Book',
        description: '20 pages minimum',
        isCompleted: date.day % 2 == 0,
        typeColor: const Color(0xFFBD93F9),
        icon: Icons.book,
      ),
      HabitDetail(
        id: '3',
        name: 'Drink Water',
        description: '8 glasses',
        isCompleted: true,
        typeColor: const Color(0xFF50FA7B),
        icon: Icons.local_drink,
      ),
    ];

    if (habitFilter != null && habitFilter != 'All Habits') {
      return allHabits.where((h) => h.name.contains(habitFilter)).toList();
    }
    return allHabits;
  }

  List<HabitDetail> _getPartnerHabitsForDate(DateTime date, String? habitFilter) {
    // Mock data - replace with actual data provider
    final allHabits = [
      HabitDetail(
        id: '4',
        name: 'Meditation',
        description: '15 minutes daily',
        isCompleted: date.day % 3 == 0,
        typeColor: const Color(0xFFFF79C6),
        icon: Icons.self_improvement,
      ),
      HabitDetail(
        id: '5',
        name: 'No Social Media',
        description: 'Before 6 PM',
        isCompleted: true,
        typeColor: const Color(0xFFFF5555),
        icon: Icons.block,
      ),
    ];

    if (habitFilter != null && habitFilter != 'All Habits') {
      return allHabits.where((h) => h.name.contains(habitFilter)).toList();
    }
    return allHabits;
  }
}

class HabitDetail {
  final String id;
  final String name;
  final String description;
  final bool isCompleted;
  final Color typeColor;
  final IconData? icon;

  const HabitDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.isCompleted,
    required this.typeColor,
    this.icon,
  });
}

// Helper function to show the bottom sheet
void showDayDetailBottomSheet(
  BuildContext context, {
  required DateTime date,
  String? habitFilter,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DayDetailBottomSheet(
      date: date,
      habitFilter: habitFilter,
    ),
  );
}