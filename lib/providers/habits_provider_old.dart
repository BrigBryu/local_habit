import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
// TODO(bridger): Timed habit service disabled
// import 'package:data_local/repositories/timed_habit_service.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/bundle_service.dart';
import 'package:data_local/repositories/stack_service.dart';

class HabitsNotifier extends StateNotifier<List<Habit>> {
  HabitsNotifier() : super([]) {
    // Add test habits for development
    _addTestHabits();
  }

  // TODO(bridger): Timed habit service disabled
  // final _timedHabitService = TimedHabitService();
  final _levelService = LevelService();
  final _bundleService = BundleService();
  final _stackService = StackService();

  void addHabit(Habit habit) {
    state = [...state, habit];
  }

  void updateHabit(Habit updatedHabit) {
    state = state.map((habit) => 
      habit.id == updatedHabit.id ? updatedHabit : habit
    ).toList();
  }

  void removeHabit(String habitId) {
    // Remove the habit itself
    state = state.where((habit) => habit.id != habitId).toList();
    
    // Clean up any bundles that reference this habit
    final updatedBundles = <Habit>[];
    for (final habit in state) {
      if (habit.type == HabitType.bundle && 
          habit.bundleChildIds != null && 
          habit.bundleChildIds!.contains(habitId)) {
        
        // Remove the deleted habit from bundle's child list
        final updatedChildIds = habit.bundleChildIds!
            .where((id) => id != habitId)
            .toList();
            
        // If bundle has less than 2 children after removal, delete the bundle too
        if (updatedChildIds.length < 2) {
          // Bundle becomes invalid, remove it entirely
          continue;
        }
        
        // Update bundle with remaining children
        final updatedBundle = Habit(
          id: habit.id,
          name: habit.name,
          description: habit.description,
          type: habit.type,
          stackedOnHabitId: habit.stackedOnHabitId,
          bundleChildIds: updatedChildIds,
          parentBundleId: habit.parentBundleId,
          // TODO(bridger): TimeOfDay fields disabled
          // alarmTime: habit.alarmTime,
          timeoutMinutes: habit.timeoutMinutes,
          // windowStartTime: habit.windowStartTime,
          // windowEndTime: habit.windowEndTime,
          availableDays: habit.availableDays,
          createdAt: habit.createdAt,
          lastCompleted: habit.lastCompleted,
          lastAlarmTriggered: habit.lastAlarmTriggered,
          sessionStartTime: habit.sessionStartTime,
          lastSessionStarted: habit.lastSessionStarted,
          sessionCompletedToday: habit.sessionCompletedToday,
          dailyCompletionCount: habit.dailyCompletionCount,
          lastCompletionCountReset: habit.lastCompletionCountReset,
          dailyFailureCount: habit.dailyFailureCount,
          lastFailureCountReset: habit.lastFailureCountReset,
          avoidanceSuccessToday: habit.avoidanceSuccessToday,
          currentStreak: habit.currentStreak,
        );
        updatedBundles.add(updatedBundle);
      }
    }
    
    // Apply bundle updates
    for (final updatedBundle in updatedBundles) {
      updateHabit(updatedBundle);
    }
    
    // Remove any bundles that became invalid (less than 2 children)
    state = state.where((habit) => 
      habit.type != HabitType.bundle || 
      (habit.bundleChildIds?.length ?? 0) >= 2
    ).toList();

    // Clean up any stacks that had this habit as a step
    // If a stack loses all its steps, it becomes empty but stays valid
    for (final habit in state) {
      if (habit.type == HabitType.stack) {
        final steps = _stackService.getStackSteps(habit, state);
        if (steps.any((step) => step.id == habitId)) {
          // This stack contained the removed habit, but we don't need to do anything
          // The step will simply not be found in future stack operations
        }
      }
    }
  }

  // TODO(bridger): Start timed session disabled (timed habits disabled)
  // Habit? startTimedSession(String habitId) {
  //   final habit = state.firstWhere((h) => h.id == habitId);
  //   final updatedHabit = _timedHabitService.startSession(habit);
  //   if (updatedHabit != null) {
  //     updateHabit(updatedHabit);
  //   }
  //   return updatedHabit;
  // }

