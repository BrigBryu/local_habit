import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/flexible_theme_system.dart';

class PartnerAvoidanceHabitTile extends ConsumerWidget {
  final Habit habit;

  const PartnerAvoidanceHabitTile({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            habit.avoidanceSuccessToday
                ? colors.completedBackground.withOpacity(0.6)
                : colors.draculaCurrentLine.withOpacity(0.4),
            habit.avoidanceSuccessToday
                ? colors.completedBackground.withOpacity(0.3)
                : colors.draculaCurrentLine.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: habit.avoidanceSuccessToday
              ? colors.completedBorder.withOpacity(0.6)
              : colors.avoidanceHabit.withOpacity(0.3),
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
                  color: colors.avoidanceHabit.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.avoidanceHabit.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.block,
                  color: colors.avoidanceHabit.withOpacity(0.8),
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
                        color: habit.avoidanceSuccessToday
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
                        color: habit.avoidanceSuccessToday
                            ? colors.completedTextOnGreen.withOpacity(0.7)
                            : colors.avoidanceHabit.withOpacity(0.8),
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
                    // Streak info
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: Colors.orange[600]?.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.currentStreak} day streak',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.draculaComment.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Read-only status indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: habit.avoidanceSuccessToday
                      ? colors.completed.withOpacity(0.8)
                      : colors.draculaCurrentLine.withOpacity(0.3),
                  border: Border.all(
                    color: habit.avoidanceSuccessToday
                        ? colors.completed.withOpacity(0.8)
                        : colors.draculaComment.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Icon(
                  habit.avoidanceSuccessToday
                      ? Icons.check
                      : Icons.radio_button_unchecked,
                  color: habit.avoidanceSuccessToday
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
    final failures = habit.dailyFailureCount;
    if (habit.avoidanceSuccessToday) {
      return 'Avoidance · Success today';
    } else if (failures > 0) {
      return 'Avoidance · $failures failure(s) today';
    }
    return 'Avoidance · In progress';
  }
}
