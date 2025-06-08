import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
// TODO(bridger): Timed habit service disabled
// import 'package:data_local/repositories/timed_habit_service.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/bundle_service.dart';

class HabitsNotifier extends StateNotifier<List<Habit>> {
  HabitsNotifier() : super([]);

  // TODO(bridger): Timed habit service disabled
  // final _timedHabitService = TimedHabitService();
  final _levelService = LevelService();
  final _bundleService = BundleService();

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
      
      final updatedBundle = _bundleService.addHabitToBundle(bundle, habitId, state);
      final updatedHabit = _bundleService.assignChildrenToBundle(bundleId, [habitId], state).first;
      
      updateHabit(updatedBundle);
      updateHabit(updatedHabit);
      
      return '${habit.name} added to ${bundle.name}';
    } catch (e) {
      return 'Failed to add habit: $e';
    }
  }

  List<Habit> getAvailableHabitsForBundle() {
    return _bundleService.getAvailableHabitsForBundle(state);
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