  String? recordFailure(String habitId) {
    final habit = state.firstWhere((h) => h.id == habitId);
    
    if (habit.type != HabitType.avoidance) {
      return 'Only avoidance habits can record failures';
    }

    final failedHabit = habit.recordFailure();
    updateHabit(failedHabit);
    
    final count = failedHabit.dailyFailureCount;
    return '${habit.name} failed ${count}x today. Streak broken.';
  }

  String? completeHabit(String habitId) {
    final habit = state.firstWhere((h) => h.id == habitId);
    
    // TODO(bridger): Time window validation disabled (timed habits disabled)
    // Validate time window completion if applicable
    // final validationError = _timedHabitService.validateTimeWindowCompletion(habit);
    // if (validationError != null) {
    //   print('❌ Cannot complete habit: $validationError');
    //   return validationError;
    // }

    final completedHabit = habit.complete();
    final xpReward = completedHabit.calculateXPReward();
    
    // Add XP with streak bonus for first completion of the day
    var totalXP = xpReward;
    if ((habit.type == HabitType.basic && completedHabit.dailyCompletionCount == 1) ||
        (habit.type == HabitType.avoidance && !habit.avoidanceSuccessToday)) {
      // Add streak bonus for first completion
      if (completedHabit.currentStreak >= 3) {
        totalXP += (completedHabit.currentStreak / 3).floor();
      }
    }
    
    final leveledUp = _levelService.addXP(totalXP, source: '${habit.name} completion');
    updateHabit(completedHabit);
    
    // Return success message with completion count for basic habits
    if (habit.type == HabitType.basic) {
      final count = completedHabit.dailyCompletionCount;
      final xpText = totalXP > 0 ? ' (+${totalXP} XP)' : '';
      if (count == 1) {
        return '${habit.name} completed!$xpText${leveledUp ? ' 🎉 LEVEL UP!' : ''}';
      } else {
        return '${habit.name} completed ${count}x today!$xpText${leveledUp ? ' 🎉 LEVEL UP!' : ''}';
      }
    } else if (habit.type == HabitType.avoidance) {
      final xpText = totalXP > 0 ? ' (+${totalXP} XP)' : '';
      if (completedHabit.dailyFailureCount == 0) {
        return '${habit.name} avoided successfully!$xpText${leveledUp ? ' 🎉 LEVEL UP!' : ''}';
      } else {
        return '${habit.name} marked as successful despite ${completedHabit.dailyFailureCount} failure(s)$xpText${leveledUp ? ' 🎉 LEVEL UP!' : ''}';
      }
    }
    
    return null; // Success, no specific message
  }

  String? completeBundle(String bundleId) {
    final bundle = state.firstWhere((h) => h.id == bundleId);
    
    if (bundle.type != HabitType.bundle) {
      return 'Not a bundle habit';
    }

    final result = _bundleService.completeBundle(bundle, state);
    
    if (result.completedHabits.isEmpty) {
      return 'All habits in bundle already completed';
    }

    // Update all completed children
    for (final completedChild in result.completedHabits) {
      updateHabit(completedChild);
    }

    // Award XP with combo bonus
    if (result.totalXP > 0) {
      String xpBreakdown = '';
      if (result.comboBonus > 0) {
        final baseXP = result.totalXP - result.comboBonus;
        xpBreakdown = ' (+${baseXP} XP + ${result.comboBonus} combo bonus)';
      } else {
        xpBreakdown = ' (+${result.totalXP} XP)';
      }
      
      final leveledUp = _levelService.addXP(result.totalXP, source: '${bundle.name} bundle completion');
      return 'Bundle completed! ${result.completedHabits.length} habits done$xpBreakdown${leveledUp ? ' 🎉 LEVEL UP!' : ''}';
    }

    return 'Bundle completed! ${result.completedHabits.length} habits done';
  }

  void addBundle(String name, String description, List<String> childIds) {
    try {
      final bundle = _bundleService.createBundle(
        name: name,
        description: description,
        childIds: childIds,
        allHabits: state,
      );
      
      // Add the bundle
      print('Creating bundle: ${bundle.name}, type: ${bundle.type}, children: ${bundle.bundleChildIds}'); // Debug
      addHabit(bundle);
      
      // Update child habits to reference the bundle
      final updatedChildren = _bundleService.assignChildrenToBundle(bundle.id, childIds, state);
      for (final updatedChild in updatedChildren) {
        updateHabit(updatedChild);
      }
      print('Bundle created successfully'); // Debug
    } catch (e) {
      throw Exception('Failed to create bundle: $e');
    }
  }

