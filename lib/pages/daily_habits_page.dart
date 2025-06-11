import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habits_provider.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/timed_habit_service_disabled.dart';
import '../features/habits/bundle_habit/index.dart';
import '../features/habits/avoidance_habit/index.dart';
import '../features/habits/stack_habit/index.dart';
import '../features/habits/stack_habit/add_stack_habit_screen.dart';
import '../core/theme/theme_extensions.dart';
import '../core/theme/app_colors.dart';

class DailyHabitsPage extends ConsumerWidget {
  const DailyHabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHabitsAsync = ref.watch(ownHabitsProvider);
    
    return allHabitsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading habits: $error'),
            ],
          ),
        ),
      ),
      data: (allHabits) {
        // Filter to show only top-level habits (not children of bundles or stacks)
        final topLevelHabits = allHabits.where((habit) => 
          habit.parentBundleId == null && habit.stackedOnHabitId == null
        ).toList();

        return _buildHabitsScaffold(context, ref, topLevelHabits, allHabits);
      },
    );
  }

  Widget _buildHabitsScaffold(BuildContext context, WidgetRef ref, List<Habit> topLevelHabits, List<Habit> allHabits) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Habits'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: topLevelHabits.isEmpty
          ? Center(
              child: Text(
                'No habits yet!\nTap the + button to add your first habit.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : ListView.builder(
              itemCount: topLevelHabits.length,
              itemBuilder: (context, index) {
                final habit = topLevelHabits[index];
                
                switch (habit.type) {
                  case HabitType.bundle:
                    return BundleHabitTile(habit: habit, allHabits: allHabits);
                  case HabitType.stack:
                    return StackHabitTile(habit: habit, allHabits: allHabits);
                  case HabitType.avoidance:
                    return AvoidanceHabitTile(habit: habit);
                  case HabitType.basic:
                  default:
                    return IndividualHabitCard(habit: habit);
                }
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "stack",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddStackHabitScreen(),
                ),
              );
            },
            tooltip: 'Create Stack',
            backgroundColor: AppColors.completedBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.stackHabit.withOpacity(0.3), width: 1),
            ),
            child: Icon(Icons.layers, color: AppColors.stackHabit),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "bundle",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddBundleHabitScreen(),
                ),
              );
            },
            tooltip: 'Create Bundle',
            backgroundColor: AppColors.completedBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.primaryPurple.withOpacity(0.3), width: 1),
            ),
            child: Icon(Icons.folder, color: AppColors.primaryPurple),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "sample",
            backgroundColor: AppColors.completedBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.primaryPurple.withOpacity(0.3), width: 1),
            ),
            onPressed: () {
              // Add some sample habits for testing
              final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
              
              // Add a basic habit
              habitsNotifier.addHabit(Habit.create(
                name: 'Read 30 minutes',
                description: 'Daily reading habit',
                type: HabitType.basic,
              ));
              
              // TODO: Re-enable when time-based habits are supported
              // habitsNotifier.addHabit(Habit.create(
              //   name: 'Meditation',
              //   description: '10 minute meditation session',
              //   type: HabitType.timedSession,
              //   timeoutMinutes: 10,
              // ));
              // 
              // habitsNotifier.addHabit(Habit.create(
              //   name: 'Morning Workout',
              //   description: 'Exercise during morning hours',
              //   type: HabitType.dailyTimeWindow,
              //   windowStartTime: const TimeOfDay(hour: 6, minute: 0),
              //   windowEndTime: const TimeOfDay(hour: 10, minute: 0),
              // ));
              
              // Add an avoidance habit
              habitsNotifier.addHabit(Habit.create(
                name: 'No Social Media',
                description: 'Avoid mindless scrolling',
                type: HabitType.avoidance,
              ));
              
              // Add individual habits that will be bundled
              final bedHabit = Habit.create(
                name: 'Make Bed',
                description: 'Make your bed each morning',
                type: HabitType.basic,
              );
              final waterHabit = Habit.create(
                name: 'Drink Water',
                description: 'Drink a glass of water',
                type: HabitType.basic,
              );
              final stretchHabit = Habit.create(
                name: 'Stretch',
                description: '5 minute stretch',
                type: HabitType.basic,
              );
              
              habitsNotifier.addHabit(bedHabit);
              habitsNotifier.addHabit(waterHabit);
              habitsNotifier.addHabit(stretchHabit);
              
              // Create a bundle with these habits
              habitsNotifier.addBundle(
                'Morning Routine',
                'Complete your morning routine',
                [bedHabit.id, waterHabit.id, stretchHabit.id],
              );
            },
            tooltip: 'Add Sample Habits',
            child: Icon(Icons.add, color: AppColors.primaryPurple),
          ),
        ],
      ),
    );
  }
}

