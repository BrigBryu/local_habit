import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';

import '../providers/habits_provider.dart';
import '../screens/partner_settings_screen.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/flexible_theme_system.dart';
import '../features/habits/basic_habit/partner_basic_habit_tile.dart';
import '../features/habits/bundle_habit/partner_bundle_habit_tile.dart';
import '../features/habits/stack_habit/partner_stack_habit_tile.dart';
import '../features/habits/avoidance_habit/partner_avoidance_habit_tile.dart';

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
          final topLevelHabits = partnerHabits
              .where((habit) =>
                  habit.parentBundleId == null &&
                  habit.stackedOnHabitId == null)
              .toList();

          if (topLevelHabits.isEmpty) {
            // Check if we have any partner relationships to distinguish between
            // "no partner" vs "partner with no habits"
            final relationshipsAsync = ref.watch(partnerRelationshipsProvider);

            return relationshipsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
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
                        Navigator.of(context).pushNamed('/partner-settings');
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
              ),
              data: (relationships) {
                if (relationships.isEmpty) {
                  // No partner relationships
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
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color:
                                    AppColors.draculaComment.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connect with a partner to see their habits here',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color:
                                    AppColors.draculaComment.withOpacity(0.6),
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed('/partner-settings');
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
                } else {
                  // Partner connected but no habits yet
                  final partnerUsernames =
                      relationships.map((r) => r.partnerUsername).join(', ');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: AppColors.draculaComment.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Habits Yet',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color:
                                    AppColors.draculaComment.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your partner ($partnerUsernames) hasn\'t created any habits yet',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color:
                                    AppColors.draculaComment.withOpacity(0.6),
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'When they create habits, they\'ll appear here automatically!',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.draculaPurple.withOpacity(0.8),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
              },
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
                  return PartnerBundleHabitTile(
                      habit: habit, allHabits: partnerHabits);
                case HabitType.stack:
                  return PartnerStackHabitTile(
                      habit: habit, allHabits: partnerHabits);
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
