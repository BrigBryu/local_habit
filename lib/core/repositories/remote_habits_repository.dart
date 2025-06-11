import 'dart:async';
import 'package:domain/domain.dart';
import 'package:logger/logger.dart';

import 'habits_repository.dart';
import 'local_habits_repository.dart';
import '../network/supabase_client.dart';
import '../network/supabase_habit_dto.dart';
import '../auth/auth_service.dart';
import '../sync/sync_queue.dart';

/// Remote repository implementation for syncing habits with Supabase backend.
class RemoteHabitsRepository implements HabitsRepository {
  final Logger _logger = Logger();
  final LocalHabitsRepository _localFallback = LocalHabitsRepository();
  String _currentUserId = '';
  
  // Stream controllers for manual updates
  final _ownHabitsController = StreamController<List<Habit>>.broadcast();
  final _partnerHabitsController = StreamController<List<Habit>>.broadcast();
  
  @override
  String getCurrentUserId() => _currentUserId;
  
  @override
  Future<void> setCurrentUserId(String userId) async {
    _currentUserId = userId;
    await _localFallback.setCurrentUserId(userId);
    _logger.d('Remote repository user ID set to: $userId');
  }
  
  @override
  Future<void> initialize() async {
    try {
      // Initialize local fallback first
      await _localFallback.initialize();
      
      // Get current user ID from auth service
      final authUserId = AuthService.instance.getCurrentUserId();
      if (authUserId != null) {
        _currentUserId = authUserId;
      } else {
        _currentUserId = 'default_user'; // Fallback for development
      }
      
      // Initialize sync queue
      await SyncQueue.instance.initialize(this);
      
      _logger.i('RemoteHabitsRepository initialized for user: $_currentUserId');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize remote repository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  @override
  Stream<List<Habit>> ownHabits() {
    try {
      if (!AuthService.instance.isAuthenticated) {
        _logger.d('Not authenticated, using local fallback for own habits');
        return _localFallback.ownHabits();
      }

      return supabase
          .from('habits')
          .stream(primaryKey: ['id'])
          .eq('owner_id', _currentUserId)
          .map((data) => data.toHabitDomainList())
          .handleError((error, stackTrace) {
            _logger.e('Error streaming own habits from Supabase, falling back to local', 
                     error: error, stackTrace: stackTrace);
            // Return local fallback data on error
            return _localFallback.ownHabits();
          });
    } catch (e, stackTrace) {
      _logger.e('Failed to create own habits stream', error: e, stackTrace: stackTrace);
      return _localFallback.ownHabits();
    }
  }
  
  @override
  Stream<List<Habit>> partnerHabits(String partnerId) {
    try {
      if (!AuthService.instance.isAuthenticated) {
        _logger.d('Not authenticated, using local fallback for partner habits');
        return _localFallback.partnerHabits(partnerId);
      }

      return supabase
          .from('habits')
          .stream(primaryKey: ['id'])
          .eq('owner_id', partnerId)
          .map((data) => data.toHabitDomainList())
          .handleError((error, stackTrace) {
            _logger.e('Error streaming partner habits from Supabase, falling back to local', 
                     error: error, stackTrace: stackTrace);
            // Return local fallback data on error
            return _localFallback.partnerHabits(partnerId);
          });
    } catch (e, stackTrace) {
      _logger.e('Failed to create partner habits stream', error: e, stackTrace: stackTrace);
      return _localFallback.partnerHabits(partnerId);
    }
  }
  
  @override
  Future<String?> addHabit(Habit habit) async {
    try {
      if (!AuthService.instance.isAuthenticated) {
        _logger.d('Not authenticated, using local fallback to add habit');
        return await _localFallback.addHabit(habit);
      }

      // Create DTO and insert to Supabase
      final dto = SupabaseHabitDto.fromDomain(habit, _currentUserId);
      
      final response = await supabase
          .from('habits')
          .insert(dto.toJson())
          .select()
          .single();
      
      _logger.i('Successfully added habit to Supabase: ${habit.name}');
      
      // Also add to local for offline support
      await _localFallback.addHabit(habit);
      
      return null; // Success
      
    } catch (e, stackTrace) {
      _logger.e('Failed to add habit remotely, using local fallback and enqueuing for retry', 
               error: e, stackTrace: stackTrace);
      
      // Enqueue for later sync
      await SyncQueue.instance.enqueue(SyncOp.addHabit(habit));
      
      return await _localFallback.addHabit(habit);
    }
  }
  
  @override
  Future<String?> updateHabit(Habit habit) async {
    try {
      if (!AuthService.instance.isAuthenticated) {
        _logger.d('Not authenticated, using local fallback to update habit');
        return await _localFallback.updateHabit(habit);
      }

      // Create DTO and update in Supabase
      final dto = SupabaseHabitDto.fromDomain(habit, _currentUserId);
      
      await supabase
          .from('habits')
          .update(dto.toJson())
          .eq('id', habit.id)
          .eq('owner_id', _currentUserId);
      
      _logger.i('Successfully updated habit in Supabase: ${habit.name}');
      
      // Also update local for offline support
      await _localFallback.updateHabit(habit);
      
      return null; // Success
      
    } catch (e, stackTrace) {
      _logger.e('Failed to update habit remotely, using local fallback and enqueuing for retry', 
               error: e, stackTrace: stackTrace);
      
      // Enqueue for later sync
      await SyncQueue.instance.enqueue(SyncOp.updateHabit(habit));
      
      return await _localFallback.updateHabit(habit);
    }
  }
  
  @override
  Future<String?> removeHabit(String habitId) async {
    try {
      if (!AuthService.instance.isAuthenticated) {
        _logger.d('Not authenticated, using local fallback to remove habit');
        return await _localFallback.removeHabit(habitId);
      }

      // Delete from Supabase
      await supabase
          .from('habits')
          .delete()
          .eq('id', habitId)
          .eq('owner_id', _currentUserId);
      
      _logger.i('Successfully removed habit from Supabase: $habitId');
      
      // Also remove from local
      await _localFallback.removeHabit(habitId);
      
      return null; // Success
      
    } catch (e, stackTrace) {
      _logger.e('Failed to remove habit remotely, using local fallback and enqueuing for retry', 
               error: e, stackTrace: stackTrace);
      
      // Enqueue for later sync
      await SyncQueue.instance.enqueue(SyncOp.removeHabit(habitId));
      
      return await _localFallback.removeHabit(habitId);
    }
  }
  
  @override
  Future<String?> completeHabit(String habitId, {int xpAwarded = 0}) async {
    try {
      if (!AuthService.instance.isAuthenticated) {
        _logger.d('Not authenticated, using local fallback to complete habit');
        return await _localFallback.completeHabit(habitId, xpAwarded: xpAwarded);
      }

      final now = DateTime.now();
      
      // Record completion in Supabase
      await supabase.from('completions').insert({
        'habit_id': habitId,
        'owner_id': _currentUserId,
        'completed_at': now.toIso8601String(),
        'xp_awarded': xpAwarded,
        'completion_type': 'manual',
      });
      
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
      
      _logger.i('Successfully recorded habit completion in Supabase: $habitId (XP: $xpAwarded)');
      
      // Also record in local for offline support
      await _localFallback.completeHabit(habitId, xpAwarded: xpAwarded);
      
      return null; // Success
      
    } catch (e, stackTrace) {
      _logger.e('Failed to complete habit remotely, using local fallback and enqueuing for retry', 
               error: e, stackTrace: stackTrace);
      
      // Enqueue for later sync
      await SyncQueue.instance.enqueue(SyncOp.completeHabit(habitId, xpAwarded));
      
      return await _localFallback.completeHabit(habitId, xpAwarded: xpAwarded);
    }
  }
  
  @override
  Future<String?> recordFailure(String habitId) async {
    try {
      if (!AuthService.instance.isAuthenticated) {
        _logger.d('Not authenticated, using local fallback to record failure');
        return await _localFallback.recordFailure(habitId);
      }

      final now = DateTime.now();
      
      // Record failure in completions table with negative XP
      await supabase.from('completions').insert({
        'habit_id': habitId,
        'owner_id': _currentUserId,
        'completed_at': now.toIso8601String(),
        'xp_awarded': -5, // Penalty for avoidance failure
        'completion_type': 'failure',
        'notes': 'Avoidance habit failure',
      });
      
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
      await _localFallback.recordFailure(habitId);
      
      return null; // Success
      
    } catch (e, stackTrace) {
      _logger.e('Failed to record failure remotely, using local fallback and enqueuing for retry', 
               error: e, stackTrace: stackTrace);
      
      // Enqueue for later sync
      await SyncQueue.instance.enqueue(SyncOp.recordFailure(habitId));
      
      return await _localFallback.recordFailure(habitId);
    }
  }
  
  @override
  Future<void> dispose() async {
    await _ownHabitsController.close();
    await _partnerHabitsController.close();
    SyncQueue.instance.dispose();
    await _localFallback.dispose();
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