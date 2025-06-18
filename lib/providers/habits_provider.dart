import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/bundle_service.dart';
import 'package:data_local/repositories/stack_service.dart';
import 'package:logger/logger.dart';

import '../core/repositories/habits_repository.dart';
import '../core/repositories/simple_memory_repository.dart';
import '../core/network/partner_service.dart';
import '../core/services/stack_progress_service.dart';
import '../screens/partner_settings_screen.dart';
import 'repository_init_provider.dart';

// Stream provider for own habits
final ownHabitsProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(habitsRepositoryProvider);
  return repository.ownHabits();
});

// Immediate provider that bypasses streams for initial load
final immediateHabitsProvider = FutureProvider<List<Habit>>((ref) async {
  final repository = ref.watch(habitsRepositoryProvider);
  // For SimpleMemoryRepository, we can get data immediately
  if (repository is SimpleMemoryRepository) {
    return repository.habits; // Direct access to avoid stream delays
  }
  // Fallback to stream for other repositories
  return await repository.ownHabits().first;
});

// Super simplified stream provider for partner habits with autoDispose
final partnerHabitsProvider =
    StreamProvider.autoDispose<List<Habit>>((ref) async* {
  final repository = ref.watch(habitsRepositoryProvider);
  final logger = Logger();

  if (kDebugMode) {
    logger.d(
        '🚀 PartnerHabitsProvider: Starting simplified provider (autoDispose)');
  }

  // Always yield empty first to prevent infinite loading
  yield <Habit>[];
  if (kDebugMode) {
    logger.d(
        '✅ PartnerHabitsProvider: Yielded initial empty list to exit loading state');
  }

  // Add a small delay to ensure the UI updates with the empty state
  await Future.delayed(const Duration(milliseconds: 100));

  try {
    if (kDebugMode) {
      logger.d('🔄 PartnerHabitsProvider: Fetching relationships...');
    }

    // Get relationships with shorter timeout
    final relationships = await ref
        .read(partnerRelationshipsProvider.future)
        .timeout(const Duration(seconds: 3))
        .catchError((e) {
      if (kDebugMode) {
        logger.e('❌ PartnerHabitsProvider: Relationships failed: $e');
      }
      return <PartnerDto>[];
    });

    if (kDebugMode) {
      logger.d(
          '✅ PartnerHabitsProvider: Got ${relationships.length} relationships');
    }

    if (relationships.isEmpty) {
      if (kDebugMode) {
        logger.d('📭 PartnerHabitsProvider: No relationships found');
      }
      return; // Stay with empty list
    }

    // Try to get habits for the first partner only (simplify)
    final firstRelationship = relationships.first;
    if (firstRelationship.partnerId != null) {
      try {
        if (kDebugMode) {
          logger.d(
              '🔍 PartnerHabitsProvider: Fetching habits for ${firstRelationship.partnerUsername}...');
        }

        final partnerHabits = await repository
            .partnerHabits(firstRelationship.partnerId!)
            .first
            .timeout(const Duration(seconds: 3));

        if (kDebugMode) {
          logger.d(
              '📋 PartnerHabitsProvider: Found ${partnerHabits.length} habits');
        }

        // Yield the actual habits
        yield partnerHabits;
        if (kDebugMode) {
          logger.d(
              '✅ PartnerHabitsProvider: Successfully yielded ${partnerHabits.length} habits');
        }
      } catch (e) {
        if (kDebugMode) {
          logger.e('❌ PartnerHabitsProvider: Failed to get habits: $e');
        }
        // Stay with empty list
      }
    }
  } catch (e) {
    if (kDebugMode) {
      logger.e('❌ PartnerHabitsProvider: Top-level error: $e');
    }
    // No caching on error
  }
});

// Legacy habits provider that combines both streams for backward compatibility
final habitsProvider = Provider<AsyncValue<List<Habit>>>((ref) {
  return ref.watch(ownHabitsProvider);
});

// Notifier for habit operations
class HabitsNotifier extends StateNotifier<AsyncValue<void>> {
  HabitsNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  final HabitsRepository _repository;
  final Ref _ref;
  final _logger = Logger();

  // Business logic services (kept from original)
  final _bundleService = BundleService();
  final _stackService = StackService();

