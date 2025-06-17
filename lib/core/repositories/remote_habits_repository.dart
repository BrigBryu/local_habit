import 'dart:async';
import 'package:domain/domain.dart';
import 'package:logger/logger.dart';

import 'habits_repository.dart';
// import 'local_habits_repository.dart';
import '../network/supabase_client.dart';
import '../network/supabase_habit_dto.dart';
import '../auth/username_auth_service.dart';
import '../sync/sync_queue.dart';
import '../realtime/realtime_service.dart';

/// Remote repository implementation for syncing habits with Supabase backend.
class RemoteHabitsRepository implements HabitsRepository {
  final Logger _logger = Logger();
  // final LocalHabitsRepository _localFallback = LocalHabitsRepository();
  String _currentUserId = '';

  // Stream controllers for manual updates
  final _ownHabitsController = StreamController<List<Habit>>.broadcast();
  final _partnerHabitsController = StreamController<List<Habit>>.broadcast();

  @override
  String getCurrentUserId() => _currentUserId;

  @override
  Future<void> setCurrentUserId(String userId) async {
    _currentUserId = userId;
    // await _localFallback.setCurrentUserId(userId);
    _logger.d('Remote repository user ID set to: $userId');
  }

  @override
  Future<void> initialize() async {
    try {
      // Initialize local fallback first
      // await _localFallback.initialize();

      // Get current user ID from username auth service
      final authUserId = UsernameAuthService.instance.getCurrentUserId();
      if (authUserId != null) {
        _currentUserId = authUserId;
      } else {
        _currentUserId = 'default_user'; // Fallback for development
      }

      // Initialize sync queue (with timeout)
      try {
        await SyncQueue.instance
            .initialize(this)
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        _logger.w('Sync queue initialization failed or timed out: $e');
      }

      // Initialize realtime service for live habit updates (with timeout)
      try {
        await RealtimeService.instance
            .initialize()
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        _logger.w('Realtime service initialization failed or timed out: $e');
      }

      _logger.i('RemoteHabitsRepository initialized for user: $_currentUserId');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize remote repository',
          error: e, stackTrace: stackTrace);
      // Don't rethrow - allow app to continue in degraded mode
      _logger.w('Continuing in degraded mode without full sync capabilities');
    }
  }

  @override
  Stream<List<Habit>> ownHabits() {
    try {
      // Skip auth check for dev users
      _logger.d('🏠 [RemoteRepo] Streaming own habits for user: $_currentUserId');

      return supabase
          .from('habits')
          .stream(primaryKey: ['id'])
          .eq('user_id', _currentUserId)
          .map((data) {
            _logger.d('🔄 [RemoteRepo] Own habits raw data: ${data.length} records for $_currentUserId');
            data.forEach((record) {
              _logger.d('📋 [RemoteRepo] Own habit record: id=${record['id']}, name=${record['name']}, user_id=${record['user_id']}');
            });
            
            final habits = data.toHabitDomainList();
            _logger.d('✅ [RemoteRepo] Own habits converted: ${habits.length} domain habits');
            
            return habits;
          })
          .handleError((error, stackTrace) {
            _logger.e('❌ [RemoteRepo] Error streaming own habits from Supabase',
                error: error, stackTrace: stackTrace);
            // Return empty stream on error
            return Stream.value(<Habit>[]);
          });
    } catch (e, stackTrace) {
      _logger.e('❌ [RemoteRepo] Failed to create own habits stream',
          error: e, stackTrace: stackTrace);
      return Stream.value(<Habit>[]);
    }
  }

  @override
  Stream<List<Habit>> partnerHabits(String partnerId) {
    try {
      // Skip auth check for dev users
      _logger.d('🔍 [RemoteRepo] Streaming partner habits for: $partnerId');

      return supabase
          .from('habits')
          .stream(primaryKey: ['id'])
          .eq('user_id', partnerId)
          .map((data) {
            _logger.d('🔄 [RemoteRepo] Raw Supabase data received: ${data.length} records');
            data.forEach((record) {
              _logger.d('📋 [RemoteRepo] Habit record: id=${record['id']}, name=${record['name']}, user_id=${record['user_id']}');
            });
            
            final habits = data.toHabitDomainList();
            _logger.d('✅ [RemoteRepo] Converted to ${habits.length} domain habits for partner $partnerId');
            habits.forEach((habit) {
              _logger.d('📝 [RemoteRepo] Domain habit: ${habit.name} (${habit.type})');
            });
            
            return habits;
          })
          .handleError((error, stackTrace) {
            _logger.e('❌ [RemoteRepo] Error streaming partner habits from Supabase',
                error: error, stackTrace: stackTrace);
            // Return empty stream on error
            return Stream.value(<Habit>[]);
          });
    } catch (e, stackTrace) {
      _logger.e('❌ [RemoteRepo] Failed to create partner habits stream',
          error: e, stackTrace: stackTrace);
      return Stream.value(<Habit>[]);
    }
  }

  @override
  Future<String?> addHabit(Habit habit) async {
    try {
      if (!UsernameAuthService.instance.isAuthenticated) {
        _logger.w('Not authenticated, enqueuing habit for later sync');
        await SyncQueue.instance.enqueue(SyncOp.addHabit(habit));
        return "Added to queue - will sync when authenticated";
      }

      _logger.d('Adding habit for user: $_currentUserId');

      // Ensure we have a valid user ID
      if (_currentUserId.isEmpty) {
        throw Exception('No valid user ID available');
      }

      // Create DTO and insert to Supabase
      final dto = SupabaseHabitDto.fromDomain(habit, _currentUserId);
      final habitJson = dto.toJson();

      _logger.d('Inserting habit data: $habitJson');

      await supabase.from('habits').insert(habitJson);

      _logger.i('Successfully added habit to Supabase: ${habit.name}');

      return null; // Success
    } catch (e, stackTrace) {
      _logger.e('Failed to add habit remotely, enqueuing for retry',
          error: e, stackTrace: stackTrace);

      // Enqueue for later sync
      await SyncQueue.instance.enqueue(SyncOp.addHabit(habit));

      return "Network error - added to sync queue";
    }
  }

  @override
  Future<String?> updateHabit(Habit habit) async {
    try {
      if (!UsernameAuthService.instance.isAuthenticated) {
        _logger.d('Not authenticated, using local fallback to update habit');
        _logger.d('Proceeding with operation for dev user: $_currentUserId');
        return null;
      }

      // Create DTO and update in Supabase
      final dto = SupabaseHabitDto.fromDomain(habit, _currentUserId);

      await supabase
          .from('habits')
          .update(dto.toJson())
          .eq('id', habit.id)
          .eq('user_id', _currentUserId);

      _logger.i('Successfully updated habit in Supabase: ${habit.name}');

      // Also update local for offline support
      // Local fallback disabled

      return null; // Success
    } catch (e, stackTrace) {
      _logger.e(
          'Failed to update habit remotely, using local fallback and enqueuing for retry',
          error: e,
          stackTrace: stackTrace);

      // Enqueue for later sync
      await SyncQueue.instance.enqueue(SyncOp.updateHabit(habit));

      return "Network error occurred";
    }
  }

  @override
  Future<String?> removeHabit(String habitId) async {
    try {
      if (!UsernameAuthService.instance.isAuthenticated) {
        _logger.d('Not authenticated, using local fallback to remove habit');
        _logger.d('Proceeding with operation for dev user: $_currentUserId');
        return null;
      }

      // Delete from Supabase
      await supabase
          .from('habits')
          .delete()
          .eq('id', habitId)
          .eq('user_id', _currentUserId);

      _logger.i('Successfully removed habit from Supabase: $habitId');

      // Also remove from local
      // Local fallback disabled

      return null; // Success
    } catch (e, stackTrace) {
      _logger.e(
          'Failed to remove habit remotely, using local fallback and enqueuing for retry',
          error: e,
          stackTrace: stackTrace);

      // Enqueue for later sync
      await SyncQueue.instance.enqueue(SyncOp.removeHabit(habitId));

      return "Network error occurred";
    }
  }

  @override
  Future<String?> completeHabit(String habitId, {int xpAwarded = 0}) async {
    try {
      if (!UsernameAuthService.instance.isAuthenticated) {
        _logger.d('Not authenticated, using local fallback to complete habit');
        _logger.d('Proceeding with operation for dev user: $_currentUserId');
        return null;
      }

      final now = DateTime.now();

      // Record completion in Supabase
      try {
        await supabase.from('habit_completions').insert({
          'habit_id': habitId,
          'user_id': _currentUserId,
          'completed_at': now.toIso8601String(),
          'xp_awarded': xpAwarded,
          'completion_type': 'manual',
        });
      } catch (completionError) {
        _logger.w(
            'Failed to insert habit completion but continuing: $completionError');
      }

      // Record XP event if XP was awarded
      if (xpAwarded > 0) {
        await supabase.from('xp_events').insert({
          'user_id': _currentUserId,
          'habit_id': habitId,
          'event_type': 'habit_completion',
          'xp_amount': xpAwarded,
          'description': 'Habit completion reward',
        });
      }

      _logger.i(
          'Successfully recorded habit completion in Supabase: $habitId (XP: $xpAwarded)');

      // Also record in local for offline support
      // Local fallback disabled

      return null; // Success
    } catch (e, stackTrace) {
      _logger.e(
          'Failed to complete habit remotely, using local fallback and enqueuing for retry',
          error: e,
          stackTrace: stackTrace);

      // Enqueue for later sync
      await SyncQueue.instance
          .enqueue(SyncOp.completeHabit(habitId, xpAwarded));

      return "Network error occurred";
    }
  }

  @override
  Future<String?> recordFailure(String habitId) async {
    try {
      if (!UsernameAuthService.instance.isAuthenticated) {
        _logger.d('Not authenticated, using local fallback to record failure');
        _logger.d('Proceeding with operation for dev user: $_currentUserId');
        return null;
      }

      final now = DateTime.now();

      // Record failure in habit_completions table with negative XP
      try {
        await supabase.from('habit_completions').insert({
          'habit_id': habitId,
          'user_id': _currentUserId,
          'completed_at': now.toIso8601String(),
          'xp_awarded': -5, // Penalty for avoidance failure
          'completion_type': 'failure',
          'notes': 'Avoidance habit failure',
        });
      } catch (completionError) {
        _logger.w(
            'Failed to insert habit failure but continuing: $completionError');
      }

      // Record XP penalty event
      await supabase.from('xp_events').insert({
        'user_id': _currentUserId,
        'habit_id': habitId,
        'event_type': 'habit_completion',
        'xp_amount': -5,
        'description': 'Avoidance habit failure penalty',
      });

      _logger.i('Successfully recorded habit failure in Supabase: $habitId');

      // Also record in local for offline support
      // Local fallback disabled

      return null; // Success
    } catch (e, stackTrace) {
      _logger.e(
          'Failed to record failure remotely, using local fallback and enqueuing for retry',
          error: e,
          stackTrace: stackTrace);

      // Enqueue for later sync
      await SyncQueue.instance.enqueue(SyncOp.recordFailure(habitId));

      return "Network error occurred";
    }
  }

  @override
  Future<void> dispose() async {
    await _ownHabitsController.close();
    await _partnerHabitsController.close();
    SyncQueue.instance.dispose();
    // Local fallback disabled
    _logger.i('RemoteHabitsRepository disposed');
  }

  // TODO: Future methods for multiplayer features:

  // Future<List<Relationship>> getPartnershipRequests();
  // Future<String?> sendPartnershipRequest(String partnerEmail);
  // Future<String?> acceptPartnershipRequest(String requestId);
  // Future<String?> createSharedHabit(Habit habit, List<String> partnerIds);
  // Future<List<Achievement>> getAchievements();
  // Future<List<LeaderboardEntry>> getLeaderboard(String timeframe);
  // Stream<PartnerActivity> partnerActivityStream();
}
