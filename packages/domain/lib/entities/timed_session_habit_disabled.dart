// TODO(bridger): Re-enable after rewrite. Currently EXCLUDED.
// TimedSessionHabit is temporarily disabled to resolve TimeOfDay conflicts and
// simplify the domain model. Will be re-enabled in a future iteration.

import '../services/time_service.dart';
import 'base_habit.dart';
import 'habit_icon.dart';

/// Timed session habit (click-to-start timer)
class TimedSessionHabit extends BaseHabit {
  final int sessionMinutes; // Duration of the session
  final int graceMinutes; // Grace period after session ends (default 15)
  final DateTime? sessionStartTime; // When current session started
  final DateTime? lastSessionStarted; // When timer was last started today
  final bool sessionCompletedToday; // If session was completed today

  const TimedSessionHabit({
    required super.id,
    required super.name,
    required super.description,
    required super.createdAt,
    required this.sessionMinutes,
    this.graceMinutes = 15,
    this.sessionStartTime,
    this.lastSessionStarted,
    this.sessionCompletedToday = false,
    super.lastCompleted,
    super.currentStreak = 0,
    super.dailyCompletionCount = 0,
    super.lastCompletionCountReset,
  });

  @override
  HabitIcon get icon => HabitIcon.timer;

  @override
  String get typeName => 'Timed Session';

  @override
  String get displayName => '$name ⏱️${sessionMinutes}m';

  bool get isSessionActive =>
      sessionStartTime != null && !sessionCompletedToday;

  @override
  bool canComplete(TimeService timeService) {
    if (sessionCompletedToday) return false;
    if (sessionStartTime == null) return false; // No session started

    final now = timeService.now();
    final sessionDuration = now.difference(sessionStartTime!);
    final totalAllowedMinutes = sessionMinutes + graceMinutes;

    // Can complete if we're within the total allowed time
    return sessionDuration.inMinutes <= totalAllowedMinutes;
  }

  /// Check if user can start a new session
  bool canStartSession(TimeService timeService) {
    if (sessionCompletedToday) return false;
    if (isSessionActive) return false; // Already has active session

    // Check if any previous session expired today
    if (lastSessionStarted != null) {
      final now = timeService.now();
      if (timeService.isSameDay(lastSessionStarted!, now)) {
        final timeSinceLastStart = now.difference(lastSessionStarted!);
        final totalAllowedMinutes = sessionMinutes + graceMinutes;

        // If last session expired, can't start another today
        if (timeSinceLastStart.inMinutes > totalAllowedMinutes) {
          return false;
        }
      }
    }

    return true;
  }

  @override
  String getStatusText(TimeService timeService) {
    if (sessionCompletedToday) {
      return 'Session completed! 🎉';
    }

    if (sessionStartTime == null) {
      if (canStartSession(timeService)) {
        return '▶️ Click to start ${sessionMinutes}m session (+${graceMinutes}m grace)';
      } else {
        return '❌ Session expired for today';
      }
    }

    final now = timeService.now();
    final sessionDuration = now.difference(sessionStartTime!);
    final remainingSessionMinutes = sessionMinutes - sessionDuration.inMinutes;

    if (remainingSessionMinutes > 0) {
      final minutes = remainingSessionMinutes;
      final seconds = 60 - (sessionDuration.inSeconds % 60);
      return '⏱️ ${minutes}m ${seconds}s remaining';
    } else {
      // In grace period
      final totalAllowedMinutes = sessionMinutes + graceMinutes;
      final remainingGraceMinutes =
          totalAllowedMinutes - sessionDuration.inMinutes;

      if (remainingGraceMinutes > 0) {
        final minutes = remainingGraceMinutes;
        final seconds = 60 - (sessionDuration.inSeconds % 60);
        return '⏱️ ${minutes}m ${seconds}s grace period';
      } else {
        return '❌ Session expired';
      }
    }
  }

  /// Start a new session
  TimedSessionHabit startSession(TimeService timeService) {
    if (!canStartSession(timeService)) {
      throw StateError('Cannot start session at this time');
    }

    final now = timeService.now();
    return copyWith(
      sessionStartTime: now,
      lastSessionStarted: now,
    );
  }

  /// Get remaining time in current session (in minutes)
  int? getRemainingMinutes(TimeService timeService) {
    if (sessionStartTime == null) return null;

    final now = timeService.now();
    final sessionDuration = now.difference(sessionStartTime!);
    final totalAllowedMinutes = sessionMinutes + graceMinutes;
    final remainingMinutes = totalAllowedMinutes - sessionDuration.inMinutes;

    return remainingMinutes > 0 ? remainingMinutes : 0;
  }

  @override
  TimedSessionHabit complete() {
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
      sessionCompletedToday: true,
      sessionStartTime: null, // Clear active session
    );
  }

  @override
  TimedSessionHabit copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? lastCompleted,
    int? currentStreak,
    int? dailyCompletionCount,
    DateTime? lastCompletionCountReset,
    int? sessionMinutes,
    int? graceMinutes,
    DateTime? sessionStartTime,
    DateTime? lastSessionStarted,
    bool? sessionCompletedToday,
  }) {
    return TimedSessionHabit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      dailyCompletionCount: dailyCompletionCount ?? this.dailyCompletionCount,
      lastCompletionCountReset:
          lastCompletionCountReset ?? this.lastCompletionCountReset,
      sessionMinutes: sessionMinutes ?? this.sessionMinutes,
      graceMinutes: graceMinutes ?? this.graceMinutes,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      lastSessionStarted: lastSessionStarted ?? this.lastSessionStarted,
      sessionCompletedToday:
          sessionCompletedToday ?? this.sessionCompletedToday,
    );
  }

  /// Reset daily session state
  TimedSessionHabit resetDailySession(TimeService timeService) {
    return copyWith(
      sessionCompletedToday: false,
      sessionStartTime: null,
      lastSessionStarted: null,
    );
  }

  /// Factory constructor to create a new TimedSessionHabit
  factory TimedSessionHabit.create({
    required String name,
    required String description,
    required int sessionMinutes,
    int graceMinutes = 15,
  }) {
    return TimedSessionHabit(
      id: BaseHabit.generateId(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
      sessionMinutes: sessionMinutes,
      graceMinutes: graceMinutes,
    );
  }
}