  Future<String?> addHabit(Habit habit) async {
    state = const AsyncValue.loading();
    try {
      final error = await _repository.addHabit(habit);

      // Invalidate providers to refresh UI
      _ref.invalidate(ownHabitsProvider);
      _ref.invalidate(partnerHabitsProvider);
      if (kDebugMode) {
        _logger.d('Invalidated habits providers after adding habit');
      }

      state = const AsyncValue.data(null);
      return error;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to add habit: $e';
    }
  }

  Future<String?> updateHabit(Habit habit) async {
    state = const AsyncValue.loading();
    try {
      final error = await _repository.updateHabit(habit);

      // Invalidate providers to refresh UI
      _ref.invalidate(ownHabitsProvider);
      _ref.invalidate(partnerHabitsProvider);
      if (kDebugMode) {
        _logger.d('Invalidated habits providers after updating habit');
      }

      state = const AsyncValue.data(null);
      return error;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to update habit: $e';
    }
  }

  Future<String?> removeHabit(String habitId) async {
    state = const AsyncValue.loading();
    try {
      final error = await _repository.removeHabit(habitId);

      // Invalidate providers to refresh UI
      _ref.invalidate(ownHabitsProvider);
      _ref.invalidate(partnerHabitsProvider);
      if (kDebugMode) {
        _logger.d('Invalidated habits providers after removing habit');
      }

      state = const AsyncValue.data(null);
      return error;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to remove habit: $e';
    }
  }

  Future<String?> completeHabit(String habitId) async {
    state = const AsyncValue.loading();
    try {
      // Get current habits to calculate XP
      final habitsAsync = _ref.read(ownHabitsProvider);
      if (habitsAsync.value == null) {
        return 'Failed to load habits for XP calculation';
      }

      final habits = habitsAsync.value!;
      final habit = habits.firstWhere(
        (h) => h.id == habitId,
        orElse: () => throw Exception('Habit not found'),
      );

      // Calculate XP using existing logic
      final baseXp = _calculateBaseXp(habit);
      final bonusXp = _calculateBonusXp(habit, habits);
      final totalXp = baseXp + bonusXp;

      // TODO: Implement awardXp method in LevelService
      // _levelService.awardXp(totalXp);

      // Mark habit as completed
      final updatedHabit = _markHabitCompleted(habit);
      await updateHabit(updatedHabit);

      // Record completion in database
      final error =
          await _repository.completeHabit(habitId, xpAwarded: totalXp);

      // Invalidate both own habits and partner habits to ensure UI updates
      _ref.invalidate(ownHabitsProvider);
      _ref.invalidate(partnerHabitsProvider);
      if (kDebugMode) {
        _logger.d(
            'Invalidated own habits and partner habits providers after habit completion');
      }

      state = const AsyncValue.data(null);
      _logger.i('Completed habit ${habit.name} for ${totalXp}XP');
      return error;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to complete habit: $e';
    }
  }

  // Bundle-related methods (adapted from original)
  Future<String?> addBundle(
      String name, String description, List<String> childIds) async {
    try {
      final habitsAsync = _ref.read(ownHabitsProvider);
      if (habitsAsync.value == null) return 'Failed to load habits';

      final bundle = _bundleService.createBundle(
        name: name,
        description: description,
        childIds: childIds,
        allHabits: habitsAsync.value!,
      );

      await addHabit(bundle);

      // Update child habits to reference the bundle
      final updatedChildren = _bundleService.assignChildrenToBundle(
          bundle.id, childIds, habitsAsync.value!);
      for (final child in updatedChildren) {
        await updateHabit(child);
      }

      // Final invalidation to ensure UI reflects the complete bundle creation
      _ref.invalidate(ownHabitsProvider);
      if (kDebugMode) {
        _logger.d('Final invalidation after bundle creation completed');
      }

      return null; // Success
    } catch (e) {
      return 'Failed to create bundle: $e';
    }
  }

