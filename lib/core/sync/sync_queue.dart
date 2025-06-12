import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:domain/domain.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

import 'sync_database.dart';
import '../repositories/remote_habits_repository.dart';

part 'sync_queue.g.dart';

/// Sync operation stored in Isar for offline queue
@Collection()
class SyncOp {
  Id id = Isar.autoIncrement;
  
  late String operationType; // 'addHabit', 'updateHabit', 'removeHabit', 'completeHabit', 'recordFailure'
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
    _repository = repository;
    await _db.initialize();
    await _startProcessing();
    _logger.i('SyncQueue initialized');
  }
  
  RemoteHabitsRepository? _repository;
  
  /// Add operation to sync queue
  Future<void> enqueue(SyncOp operation) async {
    try {
      await _db.isar.writeTxn(() async {
        await _db.isar.syncOps.put(operation);
      });
      _logger.d('Enqueued sync operation: ${operation.operationType} for habit ${operation.habitId}');
      
      // Trigger immediate processing attempt
      _processQueue();
    } catch (e, stackTrace) {
      _logger.e('Failed to enqueue sync operation', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Start background processing of sync queue
  Future<void> _startProcessing() async {
    // Process queue immediately on startup
    await _processQueue();
    
    // Schedule periodic processing
    _retryTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _processQueue();
    });
  }
  
  /// Process all pending operations in the queue
  Future<void> _processQueue() async {
    if (_repository == null) return;
    
    try {
      final pendingOpsBefore = await _db.isar.syncOps
          .filter()
          .completedEqualTo(false)
          .findAll();
      
      if (pendingOpsBefore.isEmpty) {
        // Log pending count when queue is empty
        final finalCount = await getPendingCount();
        _logger.i('SyncQueue: Pending: $finalCount');
        return;
      }
      
      _logger.d('Processing ${pendingOpsBefore.length} pending sync operations');
      
      for (final op in pendingOpsBefore) {
        await _processOperation(op);
      }
      
      // Log pending count after processing
      final finalCount = await getPendingCount();
      _logger.i('SyncQueue: Pending after processing: $finalCount');
      
    } catch (e, stackTrace) {
      _logger.e('Error processing sync queue', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Process a single sync operation
  Future<void> _processOperation(SyncOp op) async {
    if (_repository == null || op.attemptCount >= op.maxRetries) {
      if (op.attemptCount >= op.maxRetries) {
        _logger.w('Max retries exceeded for operation: ${op.operationType} ${op.habitId}');
        await _markOperationFailed(op, 'Max retries exceeded');
      }
      return;
    }
    
    // Calculate exponential backoff delay with max 300 seconds (5 minutes)
    final retrySec = min(300, 2 << op.attemptCount);
    final nextAttemptTime = (op.lastAttempt ?? op.createdAt).add(Duration(seconds: retrySec));
    
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
          result = await _repository!.completeHabit(op.habitId, xpAwarded: op.xpAwarded);
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
        _logger.d('Successfully synced operation: ${op.operationType} ${op.habitId}');
      } else {
        // Error returned
        op.errorMessage = result;
        await _updateOperation(op);
        _logger.w('Sync operation failed: ${op.operationType} ${op.habitId} - $result');
      }
      
    } catch (e, stackTrace) {
      op.errorMessage = e.toString();
      await _updateOperation(op);
      _logger.e('Error processing sync operation: ${op.operationType} ${op.habitId}', 
               error: e, stackTrace: stackTrace);
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
    return await _db.isar.syncOps
        .filter()
        .completedEqualTo(false)
        .count();
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
  
  /// Dispose sync queue
  void dispose() {
    _retryTimer?.cancel();
    _logger.i('SyncQueue disposed');
  }
}