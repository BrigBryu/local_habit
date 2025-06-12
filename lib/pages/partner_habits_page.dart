import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';

import '../providers/habits_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/flexible_theme_system.dart';

class PartnerHabitsPage extends ConsumerWidget {
  const PartnerHabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partnerHabitsAsync = ref.watch(partnerHabitsProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: partnerHabitsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load partner habits',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (partnerHabits) {
          // Filter to show only top-level habits (not children of bundles or stacks)
          final topLevelHabits = partnerHabits.where((habit) => 
            habit.parentBundleId == null && habit.stackedOnHabitId == null
          ).toList();

          if (topLevelHabits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppColors.draculaComment.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Partner Connected',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.draculaComment.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect with a partner to see their habits here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.draculaComment.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to partner connection screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Partner connection feature coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Connect Partner'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.completedBackground,
                      foregroundColor: AppColors.draculaForeground,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: topLevelHabits.length,
            itemBuilder: (context, index) {
              final habit = topLevelHabits[index];
              
              // Create read-only habit tiles
              switch (habit.type) {
                case HabitType.bundle:
                  return PartnerBundleHabitTile(habit: habit, allHabits: partnerHabits);
                case HabitType.stack:
                  return PartnerStackHabitTile(habit: habit, allHabits: partnerHabits);
                case HabitType.avoidance:
                  return PartnerAvoidanceHabitTile(habit: habit);
                case HabitType.basic:
                default:
                  return PartnerHabitTile(habit: habit); // Use partner version based on the proper tiles
              }
            },
          );
        },
      ),
    );
  }
}

// Read-only habit tile widgets for partner habits

/// Partner version of HabitTile - read-only and styled to match the proper tiles
class PartnerHabitTile extends ConsumerWidget {
  final Habit habit;

  const PartnerHabitTile({
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
              ? colors.completedBackground.withOpacity(0.6) // Dimmer for partner
              : colors.draculaCurrentLine.withOpacity(0.4),
            isCompleted 
              ? colors.completedBackground.withOpacity(0.3) // Dimmer for partner
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
                  color: _getHabitTypeColor(ref).withOpacity(0.1), // Dimmer for partner
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getHabitTypeColor(ref).withOpacity(0.2), // Dimmer for partner
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getHabitTypeIcon(),
                  color: _getHabitTypeColor(ref).withOpacity(0.8), // Dimmer for partner
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
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? colors.completedTextOnGreen.withOpacity(0.8) : colors.draculaPurple.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildSubtitleText(ref),
                      style: TextStyle(
                        color: isCompleted ? colors.completedTextOnGreen.withOpacity(0.7) : colors.basicHabit.withOpacity(0.8),
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

  String _buildSubtitleText(WidgetRef ref) {
    final colors = ref.watchColors;
    switch (habit.type) {
      case HabitType.basic:
        final count = _isHabitCompletedToday(habit) ? habit.dailyCompletionCount : 0;
        if (count > 0) {
          return 'Basic Habit · $count completed today';
        }
        return 'Basic Habit';
        
      case HabitType.avoidance:
        final failures = habit.dailyFailureCount;
        if (habit.avoidanceSuccessToday) {
          return 'Avoidance · Success today';
        } else if (failures > 0) {
          return 'Avoidance · $failures failure(s) today';
        }
        return 'Avoidance · In progress';
        
      case HabitType.bundle:
        final childCount = habit.bundleChildIds?.length ?? 0;
        return 'Bundle · $childCount habits';
        
      case HabitType.stack:
        return 'Habit Stack';
    }
  }

  Color _getHabitTypeColor(WidgetRef ref) {
    final colors = ref.watchColors;
    switch (habit.type) {
      case HabitType.basic:
        return colors.basicHabit;
      case HabitType.avoidance:
        return colors.avoidanceHabit;
      case HabitType.bundle:
        return colors.bundleHabit;
      case HabitType.stack:
        return colors.stackHabit;
    }
  }
  
  IconData _getHabitTypeIcon() {
    switch (habit.type) {
      case HabitType.basic:
        return Icons.check_circle_outline;
      case HabitType.avoidance:
        return Icons.block;
      case HabitType.bundle:
        return Icons.folder_special;
      case HabitType.stack:
        return Icons.layers;
    }
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

class PartnerAvoidanceHabitTile extends StatelessWidget {
  final Habit habit;

  const PartnerAvoidanceHabitTile({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.avoidanceHabit.withOpacity(0.2),
          child: Icon(
            Icons.block,
            color: AppColors.avoidanceHabit,
          ),
        ),
        title: Text(
          habit.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (habit.description.isNotEmpty) ...[
              Text(habit.description),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: Colors.orange[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${habit.currentStreak} day streak',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: habit.avoidanceSuccessToday
            ? Icon(
                Icons.check_circle,
                color: AppColors.completedBackground,
                size: 28,
              )
            : Icon(
                Icons.radio_button_unchecked,
                color: AppColors.draculaComment.withOpacity(0.3),
                size: 28,
              ),
      ),
    );
  }
}

class PartnerBundleHabitTile extends StatelessWidget {
  final Habit habit;
  final List<Habit> allHabits;

  const PartnerBundleHabitTile({
    super.key,
    required this.habit,
    required this.allHabits,
  });

  @override
  Widget build(BuildContext context) {
    final childHabits = habit.bundleChildIds
        ?.map((id) => allHabits.where((h) => h.id == id).firstOrNull)
        .where((h) => h != null)
        .cast<Habit>()
        .toList() ?? [];

    final completedCount = childHabits.where((h) => h.sessionCompletedToday).length;
    final totalCount = childHabits.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.bundleHabit.withOpacity(0.2),
          child: Icon(
            Icons.category,
            color: AppColors.bundleHabit,
          ),
        ),
        title: Text(
          habit.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (habit.description.isNotEmpty) ...[
              Text(habit.description),
              const SizedBox(height: 4),
            ],
            Text(
              '$completedCount of $totalCount completed',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: CircularProgressIndicator(
          value: totalCount > 0 ? completedCount / totalCount : 0,
          backgroundColor: AppColors.draculaComment.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation(AppColors.bundleHabit),
        ),
        children: childHabits.map((child) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: PartnerHabitTile(habit: child),
          );
        }).toList(),
      ),
    );
  }
}

class PartnerStackHabitTile extends StatelessWidget {
  final Habit habit;
  final List<Habit> allHabits;

  const PartnerStackHabitTile({
    super.key,
    required this.habit,
    required this.allHabits,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implement proper stack step retrieval
    final stackSteps = allHabits
        .where((h) => h.stackedOnHabitId == habit.id)
        .toList();

    final completedCount = stackSteps.where((h) => h.sessionCompletedToday).length;
    final totalCount = stackSteps.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.stackHabit.withOpacity(0.2),
          child: Icon(
            Icons.layers,
            color: AppColors.stackHabit,
          ),
        ),
        title: Text(
          habit.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (habit.description.isNotEmpty) ...[
              Text(habit.description),
              const SizedBox(height: 4),
            ],
            Text(
              'Step ${completedCount + 1} of $totalCount',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: CircularProgressIndicator(
          value: totalCount > 0 ? completedCount / totalCount : 0,
          backgroundColor: AppColors.draculaComment.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation(AppColors.stackHabit),
        ),
        children: stackSteps.map((step) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: PartnerHabitTile(habit: step),
          );
        }).toList(),
      ),
    );
  }
}