  // Stack-related methods (new architecture)
  Future<String?> addStack(
      String name, String description, List<String> childIds) async {
    try {
      final habitsAsync = _ref.read(ownHabitsProvider);
      if (habitsAsync.value == null) return 'Failed to load habits';

      // Validate stack creation using StackProgressService
      final stackProgressService = StackProgressService();
      final validationError = stackProgressService.validateStackCreation(childIds, habitsAsync.value!);
      if (validationError != null) {
        return validationError;
      }

      // Create stack using new architecture
      final stack = Habit.create(
        name: name,
        description: description,
        type: HabitType.stack,
        stackChildIds: List.from(childIds),
        currentChildIndex: 0,
      );

      await addHabit(stack);

      // Update child habits to reference the stack with parentStackId
      for (final childId in childIds) {
        final child = habitsAsync.value!.firstWhere((h) => h.id == childId);
        final updatedChild = Habit(
          id: child.id,
          name: child.name,
          description: child.description,
          type: child.type,
          stackedOnHabitId: child.stackedOnHabitId,
          bundleChildIds: child.bundleChildIds,
          parentBundleId: child.parentBundleId,
          parentStackId: stack.id, // Set parent stack reference
          stackChildIds: child.stackChildIds,
          currentChildIndex: child.currentChildIndex,
          timeoutMinutes: child.timeoutMinutes,
          availableDays: child.availableDays,
          createdAt: child.createdAt,
          lastCompleted: child.lastCompleted,
          lastAlarmTriggered: child.lastAlarmTriggered,
          sessionStartTime: child.sessionStartTime,
          lastSessionStarted: child.lastSessionStarted,
          sessionCompletedToday: child.sessionCompletedToday,
          dailyCompletionCount: child.dailyCompletionCount,
          lastCompletionCountReset: child.lastCompletionCountReset,
          dailyFailureCount: child.dailyFailureCount,
          lastFailureCountReset: child.lastFailureCountReset,
          avoidanceSuccessToday: child.avoidanceSuccessToday,
          currentStreak: child.currentStreak,
        );
        await updateHabit(updatedChild);
      }

      return null; // Success
    } catch (e) {
      return 'Failed to create stack: $e';
    }
  }

  List<Habit> getAvailableHabitsForBundle() {
    final habitsAsync = _ref.read(ownHabitsProvider);
    if (habitsAsync.value == null) return [];
    return _bundleService.getAvailableHabitsForBundle(habitsAsync.value!);
  }

  List<Habit> getAvailableHabitsForStack() {
    final habitsAsync = _ref.read(ownHabitsProvider);
    if (habitsAsync.value == null) return [];
    return _stackService.getAvailableHabitsForStack(habitsAsync.value!);
  }

  // XP calculation helpers (from original implementation)
  int _calculateBaseXp(Habit habit) {
    switch (habit.type) {
      case HabitType.basic:
        return 10;
      case HabitType.avoidance:
        return 15;
      case HabitType.bundle:
        return 25;
      case HabitType.stack:
        return 20;
      default:
        return 10;
    }
  }

  int _calculateBonusXp(Habit habit, List<Habit> allHabits) {
    int bonus = 0;

    // Streak bonus
    final streakBonus = (habit.currentStreak / 7).floor() * 5;
    bonus += streakBonus;

    // Bundle combo bonus
    if (habit.parentBundleId != null) {
      final bundle = allHabits.firstWhere(
        (h) => h.id == habit.parentBundleId,
        orElse: () => habit,
      );

      if (bundle.type == HabitType.bundle) {
        // TODO: Implement getBundleChildrenCompletedToday method in BundleService
        final todayCompletions =
            <String>[]; // _bundleService.getBundleChildrenCompletedToday(bundle, allHabits);
        if (todayCompletions.length >= 2) {
          bonus += 10; // Combo bonus
        }
      }
    }

    return bonus;
  }

  Habit _markHabitCompleted(Habit habit) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Update completion tracking
    int newDailyCount = habit.dailyCompletionCount;
    DateTime? newLastReset = habit.lastCompletionCountReset;

    if (habit.lastCompletionCountReset == null ||
        DateTime(
                habit.lastCompletionCountReset!.year,
                habit.lastCompletionCountReset!.month,
                habit.lastCompletionCountReset!.day) !=
            today) {
      newDailyCount = 1;
      newLastReset = now;
    } else {
      newDailyCount++;
    }

    // Update streak
    int newStreak = habit.currentStreak;
    if (habit.lastCompleted == null ||
        DateTime(habit.lastCompleted!.year, habit.lastCompleted!.month,
                habit.lastCompleted!.day) !=
            today) {
      newStreak++;
    }

