import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:domain/domain.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

import 'sync_database.dart';
import '../repositories/remote_habits_repository.dart';

part 'sync_queue.g.dart';

const int kSyncQueuePurgeThreshold = 25000;

/// Sync operation stored in Isar for offline queue
@Collection()
class SyncOp {
  Id id = Isar.autoIncrement;

  late String
      operationType; // 'addHabit', 'updateHabit', 'removeHabit', 'completeHabit', 'recordFailure'
  late String habitId;
  String? habitData; // JSON serialized habit data for add/update operations
  int xpAwarded = 0; // For completion operations
  late DateTime createdAt;
  DateTime? lastAttempt;
  int attemptCount = 0;
  int maxRetries = 5;
  bool completed = false;
  String? errorMessage;

  SyncOp();

  /// Create sync operation for adding a habit
  SyncOp.addHabit(Habit habit) {
    operationType = 'addHabit';
    habitId = habit.id;
    habitData = jsonEncode(habit.toJson());
    createdAt = DateTime.now();
  }

  /// Create sync operation for updating a habit
  SyncOp.updateHabit(Habit habit) {
    operationType = 'updateHabit';
    habitId = habit.id;
    habitData = jsonEncode(habit.toJson());
    createdAt = DateTime.now();
  }

  /// Create sync operation for removing a habit
  SyncOp.removeHabit(String id) {
    operationType = 'removeHabit';
    habitId = id;
    createdAt = DateTime.now();
  }

  /// Create sync operation for completing a habit
  SyncOp.completeHabit(String id, int xp) {
    operationType = 'completeHabit';
    habitId = id;
    xpAwarded = xp;
    createdAt = DateTime.now();
  }

  /// Create sync operation for recording failure
  SyncOp.recordFailure(String id) {
    operationType = 'recordFailure';
    habitId = id;
    createdAt = DateTime.now();
  }
}

/// Service for managing offline sync queue with exponential backoff retry
class SyncQueue {
  static SyncQueue? _instance;
  static SyncQueue get instance => _instance ??= SyncQueue._();

  SyncQueue._();

  final Logger _logger = Logger();
  final SyncDatabase _db = SyncDatabase.instance;
  Timer? _retryTimer;

