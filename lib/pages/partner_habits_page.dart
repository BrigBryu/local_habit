import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';

import '../providers/habits_provider.dart';
import '../features/habits/bundle_habit/index.dart';
import '../features/habits/avoidance_habit/index.dart';
import '../features/habits/stack_habit/index.dart';
import '../core/theme/theme_extensions.dart';
import '../core/theme/app_colors.dart';

class PartnerHabitsPage extends ConsumerWidget {
  const PartnerHabitsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partnerHabitsAsync = ref.watch(partnerHabitsProvider);
    
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
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
                    color: AppColors.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Partner Connected',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect with a partner to see their habits here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface.withOpacity(0.6),
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
                      foregroundColor: AppColors.onPrimary,
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
                  return PartnerBasicHabitTile(habit: habit);
              }
            },
          );
        },
      ),
    );
  }
}

// Read-only habit tile widgets for partner habits

class PartnerBasicHabitTile extends StatelessWidget {
  final Habit habit;

  const PartnerBasicHabitTile({
    Key? key,
    required this.habit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.completedBackground.withOpacity(0.2),
          child: Icon(
            Icons.task_alt,
            color: AppColors.completedBackground,
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
                const SizedBox(width: 16),
                Icon(
                  Icons.today,
                  size: 16,
                  color: AppColors.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${habit.dailyCompletionCount} today',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: habit.sessionCompletedToday
            ? Icon(
                Icons.check_circle,
                color: AppColors.completedBackground,
                size: 28,
              )
            : Icon(
                Icons.radio_button_unchecked,
                color: AppColors.onSurface.withOpacity(0.3),
                size: 28,
              ),
      ),
    );
  }
}

class PartnerAvoidanceHabitTile extends StatelessWidget {
  final Habit habit;

  const PartnerAvoidanceHabitTile({
    Key? key,
    required this.habit,
  }) : super(key: key);

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
                color: AppColors.onSurface.withOpacity(0.3),
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
    Key? key,
    required this.habit,
    required this.allHabits,
  }) : super(key: key);

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
          backgroundColor: AppColors.onSurface.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation(AppColors.bundleHabit),
        ),
        children: childHabits.map((child) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: PartnerBasicHabitTile(habit: child),
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
    Key? key,
    required this.habit,
    required this.allHabits,
  }) : super(key: key);

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
          backgroundColor: AppColors.onSurface.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation(AppColors.stackHabit),
        ),
        children: stackSteps.map((step) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: PartnerBasicHabitTile(habit: step),
          );
        }).toList(),
      ),
    );
  }
}