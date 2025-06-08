import 'package:meta/meta.dart';
import '../services/time_service.dart';
import 'habit_icon.dart';

/// Base abstract class for all habit types
abstract class BaseHabit {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime? lastCompleted;
  final int currentStreak;
  final int dailyCompletionCount;
  final DateTime? lastCompletionCountReset;

  const BaseHabit({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.lastCompleted,
    this.currentStreak = 0,
    this.dailyCompletionCount = 0,
    this.lastCompletionCountReset,
  });

  /// Get the display name for this habit
  String get displayName => name;

  /// Get the icon for this habit type
  HabitIcon get icon;

  /// Get the habit type name
  String get typeName;

  /// Check if this habit can be completed right now
  bool canComplete(TimeService timeService);

  /// Get the current status display text
  String getStatusText(TimeService timeService);

  /// Complete this habit (returns a new instance with updated state)
  BaseHabit complete();

  /// Check if this habit was completed today
  bool isCompletedToday(TimeService timeService) {
    if (lastCompleted == null) return false;
    return timeService.isSameDay(lastCompleted!, timeService.now());
  }

  /// Calculate current streak accounting for missed days
  int calculateCurrentStreak(TimeService timeService) {
    if (lastCompleted == null) return 0;

    final now = timeService.now();
    final daysSinceCompletion = timeService.daysBetween(lastCompleted!, now);

    // If completed today, streak continues
    if (daysSinceCompletion == 0) {
      return currentStreak;
    }

    // If completed yesterday, streak continues
    if (daysSinceCompletion == 1) {
      return currentStreak;
    }

    // If more than 1 day ago, streak is broken
    return 0;
  }

  /// Get XP bonus based on streak
  int getStreakBonus() {
    if (currentStreak >= 30) return 15;
    if (currentStreak >= 7) return 5;
    if (currentStreak >= 3) return 2;
    return 0;
  }

  /// Get total XP for completing this habit
  int getTotalXP() {
    return 1 + getStreakBonus();
  }

  /// Generate a unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Reset daily completion count if needed
  BaseHabit resetDailyCountIfNeeded(TimeService timeService) {
    final now = timeService.now();
    
    // If we haven't reset today, reset the count
    if (lastCompletionCountReset == null || 
        !timeService.isSameDay(lastCompletionCountReset!, now)) {
      return copyWith(
        dailyCompletionCount: 0,
        lastCompletionCountReset: now,
      );
    }
    
    return this;
  }

  /// Create a copy with updated fields (to be implemented by subclasses)
  BaseHabit copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? lastCompleted,
    int? currentStreak,
    int? dailyCompletionCount,
    DateTime? lastCompletionCountReset,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseHabit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}