    return Habit(
      id: habit.id,
      name: habit.name,
      description: habit.description,
      type: habit.type,
      stackedOnHabitId: habit.stackedOnHabitId,
      bundleChildIds: habit.bundleChildIds,
      parentBundleId: habit.parentBundleId,
      parentStackId: habit.parentStackId,
      stackChildIds: habit.stackChildIds,
      currentChildIndex: habit.currentChildIndex,
      timeoutMinutes: habit.timeoutMinutes,
      availableDays: habit.availableDays,
      createdAt: habit.createdAt,
      lastCompleted: now,
      lastAlarmTriggered: habit.lastAlarmTriggered,
      sessionStartTime: habit.sessionStartTime,
      lastSessionStarted: habit.lastSessionStarted,
      sessionCompletedToday: true,
      dailyCompletionCount: newDailyCount,
      lastCompletionCountReset: newLastReset,
      dailyFailureCount: habit.dailyFailureCount,
      lastFailureCountReset: habit.lastFailureCountReset,
      avoidanceSuccessToday: habit.avoidanceSuccessToday,
      currentStreak: newStreak,
    );
  }

  Future<String?> recordFailure(String habitId) async {
    state = const AsyncValue.loading();
    try {
      final error = await _repository.recordFailure(habitId);
      state = const AsyncValue.data(null);
      return error;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to record failure: $e';
    }
  }

  Future<String?> completeBundle(String bundleId) async {
    state = const AsyncValue.loading();
    try {
      final habitsAsync = _ref.read(ownHabitsProvider);
      if (habitsAsync.value == null) {
        return 'Failed to load habits';
      }

      final allHabits = habitsAsync.value!;
      final bundle = allHabits.firstWhere(
        (h) => h.id == bundleId,
        orElse: () => throw Exception('Bundle not found'),
      );

      if (bundle.type != HabitType.bundle) {
        return 'Not a bundle habit';
      }

      // Complete all incomplete children using bundle service
      final result = _bundleService.completeBundle(bundle, allHabits);

      // Update all completed child habits
      for (final completedHabit in result.completedHabits) {
        await updateHabit(completedHabit);
      }

      // Mark the bundle itself as completed if all children are done
      if (_bundleService.isBundleCompleted(bundle, allHabits)) {
        final completedBundle = _markHabitCompleted(bundle);
        await updateHabit(completedBundle);
      }

      state = const AsyncValue.data(null);
      _logger.i(
          'Completed bundle ${bundle.name} with ${result.completedHabits.length} habits for ${result.totalXP}XP');
      return null; // Success
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to complete bundle: $e';
    }
  }

  Future<String?> addHabitToBundle(String bundleId, String habitId) async {
    state = const AsyncValue.loading();
    try {
      final habitsAsync = _ref.read(ownHabitsProvider);
      if (habitsAsync.value == null) {
        return 'Failed to load habits';
      }

      final allHabits = habitsAsync.value!;
      final bundle = allHabits.firstWhere(
        (h) => h.id == bundleId,
        orElse: () => throw Exception('Bundle not found'),
      );
      final habitToAdd = allHabits.firstWhere(
        (h) => h.id == habitId,
        orElse: () => throw Exception('Habit not found'),
      );

      if (bundle.type != HabitType.bundle) {
        return 'Not a bundle habit';
      }

      // Add habit to bundle using bundle service
      final updatedBundle =
          _bundleService.addHabitToBundle(bundle, habitId, allHabits);
      await updateHabit(updatedBundle);

      // Update the child habit to reference the bundle
      final updatedChild = Habit(
        id: habitToAdd.id,
        name: habitToAdd.name,
        description: habitToAdd.description,
        type: habitToAdd.type,
        stackedOnHabitId: habitToAdd.stackedOnHabitId,
        bundleChildIds: habitToAdd.bundleChildIds,
        parentBundleId: bundleId,
        parentStackId: habitToAdd.parentStackId,
        stackChildIds: habitToAdd.stackChildIds,
        currentChildIndex: habitToAdd.currentChildIndex,
        timeoutMinutes: habitToAdd.timeoutMinutes,
        availableDays: habitToAdd.availableDays,
        createdAt: habitToAdd.createdAt,
        lastCompleted: habitToAdd.lastCompleted,
        lastAlarmTriggered: habitToAdd.lastAlarmTriggered,
        sessionStartTime: habitToAdd.sessionStartTime,
        lastSessionStarted: habitToAdd.lastSessionStarted,
        sessionCompletedToday: habitToAdd.sessionCompletedToday,
        dailyCompletionCount: habitToAdd.dailyCompletionCount,
        lastCompletionCountReset: habitToAdd.lastCompletionCountReset,
        dailyFailureCount: habitToAdd.dailyFailureCount,
        lastFailureCountReset: habitToAdd.lastFailureCountReset,
        avoidanceSuccessToday: habitToAdd.avoidanceSuccessToday,
        currentStreak: habitToAdd.currentStreak,
      );
      await updateHabit(updatedChild);

      // Final invalidation to ensure UI reflects the updated bundle
      _ref.invalidate(ownHabitsProvider);
      if (kDebugMode) {
        _logger.d('Final invalidation after adding habit to bundle');
      }

      state = const AsyncValue.data(null);
      _logger.i('Added habit ${habitToAdd.name} to bundle ${bundle.name}');
      return null; // Success
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to add habit to bundle: $e';
    }
  }

  /// Complete the current stack child and advance to next step
  Future<String?> completeStackChild(String stackId) async {
    state = const AsyncValue.loading();
    try {
      final habitsAsync = _ref.read(ownHabitsProvider);
      if (habitsAsync.value == null) {
        return 'Failed to load habits';
      }

      final allHabits = habitsAsync.value!;
      final stack = allHabits.firstWhere(
        (h) => h.id == stackId,
        orElse: () => throw Exception('Stack not found'),
      );

      if (stack.type != HabitType.stack) {
        return 'Not a stack habit';
      }

      final stackProgressService = StackProgressService();
      final currentChild = stackProgressService.getCurrentChild(stack, allHabits);
      
      if (currentChild == null) {
        return 'No current child to complete';
      }

      // Complete the current child habit first
      final childCompletionResult = await completeHabit(currentChild.id);
      if (childCompletionResult != null) {
        return childCompletionResult; // Child completion failed
      }

      // Get updated habits list after child completion
      final updatedHabitsAsync = _ref.read(ownHabitsProvider);
      if (updatedHabitsAsync.value == null) {
        return 'Failed to reload habits after child completion';
      }
      final updatedAllHabits = updatedHabitsAsync.value!;
      final updatedStack = updatedAllHabits.firstWhere((h) => h.id == stackId);

      // Advance to next child
      final newIndex = updatedStack.currentChildIndex + 1;
      final isStackComplete = newIndex >= (updatedStack.stackChildIds?.length ?? 0);
      
      // Award bonus XP if stack is complete
      if (isStackComplete) {
        // TODO: Award +1 XP bonus through level service
        _logger.i('Stack completed! Awarding +1 XP bonus');
      }

      // Update stack with new index (reset to 0 if complete for next day)
      final updatedStackWithIndex = Habit(
        id: updatedStack.id,
        name: updatedStack.name,
        description: updatedStack.description,
        type: updatedStack.type,
        stackedOnHabitId: updatedStack.stackedOnHabitId,
        bundleChildIds: updatedStack.bundleChildIds,
        parentBundleId: updatedStack.parentBundleId,
        parentStackId: updatedStack.parentStackId,
        stackChildIds: updatedStack.stackChildIds,
        currentChildIndex: isStackComplete ? 0 : newIndex, // Reset or advance
        timeoutMinutes: updatedStack.timeoutMinutes,
        availableDays: updatedStack.availableDays,
        createdAt: updatedStack.createdAt,
        lastCompleted: isStackComplete ? DateTime.now() : updatedStack.lastCompleted,
        lastAlarmTriggered: updatedStack.lastAlarmTriggered,
        sessionStartTime: updatedStack.sessionStartTime,
        lastSessionStarted: updatedStack.lastSessionStarted,
        sessionCompletedToday: updatedStack.sessionCompletedToday,
        dailyCompletionCount: updatedStack.dailyCompletionCount,
        lastCompletionCountReset: updatedStack.lastCompletionCountReset,
        dailyFailureCount: updatedStack.dailyFailureCount,
        lastFailureCountReset: updatedStack.lastFailureCountReset,
        avoidanceSuccessToday: updatedStack.avoidanceSuccessToday,
        currentStreak: updatedStack.currentStreak,
      );

      await updateHabit(updatedStackWithIndex);

      state = const AsyncValue.data(null);
      _logger.i('Stack child completed and index advanced for stack ${stack.name}');
      return null; // Success
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return 'Failed to complete stack child: $e';
    }
  }
}

final habitsNotifierProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(habitsRepositoryProvider);
  return HabitsNotifier(repository, ref);
});

// Repository initialization is now handled by repository_init_provider.dart
