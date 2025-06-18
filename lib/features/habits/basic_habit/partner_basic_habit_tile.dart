import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../core/theme/flexible_theme_system.dart';

/// Partner version of HabitTile - read-only and styled to match the proper tiles
class PartnerBasicHabitTile extends ConsumerWidget {
  final Habit habit;

  const PartnerBasicHabitTile({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = _isHabitCompletedToday(habit);
    final colors = ref.watchColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            isCompleted
                ? colors.completedBackground
                    .withOpacity(0.6) // Dimmer for partner
                : colors.draculaCurrentLine.withOpacity(0.4),
            isCompleted
                ? colors.completedBackground
                    .withOpacity(0.3) // Dimmer for partner
                : colors.draculaCurrentLine.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isCompleted
              ? colors.completedBorder.withOpacity(0.6) // Dimmer for partner
              : colors.basicHabit.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Habit type icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      colors.basicHabit.withOpacity(0.1), // Dimmer for partner
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.basicHabit
                        .withOpacity(0.2), // Dimmer for partner
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color:
                      colors.basicHabit.withOpacity(0.8), // Dimmer for partner
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Habit info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: colors.draculaComment.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Partner\'s Habit',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.draculaComment.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      habit.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? colors.completedTextOnGreen.withOpacity(0.8)
                            : colors.draculaPurple.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildSubtitleText(),
                      style: TextStyle(
                        color: isCompleted
                            ? colors.completedTextOnGreen.withOpacity(0.7)
                            : colors.basicHabit.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (habit.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        habit.description,
                        style: TextStyle(
                          color: colors.draculaComment.withOpacity(0.7),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Read-only status indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? colors.completed.withOpacity(0.8)
                      : colors.draculaCurrentLine.withOpacity(0.3),
                  border: Border.all(
                    color: isCompleted
                        ? colors.completed.withOpacity(0.8)
                        : colors.draculaComment.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.radio_button_unchecked,
                  color: isCompleted
                      ? Colors.white
                      : colors.draculaComment.withOpacity(0.6),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildSubtitleText() {
    final count =
        _isHabitCompletedToday(habit) ? habit.dailyCompletionCount : 0;
    if (count > 0) {
      return 'Basic Habit · $count completed today';
    }
    return 'Basic Habit';
  }

  bool _isHabitCompletedToday(Habit habit) {
    if (habit.lastCompleted == null) return false;
    final now = DateTime.now();
    final lastCompleted = habit.lastCompleted!;
    return now.year == lastCompleted.year &&
        now.month == lastCompleted.month &&
        now.day == lastCompleted.day;
  }
}
