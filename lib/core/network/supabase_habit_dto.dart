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

  /// Create DTO from Supabase JSON response (minimal schema)
  factory SupabaseHabitDto.fromJson(Map<String, dynamic> json) {
    return SupabaseHabitDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      ownerId: json['user_id'] as String,
      type: 'basic', // Default type for simple schema
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert DTO to JSON for Supabase (minimal schema)
  Map<String, dynamic> toJson() {
    return {
      // Generate proper UUID if the id is not already UUID format
      'id': _ensureUuidFormat(id),
      'name': name,
      'description': description,
      'user_id': ownerId,
      'frequency_type': 'daily', // Simple default for now
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Ensure ID is in proper UUID format
  String _ensureUuidFormat(String id) {
    // If it's already a valid UUID format, return as-is
    if (RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(id)) {
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