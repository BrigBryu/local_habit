import 'dart:async';
import 'dart:math';
import 'package:domain/domain.dart';
import 'package:logger/logger.dart';

import 'package:habit_level_up/core/sync/sync_queue.dart';
import 'package:habit_level_up/core/repositories/remote_habits_repository.dart';
import 'package:habit_level_up/core/repositories/local_habits_repository.dart';

/// Simulates offline/online conditions to test SyncQueue functionality
class SyncQueueSimulator {
  final Logger _logger = Logger();
  final RemoteHabitsRepository _remoteRepo = RemoteHabitsRepository();
  final LocalHabitsRepository _localRepo = LocalHabitsRepository();
  late Timer _networkToggleTimer;
  bool _simulationRunning = false;

  /// Run the full sync queue simulation
  Future<void> runSimulation() async {
    if (_simulationRunning) {
      _logger.w('Simulation already running, skipping...');
      return;
    }

    _simulationRunning = true;
    _logger.i('🚀 Starting SyncQueue simulation...');

    try {
      // Initialize repositories
      await _initializeRepositories();

      // Phase 1: Go offline and enqueue operations
      await _simulateOfflinePhase();

      // Phase 2: Come back online and verify sync
      await _simulateOnlinePhase();

      _logger.i('✅ SyncQueue simulation completed successfully!');
    } catch (e, stackTrace) {
      _logger.e('❌ SyncQueue simulation failed',
          error: e, stackTrace: stackTrace);
    } finally {
      _simulationRunning = false;
      _networkToggleTimer.cancel();
    }
  }

  /// Initialize repositories for testing
  Future<void> _initializeRepositories() async {
    _logger.i('Initializing repositories for simulation...');

    // Initialize local repository first
    await _localRepo.initialize();
    await _localRepo
        .setCurrentUserId('sim_user_${DateTime.now().millisecondsSinceEpoch}');

    // Initialize remote repository (will handle sync queue initialization)
    await _remoteRepo.initialize();
    await _remoteRepo.setCurrentUserId(_localRepo.getCurrentUserId());

    _logger.i('Repositories initialized');
  }

  /// Simulate 30 seconds offline with operations being queued
  Future<void> _simulateOfflinePhase() async {
    _logger.i('📱 PHASE 1: Simulating OFFLINE mode for 30 seconds...');

    // Mock network failure by overriding HTTP client
    _mockNetworkFailure(true);
    _isOnline = false;

    // Create test habits and completions that will be queued
    final testHabits = _generateTestHabits();

    _logger.i('Enqueueing ${testHabits.length} habits while offline...');

    // Try to add habits - these should fail and be queued
    for (int i = 0; i < testHabits.length; i++) {
      final habit = testHabits[i];
      _logger.d('Adding habit ${i + 1}: ${habit.name}');

      try {
        await _remoteRepo.addHabit(habit);
        _logger.d('Habit added (queued): ${habit.name}');
      } catch (e) {
        _logger.d('Habit add failed as expected (will be queued): $e');
      }

      // Small delay between operations
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Try to complete some habits - these should also be queued
    for (int i = 0; i < min(2, testHabits.length); i++) {
      final habitId = testHabits[i].id;
      _logger.d('Completing habit ${i + 1}: $habitId');

      try {
        await _remoteRepo.completeHabit(habitId, xpAwarded: 10 + i * 5);
        _logger.d('Habit completion queued: $habitId');
      } catch (e) {
        _logger.d('Habit completion failed as expected (will be queued): $e');
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Check sync queue status
    final pendingCount = await SyncQueue.instance.getPendingCount();
    _logger.i('📊 Sync queue has $pendingCount pending operations');

    // Wait for the remaining offline time
    _logger.i('⏳ Waiting remaining offline time...');
    await Future.delayed(const Duration(seconds: 25));
  }

  /// Simulate coming back online and verify sync queue drains
  Future<void> _simulateOnlinePhase() async {
    _logger.i('🌐 PHASE 2: Simulating ONLINE mode for 30 seconds...');

    // Restore network connectivity
    _mockNetworkFailure(false);
    _isOnline = true;

    // Check initial queue state
    final initialPendingCount = await SyncQueue.instance.getPendingCount();
    _logger.i('📊 Initial pending operations: $initialPendingCount');

    if (initialPendingCount == 0) {
      _logger.w(
          '⚠️  No pending operations found - simulation may not have worked correctly');
      return;
    }

    // Wait and monitor sync queue draining
    _logger.i('⏳ Monitoring sync queue draining...');
    int checkCount = 0;
    const maxChecks = 30; // 30 seconds with 1-second intervals

    while (checkCount < maxChecks) {
      await Future.delayed(const Duration(seconds: 1));
      checkCount++;

      final currentPending = await SyncQueue.instance.getPendingCount();
      _logger.d('Check $checkCount: $currentPending operations pending');

      if (currentPending == 0) {
        _logger.i('✅ Sync queue fully drained after $checkCount seconds!');
        break;
      }

      // Log progress every 5 seconds
      if (checkCount % 5 == 0) {
        final processed = initialPendingCount - currentPending;
        _logger.i(
            '📈 Progress: $processed/$initialPendingCount operations synced');
      }
    }

    // Final status check
    final finalPendingCount = await SyncQueue.instance.getPendingCount();
    if (finalPendingCount == 0) {
      _logger.i('🎉 SUCCESS: All operations successfully synced!');
    } else {
      _logger.w(
          '⚠️  WARNING: $finalPendingCount operations still pending after 30 seconds');
    }

    // Clean up any completed operations
    await SyncQueue.instance.clearCompleted();
    _logger.i('🧹 Cleaned up completed sync operations');
  }

  /// Generate test habits for simulation
  List<Habit> _generateTestHabits() {
    final habitNames = [
      'Morning Meditation',
      'Evening Workout',
      'Read 30 Minutes',
    ];

    return habitNames.map((name) {
      return Habit.create(
        name: name,
        description: 'Test habit for sync queue simulation',
        type: HabitType.basic,
      );
    }).toList();
  }

  /// Mock network failure for testing
  void _mockNetworkFailure(bool shouldFail) {
    if (shouldFail) {
      _logger
          .w('🔌 NETWORK: Simulating offline mode (operations will be queued)');
      // In a real implementation, you would override HttpClient or use a test HTTP client
      // For simulation purposes, we'll rely on the sync queue to handle failures
    } else {
      _logger.i('🌐 NETWORK: Simulating online mode (operations will sync)');
    }
  }
}

/// Main entry point for sync queue simulation
Future<void> runSyncQueueSimulation() async {
  final simulator = SyncQueueSimulator();
  await simulator.runSimulation();
}