  /// Initialize sync queue and start processing
  Future<void> initialize(RemoteHabitsRepository repository) async {
    try {
      _repository = repository;
      await _db.initialize();
      await _purgeStaleOperations();
      await _startProcessing();
      _logger.i('SyncQueue initialized');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize sync queue',
          error: e, stackTrace: stackTrace);
      // Don't rethrow - allow app to continue without sync
      _logger.w('Continuing without sync queue functionality');
    }
  }

  RemoteHabitsRepository? _repository;

  /// Add operation to sync queue
  Future<void> enqueue(SyncOp operation) async {
    // COMPLETELY DISABLED: Skip all sync operations for clean Stack testing
    _logger.d('SKIPPED sync operation: ${operation.operationType} for habit ${operation.habitId} (sync completely disabled)');
    return;
  }

  /// Start background processing of sync queue
  Future<void> _startProcessing() async {
    // COMPLETELY DISABLED: No background processing during Stack testing
    _logger.d('Background sync processing disabled for clean testing');
    return;
  }

  /// Process pending operations with memory-efficient pagination
  Future<void> _processQueue() async {
    if (_repository == null) return;

    try {
      // Get total count first without loading all objects
      final totalPending =
          await _db.isar.syncOps.filter().completedEqualTo(false).count();

      if (totalPending == 0) {
        _logger.i('SyncQueue: No pending operations');
        return;
      }

      _logger.d('Processing $totalPending pending sync operations (paginated)');

      // Process in small pages to prevent memory exhaustion
      const pageSize = 20;
      int processed = 0;
      int offset = 0;

      while (offset < totalPending) {
        // Fetch only a small page of operations
        final pageOps = await _db.isar.syncOps
            .filter()
            .completedEqualTo(false)
            .offset(offset)
            .limit(pageSize)
            .findAll();

        if (pageOps.isEmpty) break;

        // Process this page
        for (final op in pageOps) {
          await _processOperation(op);
          processed++;

          // Yield control after every operation to prevent blocking
          if (processed % 5 == 0) {
            await Future.delayed(const Duration(milliseconds: 5));
          }
        }

        offset += pageSize;

        // Log progress and yield control
        if (processed % 50 == 0) {
          _logger.d('Processed $processed/$totalPending operations');
          await Future.delayed(const Duration(milliseconds: 20));
        }

        // Safety break if we've processed too many
        if (processed > 1000) {
          _logger
              .w('Processed 1000 operations, pausing to prevent memory issues');
          break;
        }
      }

      // Log final count
      final finalCount = await getPendingCount();
      _logger.i(
          'SyncQueue: Processed $processed operations, $finalCount remaining');
    } catch (e, stackTrace) {
      _logger.e('Error processing sync queue',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Process a single sync operation
  Future<void> _processOperation(SyncOp op) async {
    if (_repository == null || op.attemptCount >= op.maxRetries) {
      if (op.attemptCount >= op.maxRetries) {
        _logger.w(
            'Max retries exceeded for operation: ${op.operationType} ${op.habitId}');
        await _markOperationFailed(op, 'Max retries exceeded');
      }
      return;
    }

    // Calculate exponential backoff delay with max 300 seconds (5 minutes)
    final retrySec = min(300, 2 << op.attemptCount);
    final nextAttemptTime =
        (op.lastAttempt ?? op.createdAt).add(Duration(seconds: retrySec));

    if (DateTime.now().isBefore(nextAttemptTime)) {
      return; // Too early to retry
    }

    try {
      op.lastAttempt = DateTime.now();
      op.attemptCount++;

      String? result;

      switch (op.operationType) {
        case 'addHabit':
          if (op.habitData != null) {
            final habitJson = jsonDecode(op.habitData!);
            final habit = Habit.fromJson(habitJson);
            result = await _repository!.addHabit(habit);
          }
          break;

        case 'updateHabit':
          if (op.habitData != null) {
            final habitJson = jsonDecode(op.habitData!);
            final habit = Habit.fromJson(habitJson);
            result = await _repository!.updateHabit(habit);
          }
          break;

        case 'removeHabit':
          result = await _repository!.removeHabit(op.habitId);
          break;

        case 'completeHabit':
          result = await _repository!
              .completeHabit(op.habitId, xpAwarded: op.xpAwarded);
          break;

        case 'recordFailure':
          result = await _repository!.recordFailure(op.habitId);
          break;

        default:
          result = 'Unknown operation type: ${op.operationType}';
      }

      if (result == null) {
        // Success
        await _markOperationCompleted(op);
        _logger.d(
            'Successfully synced operation: ${op.operationType} ${op.habitId}');
      } else {
        // Error returned
        op.errorMessage = result;
        await _updateOperation(op);
        _logger.w(
            'Sync operation failed: ${op.operationType} ${op.habitId} - $result');
      }
    } catch (e, stackTrace) {
      op.errorMessage = e.toString();
      await _updateOperation(op);
      _logger.e(
          'Error processing sync operation: ${op.operationType} ${op.habitId}',
          error: e,
          stackTrace: stackTrace);
    }
  }

  /// Mark operation as completed and remove from queue
  Future<void> _markOperationCompleted(SyncOp op) async {
    await _db.isar.writeTxn(() async {
      await _db.isar.syncOps.delete(op.id);
    });
  }

  /// Mark operation as permanently failed
  Future<void> _markOperationFailed(SyncOp op, String error) async {
    op.completed = true;
    op.errorMessage = error;
    await _updateOperation(op);
  }

  /// Update operation in database
  Future<void> _updateOperation(SyncOp op) async {
    await _db.isar.writeTxn(() async {
      await _db.isar.syncOps.put(op);
    });
  }

  /// Get pending operations count for debugging
  Future<int> getPendingCount() async {
    return await _db.isar.syncOps.filter().completedEqualTo(false).count();
  }

  /// Clear all completed/failed operations from queue
  Future<void> clearCompleted() async {
    await _db.isar.writeTxn(() async {
      final completedIds = await _db.isar.syncOps
          .filter()
          .completedEqualTo(true)
          .idProperty()
          .findAll();

      await _db.isar.syncOps.deleteAll(completedIds);
    });

    _logger.i('Cleared completed sync operations');
  }

  /// Purge stale operations on startup
  Future<void> _purgeStaleOperations() async {
    try {
      final totalCount = await _db.isar.syncOps.count();
      final failedCount =
          await _db.isar.syncOps.filter().attemptCountGreaterThan(5).count();

      _logger.i(
          'SyncQueue startup: Total ops: $totalCount, High-retry ops: $failedCount');

      // If we have more than threshold pending operations, purge them
      if (totalCount > kSyncQueuePurgeThreshold) {
        await _db.isar.writeTxn(() async {
          await _db.isar.syncOps.clear();
        });
        _logger.w(
            'Purged all sync operations due to excessive queue size: $totalCount');
        return;
      }

      // If we have operations that failed more than 5 times, purge them
      if (failedCount > 0) {
        await _db.isar.writeTxn(() async {
          final staleIds = await _db.isar.syncOps
              .filter()
              .attemptCountGreaterThan(5)
              .idProperty()
              .findAll();

          await _db.isar.syncOps.deleteAll(staleIds);
        });
        _logger.w('Purged $failedCount high-retry sync operations');
      }
    } catch (e, stackTrace) {
      _logger.e('Error purging stale operations',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Dispose sync queue
  void dispose() {
    _retryTimer?.cancel();
    _logger.i('SyncQueue disposed');
  }
}
