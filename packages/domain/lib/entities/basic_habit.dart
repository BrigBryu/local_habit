import '../services/time_service.dart';
import 'base_habit.dart';
import 'habit_icon.dart';

/// Basic habit that can be completed once per day
class BasicHabit extends BaseHabit {
  const BasicHabit({
    required super.id,
    required super.name,
    required super.description,
    required super.createdAt,
    super.updatedAt,
    super.lastCompleted,
    super.currentStreak = 0,
    super.dailyCompletionCount = 0,
    super.lastCompletionCountReset,
    super.habitIcon = HabitIcon.basic,
    super.timeOfDay = TimeOfDay.anytime,
  });

  @override
  HabitIcon get icon => habitIcon;

  @override
  String get typeName => 'Basic Habit';

  @override
  bool canComplete(TimeService timeService) {
    return !isCompletedToday(timeService);
  }

  @override
  String getStatusText(TimeService timeService) {
    if (isCompletedToday(timeService)) {
      return 'Completed today! 🎉';
    }
    return 'Ready to complete';
  }

  @override
  BasicHabit complete() {
    final timeService = TimeService();
    final now = timeService.now();

    // Calculate new streak
    int newStreak = currentStreak;
    if (lastCompleted != null) {
      final daysSinceCompletion = timeService.daysBetween(lastCompleted!, now);
      if (daysSinceCompletion == 1) {
        // Consecutive day - increment streak
        newStreak = currentStreak + 1;
      } else if (daysSinceCompletion == 0) {
        // Same day - keep streak (shouldn't happen if canComplete works)
        newStreak = currentStreak;
      } else {
        // Gap in days - reset streak to 1
        newStreak = 1;
      }
    } else {
      // First completion
      newStreak = 1;
    }

    return copyWith(
      lastCompleted: now,
      currentStreak: newStreak,
      dailyCompletionCount: dailyCompletionCount + 1,
    );
  }

  @override
  BasicHabit copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastCompleted,
    int? currentStreak,
    int? dailyCompletionCount,
    DateTime? lastCompletionCountReset,
    HabitIcon? habitIcon,
    TimeOfDay? timeOfDay,
  }) {
    return BasicHabit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      dailyCompletionCount: dailyCompletionCount ?? this.dailyCompletionCount,
      lastCompletionCountReset:
          lastCompletionCountReset ?? this.lastCompletionCountReset,
      habitIcon: habitIcon ?? this.habitIcon,
      timeOfDay: timeOfDay ?? this.timeOfDay,
    );
  }

  /// Factory constructor to create a new BasicHabit
  factory BasicHabit.create({
    required String name,
    required String description,
    HabitIcon? habitIcon,
    TimeOfDay? timeOfDay,
  }) {
    final now = DateTime.now();
    return BasicHabit(
      id: BaseHabit.generateId(),
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
      habitIcon: habitIcon ?? HabitIcon.basic,
      timeOfDay: timeOfDay ?? TimeOfDay.anytime,
    );
  }
}
