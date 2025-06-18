import 'dart:async';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_client.dart';
import '../network/supabase_habit_dto.dart';
import '../auth/auth_service.dart';

/// Service for managing realtime subscriptions to habits and completions
class RealtimeService {
  static RealtimeService? _instance;
  static RealtimeService get instance => _instance ??= RealtimeService._();

  RealtimeService._();

  final Logger _logger = Logger();
  RealtimeChannel? _habitsChannel;
  RealtimeChannel? _completionsChannel;

  // Stream controllers for realtime updates with sync option to prevent buffering
  final _habitsUpdateController =
      StreamController<List<Habit>>.broadcast(sync: true);
  final _completionsUpdateController =
      StreamController<Map<String, dynamic>>.broadcast(sync: true);

  /// Stream of habit updates from realtime
  Stream<List<Habit>> get habitsUpdates => _habitsUpdateController.stream;

  /// Stream of completion updates from realtime
  Stream<Map<String, dynamic>> get completionsUpdates =>
      _completionsUpdateController.stream;

  /// Initialize realtime subscriptions
  Future<void> initialize() async {
    try {
      // Check if Supabase is available
      if (!SupabaseClientService.instance.isInitialized) {
        _logger.d('Supabase not initialized, skipping realtime initialization');
        return;
      }

      if (!AuthService.instance.isAuthenticated) {
        _logger.d('Not authenticated, skipping realtime initialization');
        return;
      }

      await _subscribeToHabits();
      await _subscribeToCompletions();
      _logger.i('Realtime service initialized');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize realtime service',
          error: e, stackTrace: stackTrace);
      // Don't rethrow - allow app to continue without realtime
    }
  }

  /// Subscribe to habits table changes
  Future<void> _subscribeToHabits() async {
    final currentUserId = AuthService.instance.getCurrentUserId();
    if (currentUserId == null) return;

    try {
      // Get partner IDs for filtering
      final partnerIds = await _getPartnerIds(currentUserId);
      final allowedUserIds = [currentUserId, ...partnerIds];

      _habitsChannel = supabase
          .channel('habits_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'habits',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: currentUserId,
            ),
            callback: _onHabitsChange,
          )
          .subscribe();

      if (kDebugMode) {
        _logger.d(
            'Subscribed to habits realtime updates for users: $allowedUserIds');
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to subscribe to habits updates',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Subscribe to completions table changes
  Future<void> _subscribeToCompletions() async {
    final currentUserId = AuthService.instance.getCurrentUserId();
    if (currentUserId == null) return;

    try {
      // Get partner IDs for filtering
      final partnerIds = await _getPartnerIds(currentUserId);
      final allowedUserIds = [currentUserId, ...partnerIds];

      _completionsChannel = supabase
          .channel('completions_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'habit_completions',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: currentUserId,
            ),
            callback: _onCompletionsChange,
          )
          .subscribe();

      if (kDebugMode) {
        _logger.d(
            'Subscribed to completions realtime updates for users: $allowedUserIds');
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to subscribe to completions updates',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Get partner IDs for current user
  Future<List<String>> _getPartnerIds(String userId) async {
    try {
      final response = await supabase
          .from('relationships')
          .select('user_id, partner_id')
          .or('user_id.eq.$userId,partner_id.eq.$userId')
          .eq('status', 'active');

      final partnerIds = <String>[];
      for (final relationship in response) {
        final partnerId = relationship['user_id'] == userId
            ? relationship['partner_id'] as String?
            : relationship['user_id'] as String?;
        if (partnerId != null && partnerId != userId) {
          partnerIds.add(partnerId);
        }
      }

      return partnerIds;
    } catch (e, stackTrace) {
      _logger.e('Failed to get partner IDs', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Handle habits table changes
  void _onHabitsChange(PostgresChangePayload payload) {
    try {
      if (kDebugMode) {
        _logger.i('REALTIME HABITS: ${payload.eventType} on ${payload.table}');
        _logger.i('PAYLOAD NEW: ${payload.newRecord}');
        _logger.i('PAYLOAD OLD: ${payload.oldRecord}');
      }

      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
          _handleHabitInsert(payload.newRecord);
          break;
        case PostgresChangeEvent.update:
          _handleHabitUpdate(payload.newRecord);
          break;
        case PostgresChangeEvent.delete:
          _handleHabitDelete(payload.oldRecord);
          break;
        default:
          break;
      }
    } catch (e, stackTrace) {
      _logger.e('Error handling habits change',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Handle completions table changes
  void _onCompletionsChange(PostgresChangePayload payload) {
    try {
      if (kDebugMode) {
        _logger.i(
            'REALTIME COMPLETIONS: ${payload.eventType} on ${payload.table}');
        _logger.i('PAYLOAD NEW: ${payload.newRecord}');
        _logger.i('PAYLOAD OLD: ${payload.oldRecord}');
      }

      // Forward completion events to stream
      _completionsUpdateController.add({
        'event': payload.eventType.name,
        'data': payload.newRecord,
      });
    } catch (e, stackTrace) {
      _logger.e('Error handling completions change',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Handle habit insert event
  void _handleHabitInsert(Map<String, dynamic> record) {
    try {
      final habit = SupabaseHabitDto.fromJson(record).toDomain();
      if (kDebugMode) {
        _logger.d('New habit created: ${habit.name}');
      }
      // Trigger refresh of habits list
      _triggerHabitsRefresh();
    } catch (e, stackTrace) {
      _logger.e('Error handling habit insert',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Handle habit update event
  void _handleHabitUpdate(Map<String, dynamic> record) {
    try {
      final habit = SupabaseHabitDto.fromJson(record).toDomain();
      if (kDebugMode) {
        _logger.d('Habit updated: ${habit.name}');
      }
      // Trigger refresh of habits list
      _triggerHabitsRefresh();
    } catch (e, stackTrace) {
      _logger.e('Error handling habit update',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Handle habit delete event
  void _handleHabitDelete(Map<String, dynamic> record) {
    try {
      final habitId = record['id'] as String;
      if (kDebugMode) {
        _logger.d('Habit deleted: $habitId');
      }
      // Trigger refresh of habits list
      _triggerHabitsRefresh();
    } catch (e, stackTrace) {
      _logger.e('Error handling habit delete',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Trigger habits list refresh (providers will listen to this)
  void _triggerHabitsRefresh() {
    // Only trigger if there are active listeners to prevent memory buildup
    if (_habitsUpdateController.hasListener) {
      _habitsUpdateController.add([]);
    }
  }

  /// Dispose realtime service
  void dispose() {
    _habitsChannel?.unsubscribe();
    _completionsChannel?.unsubscribe();
    _habitsUpdateController.close();
    _completionsUpdateController.close();
    _logger.i('Realtime service disposed');
  }
}
