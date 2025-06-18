import 'package:domain/domain.dart';
import 'package:uuid/uuid.dart';

/// DTO for converting between Supabase JSON and Habit domain objects
class SupabaseHabitDto {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String type;
  final String? stackedOnHabitId;
  final List<String>? bundleChildIds;
  final String? parentBundleId;
  final String? parentStackId;
  final List<String>? stackChildIds;
  final int currentChildIndex;
  final int? timeoutMinutes;
  final List<int>? availableDays;
  final DateTime createdAt;
  final DateTime? lastCompleted;
  final DateTime? lastAlarmTriggered;
  final DateTime? sessionStartTime;
  final DateTime? lastSessionStarted;
  final bool sessionCompletedToday;
  final int dailyCompletionCount;
  final DateTime? lastCompletionCountReset;
  final int dailyFailureCount;
  final DateTime? lastFailureCountReset;
  final bool avoidanceSuccessToday;
  final int currentStreak;

  const SupabaseHabitDto({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.type,
    this.stackedOnHabitId,
    this.bundleChildIds,
    this.parentBundleId,
    this.parentStackId,
    this.stackChildIds,
    this.currentChildIndex = 0,
    this.timeoutMinutes,
    this.availableDays,
    required this.createdAt,
    this.lastCompleted,
    this.lastAlarmTriggered,
    this.sessionStartTime,
    this.lastSessionStarted,
    this.sessionCompletedToday = false,
    this.dailyCompletionCount = 0,
    this.lastCompletionCountReset,
    this.dailyFailureCount = 0,
    this.lastFailureCountReset,
    this.avoidanceSuccessToday = false,
    this.currentStreak = 0,
  });