  String? addHabitToBundle(String bundleId, String habitId) {
    try {
      final bundle = state.firstWhere((h) => h.id == bundleId);
      final habit = state.firstWhere((h) => h.id == habitId);
      
      // If habit is already in a bundle, remove it from the old bundle first
      if (habit.parentBundleId != null && habit.parentBundleId != bundleId) {
        final oldBundle = state.firstWhere((h) => h.id == habit.parentBundleId);
        final updatedOldBundleChildIds = oldBundle.bundleChildIds!
            .where((id) => id != habitId)
            .toList();
        
        if (updatedOldBundleChildIds.length < 2) {
          // Old bundle becomes invalid, remove it entirely
          removeHabit(oldBundle.id);
        } else {
          // Update old bundle with remaining children
          final updatedOldBundle = Habit(
            id: oldBundle.id,
            name: oldBundle.name,
            description: oldBundle.description,
            type: oldBundle.type,
            stackedOnHabitId: oldBundle.stackedOnHabitId,
            bundleChildIds: updatedOldBundleChildIds,
            parentBundleId: oldBundle.parentBundleId,
            timeoutMinutes: oldBundle.timeoutMinutes,
            availableDays: oldBundle.availableDays,
            createdAt: oldBundle.createdAt,
            lastCompleted: oldBundle.lastCompleted,
            lastAlarmTriggered: oldBundle.lastAlarmTriggered,
            sessionStartTime: oldBundle.sessionStartTime,
            lastSessionStarted: oldBundle.lastSessionStarted,
            sessionCompletedToday: oldBundle.sessionCompletedToday,
            dailyCompletionCount: oldBundle.dailyCompletionCount,
            lastCompletionCountReset: oldBundle.lastCompletionCountReset,
            dailyFailureCount: oldBundle.dailyFailureCount,
            lastFailureCountReset: oldBundle.lastFailureCountReset,
            avoidanceSuccessToday: oldBundle.avoidanceSuccessToday,
            currentStreak: oldBundle.currentStreak,
          );
          updateHabit(updatedOldBundle);
        }
      }
      
      // Add to new bundle
      final currentChildIds = bundle.bundleChildIds ?? [];
      if (!currentChildIds.contains(habitId)) {
        final updatedBundle = Habit(
          id: bundle.id,
          name: bundle.name,
          description: bundle.description,
          type: bundle.type,
          stackedOnHabitId: bundle.stackedOnHabitId,
          bundleChildIds: [...currentChildIds, habitId],
          parentBundleId: bundle.parentBundleId,
          timeoutMinutes: bundle.timeoutMinutes,
          availableDays: bundle.availableDays,
          createdAt: bundle.createdAt,
          lastCompleted: bundle.lastCompleted,
          lastAlarmTriggered: bundle.lastAlarmTriggered,
          sessionStartTime: bundle.sessionStartTime,
          lastSessionStarted: bundle.lastSessionStarted,
          sessionCompletedToday: bundle.sessionCompletedToday,
          dailyCompletionCount: bundle.dailyCompletionCount,
          lastCompletionCountReset: bundle.lastCompletionCountReset,
          dailyFailureCount: bundle.dailyFailureCount,
          lastFailureCountReset: bundle.lastFailureCountReset,
          avoidanceSuccessToday: bundle.avoidanceSuccessToday,
          currentStreak: bundle.currentStreak,
        );
        updateHabit(updatedBundle);
      }
      
      // Update habit to reference new bundle
      final updatedHabit = Habit(
        id: habit.id,
        name: habit.name,
        description: habit.description,
        type: habit.type,
        stackedOnHabitId: habit.stackedOnHabitId,
        bundleChildIds: habit.bundleChildIds,
        parentBundleId: bundleId,
        timeoutMinutes: habit.timeoutMinutes,
        availableDays: habit.availableDays,
        createdAt: habit.createdAt,
        lastCompleted: habit.lastCompleted,
        lastAlarmTriggered: habit.lastAlarmTriggered,
        sessionStartTime: habit.sessionStartTime,
        lastSessionStarted: habit.lastSessionStarted,
        sessionCompletedToday: habit.sessionCompletedToday,
        dailyCompletionCount: habit.dailyCompletionCount,
        lastCompletionCountReset: habit.lastCompletionCountReset,
        dailyFailureCount: habit.dailyFailureCount,
        lastFailureCountReset: habit.lastFailureCountReset,
        avoidanceSuccessToday: habit.avoidanceSuccessToday,
        currentStreak: habit.currentStreak,
      );
      updateHabit(updatedHabit);
      
      if (habit.parentBundleId != null && habit.parentBundleId != bundleId) {
        return '${habit.name} moved to ${bundle.name}';
      } else {
        return '${habit.name} added to ${bundle.name}';
      }
    } catch (e) {
      return 'Failed to add habit: $e';
    }
  }