/// Individual habit card for standalone habits (not in bundles)
class IndividualHabitCard extends ConsumerWidget {
  final Habit habit;
  
  const IndividualHabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: HabitListTile(habit: habit),
    );
  }
}

/// Internal habit list tile widget (reusable for both individual and nested habits)
class HabitListTile extends ConsumerWidget {
  final Habit habit;
  final bool isNested;
  final EdgeInsets? padding;
  
  const HabitListTile({
    super.key, 
    required this.habit,
    this.isNested = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timedHabitService = TimedHabitService();
    final isCompleted = _isHabitCompletedToday(habit);
    
    return Container(
      padding: padding ?? (isNested ? const EdgeInsets.only(left: 16) : EdgeInsets.zero),
      decoration: isNested ? BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 3,
          ),
        ),
      ) : null,
      child: ListTile(
        contentPadding: isNested 
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
          : null,
        title: Text(
          habit.displayName,
          style: TextStyle(
            fontSize: isNested ? 14 : 16,
            fontWeight: isNested ? FontWeight.normal : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _getSubtitle(timedHabitService),
          style: TextStyle(
            fontSize: isNested ? 12 : 14,
          ),
        ),
        trailing: _buildTrailingIcon(context, ref, timedHabitService, isCompleted),
        onTap: habit.type == HabitType.avoidance ? null : () => _handleTap(context, ref, timedHabitService),
      ),
    );
  }

  String _getSubtitle(TimedHabitService timedHabitService) {
    // TODO: Re-enable when time-based habits are supported
    // if (habit.type == HabitType.timedSession ||
    //     habit.type == HabitType.timeWindow ||
    //     habit.type == HabitType.dailyTimeWindow ||
    //     habit.type == HabitType.alarmHabit) {
    //   return timedHabitService.getTimedHabitStatus(habit);
    // }
    
    // For basic habits, show completion count if > 0
    if (habit.type == HabitType.basic && habit.dailyCompletionCount > 0) {
      final count = habit.dailyCompletionCount;
      final nextXP = habit.calculateXPReward();
      return 'Completed ${count}x today • Next: +${nextXP} XP';
    }
    
    // For avoidance habits, show status
    if (habit.type == HabitType.avoidance) {
      if (habit.avoidanceSuccessToday) {
        return 'Successfully avoided today!';
      } else if (habit.dailyFailureCount > 0) {
        return 'Failed ${habit.dailyFailureCount}x today';
      } else {
        return 'Tap ✅ if avoided, ❌ if failed';
      }
    }
    
    return habit.description;
  }

  Widget _buildTrailingIcon(BuildContext context, WidgetRef ref, 
      TimedHabitService timedHabitService, bool isCompleted) {
    
    switch (habit.type) {
      case HabitType.avoidance:
        return AvoidanceHabitButtons(habit: habit, ref: ref);
      
      case HabitType.basic:
      default:
        return BasicHabitCheckButton(habit: habit, ref: ref);
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

  Future<void> _handleTap(BuildContext context, WidgetRef ref, TimedHabitService timedHabitService) async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    
    if (_isHabitCompletedToday(habit)) {
      return; // Already completed
    }

    // TODO: Re-enable when time-based habits are supported
    // switch (habit.type) {
    //   case HabitType.timedSession:
    //     if (!habit.hasStartedSessionToday()) {
    //       // Start the timer
    //       final result = habitsNotifier.startTimedSession(habit.id);
    //       if (result != null) {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(content: Text('Timer started for ${habit.name}!')),
    //         );
    //       } else {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           const SnackBar(content: Text('Timer already started today')),
    //         );
    //       }
    //     } else if (habit.sessionCompletedToday) {
    //       // Check off the completed session
    //       final result = habitsNotifier.completeHabit(habit.id);
    //       if (result != null) {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(content: Text(result)),
    //         );
    //       } else {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(content: Text('${habit.name} completed!')),
    //         );
    //       }
    //     } else {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('Timer still running or not completed')),
    //       );
    //     }
    //     break;
    //   
    //   case HabitType.timeWindow:
    //   case HabitType.dailyTimeWindow:
    //     final validationError = timedHabitService.validateTimeWindowCompletion(habit);
    //     if (validationError != null) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text(validationError)),
    //       );
    //     } else {
    //       final result = habitsNotifier.completeHabit(habit.id);
    //       if (result != null) {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(content: Text(result)),
    //         );
    //       } else {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(content: Text('${habit.name} completed!')),
    //         );
    //       }
    //     }
    //     break;
    //   
    //   default:
        final result = await habitsNotifier.completeHabit(habit.id);
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${habit.name} completed!')),
          );
        }
    // }
  }
}