  /// Create DTO from Supabase JSON response (complete schema)
  factory SupabaseHabitDto.fromJson(Map<String, dynamic> json) {
    return SupabaseHabitDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      ownerId: json['user_id'] as String,
      type: json['type'] as String? ?? 'basic',
      stackedOnHabitId: json['stacked_on_habit_id'] as String?,
      bundleChildIds: json['bundle_child_ids'] != null
          ? List<String>.from(json['bundle_child_ids'] as List)
          : null,
      parentBundleId: json['parent_bundle_id'] as String?,
      parentStackId: json['parent_stack_id'] as String?,
      stackChildIds: json['stack_child_ids'] != null
          ? List<String>.from(json['stack_child_ids'] as List)
          : null,
      currentChildIndex: json['current_child_index'] as int? ?? 0,
      timeoutMinutes: json['timeout_minutes'] as int? ?? 30,
      availableDays: json['available_days'] != null
          ? List<int>.from(json['available_days'] as List)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastCompleted: json['last_completed'] != null
          ? DateTime.parse(json['last_completed'] as String)
          : null,
      lastAlarmTriggered: json['last_alarm_triggered'] != null
          ? DateTime.parse(json['last_alarm_triggered'] as String)
          : null,
      sessionStartTime: json['session_start_time'] != null
          ? DateTime.parse(json['session_start_time'] as String)
          : null,
      lastSessionStarted: json['last_session_started'] != null
          ? DateTime.parse(json['last_session_started'] as String)
          : null,
      sessionCompletedToday: json['session_completed_today'] as bool? ?? false,
      dailyCompletionCount: json['daily_completion_count'] as int? ?? 0,
      lastCompletionCountReset: json['last_completion_count_reset'] != null
          ? DateTime.parse(json['last_completion_count_reset'] as String)
          : null,
      dailyFailureCount: json['daily_failure_count'] as int? ?? 0,
      lastFailureCountReset: json['last_failure_count_reset'] != null
          ? DateTime.parse(json['last_failure_count_reset'] as String)
          : null,
      avoidanceSuccessToday: json['avoidance_success_today'] as bool? ?? false,
      currentStreak: json['current_streak'] as int? ?? 0,
    );
  }

  /// Convert DTO to JSON for Supabase (complete schema)
  Map<String, dynamic> toJson() {
    return {
      // Generate proper UUID if the id is not already UUID format
      'id': _ensureUuidFormat(id),
      'name': name,
      'description': description,
      'user_id': ownerId,
      'type': type,
      'frequency_type': 'daily', // Default frequency type
      'frequency_count': 1, // Default frequency count
      'category': 'general', // Default category
      'is_active': true,
      'current_streak': currentStreak,
      'daily_completion_count': dailyCompletionCount,
      'session_completed_today': sessionCompletedToday,
      'avoidance_success_today': avoidanceSuccessToday,
      'daily_failure_count': dailyFailureCount,
      'timeout_minutes': timeoutMinutes,
      'available_days': availableDays,
      'stacked_on_habit_id': stackedOnHabitId,
      'bundle_child_ids': bundleChildIds,
      'parent_bundle_id': parentBundleId,
      'parent_stack_id': parentStackId,
      'stack_child_ids': stackChildIds,
      'current_child_index': currentChildIndex,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'last_completed': lastCompleted?.toIso8601String(),
      'last_alarm_triggered': lastAlarmTriggered?.toIso8601String(),
      'session_start_time': sessionStartTime?.toIso8601String(),
      'last_session_started': lastSessionStarted?.toIso8601String(),
      'last_completion_count_reset':
          lastCompletionCountReset?.toIso8601String(),
      'last_failure_count_reset': lastFailureCountReset?.toIso8601String(),
    };
  }

  /// Ensure ID is in proper UUID format
  String _ensureUuidFormat(String id) {
    // If it's already a valid UUID format, return as-is
    if (RegExp(
            r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
        .hasMatch(id)) {
      return id;
    }

    // Otherwise, generate a new UUID
    return const Uuid().v4();
  }

  /// Convert DTO to domain Habit object
  Habit toDomain() {
    return Habit(
      id: id,
      name: name,
      description: description,
      type: _parseHabitType(type),
      stackedOnHabitId: stackedOnHabitId,
      bundleChildIds: bundleChildIds,
      parentBundleId: parentBundleId,
      parentStackId: parentStackId,
      stackChildIds: stackChildIds,
      currentChildIndex: currentChildIndex,
      timeoutMinutes: timeoutMinutes,
      availableDays: availableDays,
      createdAt: createdAt,
      lastCompleted: lastCompleted,
      lastAlarmTriggered: lastAlarmTriggered,
      sessionStartTime: sessionStartTime,
      lastSessionStarted: lastSessionStarted,
      sessionCompletedToday: sessionCompletedToday,
      dailyCompletionCount: dailyCompletionCount,
      lastCompletionCountReset: lastCompletionCountReset,
      dailyFailureCount: dailyFailureCount,
      lastFailureCountReset: lastFailureCountReset,
      avoidanceSuccessToday: avoidanceSuccessToday,
      currentStreak: currentStreak,
    );
  }

  /// Create DTO from domain Habit object
  factory SupabaseHabitDto.fromDomain(Habit habit, String ownerId) {
    return SupabaseHabitDto(
      id: habit.id,
      name: habit.name,
      description: habit.description,
      ownerId: ownerId,
      type: habit.type.name,
      stackedOnHabitId: habit.stackedOnHabitId,
      bundleChildIds: habit.bundleChildIds,
      parentBundleId: habit.parentBundleId,
      parentStackId: habit.parentStackId,
      stackChildIds: habit.stackChildIds,
      currentChildIndex: habit.currentChildIndex,
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
  }

  HabitType _parseHabitType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'basic':
        return HabitType.basic;
      case 'avoidance':
        return HabitType.avoidance;
      case 'bundle':
        return HabitType.bundle;
      case 'stack':
        return HabitType.stack;
      default:
        return HabitType.basic; // Default fallback
    }
  }
}

/// Extension to convert list of DTOs to domain objects
extension SupabaseHabitDtoList on List<SupabaseHabitDto> {
  List<Habit> toDomainList() {
    return map((dto) => dto.toDomain()).toList();
  }
}

/// Extension to convert Supabase JSON list to domain objects
extension SupabaseJsonList on List<Map<String, dynamic>> {
  List<Habit> toHabitDomainList() {
    return map((json) => SupabaseHabitDto.fromJson(json).toDomain()).toList();
  }
}
