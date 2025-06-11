import 'dart:async';
import 'package:domain/domain.dart';
import 'package:logger/logger.dart';

import 'habits_repository.dart';
import 'local_habits_repository.dart';
import '../network/supabase_client.dart';
import '../network/supabase_habit_dto.dart';
import '../auth/auth_service.dart';

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

      // TODO: Implement Supabase habit creation
      _logger.d('TODO: Add habit to Supabase: ${habit.name}');
      
      // For now, add to local as well for offline support
      return await _localFallback.addHabit(habit);
      
    } catch (e, stackTrace) {
      _logger.e('Failed to add habit remotely, using local fallback', 
               error: e, stackTrace: stackTrace);
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

      // TODO: Implement Supabase habit update
      _logger.d('TODO: Update habit in Supabase: ${habit.name}');
      
      // For now, update local as well for offline support
      return await _localFallback.updateHabit(habit);
      
    } catch (e, stackTrace) {
      _logger.e('Failed to update habit remotely, using local fallback', 
               error: e, stackTrace: stackTrace);
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

      // TODO: Implement Supabase habit deletion
      _logger.d('TODO: Remove habit from Supabase: $habitId');
      
      // For now, remove from local as well
      return await _localFallback.removeHabit(habitId);
      
    } catch (e, stackTrace) {
      _logger.e('Failed to remove habit remotely, using local fallback', 
               error: e, stackTrace: stackTrace);
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

      // TODO: Implement Supabase habit completion
      _logger.d('TODO: Record habit completion in Supabase: $habitId (XP: $xpAwarded)');
      
      // For now, record in local as well
      return await _localFallback.completeHabit(habitId, xpAwarded: xpAwarded);
      
    } catch (e, stackTrace) {
      _logger.e('Failed to complete habit remotely, using local fallback', 
               error: e, stackTrace: stackTrace);
      return await _localFallback.completeHabit(habitId, xpAwarded: xpAwarded);
    }
  }
  
  @override
  Future<void> dispose() async {
    await _ownHabitsController.close();
    await _partnerHabitsController.close();
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