/// Simple checkmark button for basic habits with clean aesthetic
class BasicHabitCheckButton extends ConsumerWidget {
  final Habit habit;
  final WidgetRef ref;

  const BasicHabitCheckButton({super.key, required this.habit, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = _isHabitCompletedToday(habit);
    final completionColors = Theme.of(context).completionColors;
    
    return GestureDetector(
      onTap: isCompleted ? null : () => _completeHabit(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? completionColors.completed : completionColors.incompleteBackground,
          border: Border.all(
            color: isCompleted ? completionColors.completedBorder : completionColors.incompleteBorder,
            width: 2,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isCompleted
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 24,
                key: ValueKey('completed'),
              )
            : Icon(
                Icons.circle_outlined,
                color: completionColors.incomplete,
                size: 24,
                key: const ValueKey('incomplete'),
              ),
        ),
      ),
    );
  }

  bool _isHabitCompletedToday(Habit habit) {
    if (habit.lastCompleted == null) return false;
    final now = DateTime.now();
    final lastCompleted = habit.lastCompleted!;
    return now.year == lastCompleted.year &&
           now.month == lastCompleted.month &&
           now.day == lastCompleted.day;
  }

  Future<void> _completeHabit(BuildContext context) async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result = await habitsNotifier.completeHabit(habit.id);
    final completionColors = Theme.of(context).completionColors;
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: completionColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${habit.name} completed! +${habit.calculateXPReward()} XP'),
          backgroundColor: completionColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class AvoidanceHabitButtons extends ConsumerWidget {
  final Habit habit;
  final WidgetRef ref;

  const AvoidanceHabitButtons({super.key, required this.habit, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (habit.avoidanceSuccessToday) {
      final completionColors = Theme.of(context).completionColors;
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: completionColors.success,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 24),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Failure button
        GestureDetector(
          onTap: () => _recordFailure(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).completionColors.errorBackground.withOpacity(0.3),
              border: Border.all(color: Theme.of(context).completionColors.error, width: 2),
            ),
            child: Icon(Icons.close, color: Theme.of(context).completionColors.error, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        // Success button
        GestureDetector(
          onTap: () => _markSuccess(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).completionColors.successBackground.withOpacity(0.3),
              border: Border.all(color: Theme.of(context).completionColors.success, width: 2),
            ),
            child: Icon(Icons.check, color: Theme.of(context).completionColors.success, size: 20),
          ),
        ),
      ],
    );
  }

  void _recordFailure(BuildContext context) {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    // TODO: Implement recordFailure method in new provider
    final result = 'Failure recording not implemented yet';
    final completionColors = Theme.of(context).completionColors;
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: completionColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _markSuccess(BuildContext context) async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final result = await habitsNotifier.completeHabit(habit.id);
    final completionColors = Theme.of(context).completionColors;
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: completionColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${habit.name} avoided successfully!'),
          backgroundColor: completionColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}