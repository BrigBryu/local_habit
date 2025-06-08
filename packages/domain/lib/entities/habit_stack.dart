
import '../services/time_service.dart';
import 'base_habit.dart';

/// Habit that builds on top of another habit (habit stacking)
class HabitStack extends BaseHabit {
  final String stackedOnHabitId;

  const HabitStack({
    required super.id,
    required super.name,
    required super.description,
    required super.createdAt,
    required this.stackedOnHabitId,
    super.lastCompleted,
    super.currentStreak = 0,
    super.dailyCompletionCount = 0,
    super.lastCompletionCountReset,
  });

  @override
  IconData get icon => Icons.layers;

  @override
  String get typeName => 'Habit Stack';

  @override
  String get displayName => '📚 $name';

  @override
  bool canComplete(TimeService timeService) {
    // Habit stacks can only be completed if not completed today
    // Visibility is handled separately by the service
    return !isCompletedToday(timeService);
  }

  @override
  String getStatusText(TimeService timeService) {
    if (isCompletedToday(timeService)) {
      return 'Stack completed! 🎉';
    }
    return 'Ready to stack';
  }

  /// Get the display name for when both base and stack are completed
  String getCombinedDisplayName(String baseHabitName, int chainDepth) {
    return '$baseHabitName → $name 📚$chainDepth';
  }

  @override
  HabitStack complete() {
    final timeService = TimeService();
    final now = timeService.now();
    
    // Calculate new streak
    int newStreak = currentStreak;
    if (lastCompleted != null) {
      final daysSinceCompletion = timeService.daysBetween(lastCompleted!, now);
      if (daysSinceCompletion == 1) {
        newStreak = currentStreak + 1;
      } else if (daysSinceCompletion == 0) {
        newStreak = currentStreak;
      } else {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    return copyWith(
      lastCompleted: now,
      currentStreak: newStreak,
      dailyCompletionCount: dailyCompletionCount + 1,
    ) as HabitStack;
  }

  @override
  HabitStack copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? lastCompleted,
    int? currentStreak,
    int? dailyCompletionCount,
    DateTime? lastCompletionCountReset,
    String? stackedOnHabitId,
  }) {
    return HabitStack(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      dailyCompletionCount: dailyCompletionCount ?? this.dailyCompletionCount,
      lastCompletionCountReset: lastCompletionCountReset ?? this.lastCompletionCountReset,
      stackedOnHabitId: stackedOnHabitId ?? this.stackedOnHabitId,
    );
  }

  /// Factory constructor to create a new HabitStack
  factory HabitStack.create({
    required String name,
    required String description,
    required String stackedOnHabitId,
  }) {
    return HabitStack(
      id: BaseHabit.generateId(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
      stackedOnHabitId: stackedOnHabitId,
    );
  }
}