  List<Habit> getAvailableHabitsForBundle() {
    // Return all non-bundle habits, allowing moving between bundles
    return state.where((habit) => habit.type != HabitType.bundle).toList();
  }

  // Stack-related methods
  String? addStack(String name, String description, List<String> stepIds) {
    try {
      final stack = _stackService.createStack(
        name: name,
        description: description,
        stepIds: stepIds,
        allHabits: state,
      );
      
      // Add the stack
      addHabit(stack);
      
      // Update step habits to reference the stack
      final updatedSteps = _stackService.assignStepsToStack(stack.id, stepIds, state);
      for (final updatedStep in updatedSteps) {
        updateHabit(updatedStep);
      }
      
      return null; // Success
    } catch (e) {
      return 'Failed to create stack: $e';
    }
  }

  String? addHabitToStack(String stackId, String habitId) {
    try {
      final stack = state.firstWhere((h) => h.id == stackId);
      final habit = state.firstWhere((h) => h.id == habitId);
      
      // Remove from any existing stack or bundle
      if (habit.stackedOnHabitId != null && habit.stackedOnHabitId != stackId) {
        _removeFromStack(habit.stackedOnHabitId!, habitId);
      }
      
      if (habit.parentBundleId != null) {
        _removeFromBundle(habit.parentBundleId!, habitId);
      }
      
      // Update habit to reference the stack
      final updatedHabit = Habit(
        id: habit.id,
        name: habit.name,
        description: habit.description,
        type: habit.type,
        stackedOnHabitId: stackId,
        bundleChildIds: habit.bundleChildIds,
        parentBundleId: null, // Remove bundle reference
        timeoutMinutes: habit.timeoutMinutes,
        availableDays: habit.availableDays,
        createdAt: habit.createdAt,
        lastCompleted: habit.lastCompleted,
        lastAlarmTriggered: habit.lastAlarmTriggered,
        sessionStartTime: habit.sessionStartTime,
        lastSessionStarted: habit.lastSessionStarted,
        sessionCompletedToday: habit.sessionCompletedToday,
        dailyCompletionCount: habit.dailyCompletionCount,
        lastCompletionCountReset: habit.lastCompletionCountReset,
        dailyFailureCount: habit.dailyFailureCount,
        lastFailureCountReset: habit.lastFailureCountReset,
        avoidanceSuccessToday: habit.avoidanceSuccessToday,
        currentStreak: habit.currentStreak,
      );
      updateHabit(updatedHabit);
      
      return '${habit.name} added to ${stack.name}';
    } catch (e) {
      return 'Failed to add habit to stack: $e';
    }
  }

  void _removeFromStack(String stackId, String habitId) {
    // Remove habit from stack - for now, just update the habit
    final habit = state.firstWhere((h) => h.id == habitId);
    final updatedHabit = Habit(
      id: habit.id,
      name: habit.name,
      description: habit.description,
      type: habit.type,
      stackedOnHabitId: null,
      bundleChildIds: habit.bundleChildIds,
      parentBundleId: habit.parentBundleId,
      timeoutMinutes: habit.timeoutMinutes,
      availableDays: habit.availableDays,
      createdAt: habit.createdAt,
      lastCompleted: habit.lastCompleted,
      lastAlarmTriggered: habit.lastAlarmTriggered,
      sessionStartTime: habit.sessionStartTime,
      lastSessionStarted: habit.lastSessionStarted,
      sessionCompletedToday: habit.sessionCompletedToday,
      dailyCompletionCount: habit.dailyCompletionCount,
      lastCompletionCountReset: habit.lastCompletionCountReset,
      dailyFailureCount: habit.dailyFailureCount,
      lastFailureCountReset: habit.lastFailureCountReset,
      avoidanceSuccessToday: habit.avoidanceSuccessToday,
      currentStreak: habit.currentStreak,
    );
    updateHabit(updatedHabit);
  }

  void _removeFromBundle(String bundleId, String habitId) {
    final bundle = state.firstWhere((h) => h.id == bundleId);
    final updatedChildIds = bundle.bundleChildIds!
        .where((id) => id != habitId)
        .toList();
    
    if (updatedChildIds.length < 2) {
      // Bundle becomes invalid, remove it entirely
      removeHabit(bundleId);
    } else {
      // Update bundle with remaining children
      final updatedBundle = Habit(
        id: bundle.id,
        name: bundle.name,
        description: bundle.description,
        type: bundle.type,
        stackedOnHabitId: bundle.stackedOnHabitId,
        bundleChildIds: updatedChildIds,
        parentBundleId: bundle.parentBundleId,
        timeoutMinutes: bundle.timeoutMinutes,
        availableDays: bundle.availableDays,
        createdAt: bundle.createdAt,
        lastCompleted: bundle.lastCompleted,
        lastAlarmTriggered: bundle.lastAlarmTriggered,
        sessionStartTime: bundle.sessionStartTime,
        lastSessionStarted: bundle.lastSessionStarted,
        sessionCompletedToday: bundle.sessionCompletedToday,
        dailyCompletionCount: bundle.dailyCompletionCount,
        lastCompletionCountReset: bundle.lastCompletionCountReset,
        dailyFailureCount: bundle.dailyFailureCount,
        lastFailureCountReset: bundle.lastFailureCountReset,
        avoidanceSuccessToday: bundle.avoidanceSuccessToday,
        currentStreak: bundle.currentStreak,
      );
      updateHabit(updatedBundle);
    }
  }

  List<Habit> getAvailableHabitsForStack() {
    return _stackService.getAvailableHabitsForStack(state);
  }

  void _addTestHabits() {
    // Add test habits for development
    final habit1 = Habit(
      id: 'test_habit_1',
      name: 'habit1',
      description: '',
      type: HabitType.basic,
      createdAt: DateTime.now(),
    );
    
    final habit2 = Habit(
      id: 'test_habit_2', 
      name: 'habit2',
      description: '',
      type: HabitType.basic,
      createdAt: DateTime.now(),
    );

    // Add 3 more habits for the bundle
    final habit3 = Habit(
      id: 'test_habit_3',
      name: 'Morning Exercise',
      description: '10 push-ups',
      type: HabitType.basic,
      createdAt: DateTime.now(),
      parentBundleId: 'test_bundle_1',
    );

    final habit4 = Habit(
      id: 'test_habit_4',
      name: 'Drink Water',
      description: 'Glass of water',
      type: HabitType.basic,
      createdAt: DateTime.now(),
      parentBundleId: 'test_bundle_1',
    );

    final habit5 = Habit(
      id: 'test_habit_5',
      name: 'Read',
      description: '5 minutes reading',
      type: HabitType.basic,
      createdAt: DateTime.now(),
      parentBundleId: 'test_bundle_1',
    );

    // Create a test bundle
    final testBundle = Habit(
      id: 'test_bundle_1',
      name: 'Morning Routine',
      description: 'Start the day right',
      type: HabitType.bundle,
      bundleChildIds: ['test_habit_3', 'test_habit_4', 'test_habit_5'],
      createdAt: DateTime.now(),
    );
    
    state = [habit1, habit2, habit3, habit4, habit5, testBundle];
  }

  // TODO(bridger): Update timed habits disabled (timed habits disabled)
  // void updateTimedHabits() {
  //   final updatedHabits = _timedHabitService.updateAllTimedHabits(state);
  //   for (final updatedHabit in updatedHabits) {
  //     updateHabit(updatedHabit);
  //   }
  // }
}

final habitsProvider = StateNotifierProvider<HabitsNotifier, List<Habit>>((ref) {
  return HabitsNotifier();
});