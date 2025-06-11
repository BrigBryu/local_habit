// ignore_for_file: directives_ordering, unused_import, dead_code, unused_local_variable

// TODO(bridger): Re-enable after rewrite. Currently EXCLUDED.
// TimedHabitService is temporarily disabled to resolve TimeOfDay conflicts and
// simplify the domain model. Will be re-enabled in a future iteration.

import 'package:flutter/material.dart';
import 'package:domain/entities/habit.dart';
import 'package:domain/services/time_service.dart';
import 'habit_service.dart';
import 'package:domain/services/level_service.dart';

/// Service to handle all time-based habits (timed stacks, sessions, windows)
class TimedHabitService {
  static final TimedHabitService _instance = TimedHabitService._internal();
  factory TimedHabitService() => _instance;
  TimedHabitService._internal();

  final Map<String, DateTime> _triggeredAlarms = {};
  final Map<String, bool> _timedOut = {};
  final Map<String, DateTime> _activeSessions = {}; // For timed sessions

  /// Check if alarm should trigger for an alarm habit
  bool shouldTriggerAlarm(Habit habit) {
    if (habit.type != HabitType.alarmHabit || habit.alarmTime == null) return false;
    
    final timeService = TimeService();
    final now = timeService.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Create alarm datetime for today
    final alarmDateTime = DateTime(
      today.year,
      today.month, 
      today.day,
      habit.alarmTime!.hour,
      habit.alarmTime!.minute,
    );
    
    // Check if we've passed the alarm time and haven't triggered today
    final alreadyTriggeredToday = _triggeredAlarms[habit.id] != null &&
        timeService.isSameDay(_triggeredAlarms[habit.id]!, now);
    
    return now.isAfter(alarmDateTime) && !alreadyTriggeredToday;
  }

  /// Trigger alarm for a habit
  void triggerAlarm(String habitId) {
    final timeService = TimeService();
    _triggeredAlarms[habitId] = timeService.now();
    _timedOut[habitId] = false;
    
    print('⏰ ALARM! Timed habit triggered: $habitId');
  }

  /// Check if an alarm habit has expired (timeout reached)
  bool hasTimedOut(Habit habit) {
    if (habit.type != HabitType.alarmHabit || 
        habit.timeoutMinutes == null ||
        _triggeredAlarms[habit.id] == null) return false;
    
    final timeService = TimeService();
    final alarmTime = _triggeredAlarms[habit.id]!;
    final timeoutTime = alarmTime.add(Duration(minutes: habit.timeoutMinutes!));
    
    return timeService.now().isAfter(timeoutTime);
  }

  /// Check if a timed habit is currently active (alarm triggered but not timed out)
  bool isTimedHabitActive(String habitId) {
    return _triggeredAlarms[habitId] != null && 
           !(_timedOut[habitId] ?? false);
  }

  /// Get remaining time for active alarm habit
  Duration? getRemainingTime(Habit habit) {
    if (habit.type != HabitType.alarmHabit || 
        habit.timeoutMinutes == null ||
        _triggeredAlarms[habit.id] == null) return null;
    
    final timeService = TimeService();
    final alarmTime = _triggeredAlarms[habit.id]!;
    final timeoutTime = alarmTime.add(Duration(minutes: habit.timeoutMinutes!));
    final remaining = timeoutTime.difference(timeService.now());
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Process timeout for a habit (no penalty)
  void processTimeout(String habitId) {
    if (_timedOut[habitId] == true) return; // Already processed
    
    _timedOut[habitId] = true;
    print('⏰ Alarm habit window expired: $habitId');
  }

  /// Check all timed habits for alarms and timeouts
  void updateTimedHabits(List<Habit> habits) {
    for (final habit in habits) {
      if (habit.type == HabitType.alarmHabit) {
        // Check for alarm trigger
        if (shouldTriggerAlarm(habit)) {
          triggerAlarm(habit.id);
        }
        
        // Check for timeout
        if (isTimedHabitActive(habit.id) && hasTimedOut(habit)) {
          processTimeout(habit.id);
        }
      }
    }
  }


  // ========== TIMED SESSION METHODS ==========
  
  /// Start a timed session (returns updated habit or null if cannot start)
  Habit? startSession(Habit habit) {
    if (habit.type != HabitType.timedSession) return null;
    
    // Check if already started today
    if (habit.hasStartedSessionToday()) {
      print('⏱️ Session already started today for habit: ${habit.id}');
      return null;
    }
    
    final timeService = TimeService();
    _activeSessions[habit.id] = timeService.now();
    print('⏱️ Timed session started for habit: ${habit.id}');
    
    return habit.startTimedSession();
  }

  /// Check if a session is active
  bool isSessionActive(String habitId) {
    return _activeSessions[habitId] != null;
  }

  /// Get remaining time for active session (includes 15-minute grace period)
  Duration? getSessionRemainingTime(Habit habit) {
    if (habit.type != HabitType.timedSession || 
        habit.timeoutMinutes == null ||
        _activeSessions[habit.id] == null) return null;
    
    final timeService = TimeService();
    final sessionStart = _activeSessions[habit.id]!;
    final gracePeriod = Duration(minutes: 15); // 15-minute grace period
    final sessionEnd = sessionStart.add(Duration(minutes: habit.timeoutMinutes!)).add(gracePeriod);
    final remaining = sessionEnd.difference(timeService.now());
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if session has expired
  bool hasSessionExpired(Habit habit) {
    final remaining = getSessionRemainingTime(habit);
    return remaining != null && remaining <= Duration.zero;
  }

  /// Complete a timed session (returns updated habit)
  Habit completeSession(Habit habit) {
    _activeSessions.remove(habit.id);
    print('✅ Timed session completed: ${habit.id}');
    
    return habit.completeTimedSession();
  }

  /// Expire a timed session (no penalty)
  void expireSession(String habitId) {
    _activeSessions.remove(habitId);
    print('⏱️ Timed session expired: $habitId');
  }

  // ========== TIME WINDOW METHODS ==========
  
  /// Check if a time window habit is currently available
  bool isTimeWindowAvailable(Habit habit) {
    if ((habit.type != HabitType.timeWindow && habit.type != HabitType.dailyTimeWindow) ||
        habit.windowStartTime == null ||
        habit.windowEndTime == null) return false;
    
    // For daily time windows, no need to check available days
    if (habit.type == HabitType.dailyTimeWindow) {
      return _isWithinTimeWindow(habit);
    }
    
    // For regular time windows, check available days
    if (habit.availableDays == null) return false;
    
    final timeService = TimeService();
    final now = timeService.now();
    
    // Check if today is an available day (1=Monday, 7=Sunday)
    final todayWeekday = now.weekday;
    if (!habit.availableDays!.contains(todayWeekday)) return false;
    
    return _isWithinTimeWindow(habit);
  }

  /// Helper method to check if current time is within the time window
  bool _isWithinTimeWindow(Habit habit) {
    final timeService = TimeService();
    final now = timeService.now();
    final nowTime = TimeOfDay.fromDateTime(now);
    final startMinutes = habit.windowStartTime!.hour * 60 + habit.windowStartTime!.minute;
    final endMinutes = habit.windowEndTime!.hour * 60 + habit.windowEndTime!.minute;
    final nowMinutes = nowTime.hour * 60 + nowTime.minute;
    
    // Handle overnight windows (e.g., 22:00-06:00)
    if (startMinutes > endMinutes) {
      return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
    } else {
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    }
  }

  /// Get time until window opens
  Duration? getTimeUntilWindowOpens(Habit habit) {
    if ((habit.type != HabitType.timeWindow && habit.type != HabitType.dailyTimeWindow) ||
        habit.windowStartTime == null) return null;
    
    // For daily time windows, calculate next occurrence today or tomorrow
    if (habit.type == HabitType.dailyTimeWindow) {
      return _getTimeUntilDailyWindowOpens(habit);
    }
    
    // For regular time windows, check available days
    if (habit.availableDays == null) return null;
    
    final timeService = TimeService();
    final now = timeService.now();
    
    // Find next available day
    for (int i = 0; i < 7; i++) {
      final checkDay = now.add(Duration(days: i));
      if (habit.availableDays!.contains(checkDay.weekday)) {
        final windowStart = DateTime(
          checkDay.year, checkDay.month, checkDay.day,
          habit.windowStartTime!.hour, habit.windowStartTime!.minute,
        );
        
        if (windowStart.isAfter(now)) {
          return windowStart.difference(now);
        }
      }
    }
    
    return null;
  }

  /// Helper method for daily time window next opening
  Duration? _getTimeUntilDailyWindowOpens(Habit habit) {
    final timeService = TimeService();
    final now = timeService.now();
    
    // Try today first
    final todayWindowStart = DateTime(
      now.year, now.month, now.day,
      habit.windowStartTime!.hour, habit.windowStartTime!.minute,
    );
    
    if (todayWindowStart.isAfter(now)) {
      return todayWindowStart.difference(now);
    }
    
    // Try tomorrow
    final tomorrowWindowStart = DateTime(
      now.year, now.month, now.day + 1,
      habit.windowStartTime!.hour, habit.windowStartTime!.minute,
    );
    
    return tomorrowWindowStart.difference(now);
  }

  /// Validate if a time window habit can be completed right now
  String? validateTimeWindowCompletion(Habit habit) {
    if (habit.type != HabitType.timeWindow && habit.type != HabitType.dailyTimeWindow) {
      return null; // Not a time window habit
    }
    
    if (isTimeWindowAvailable(habit)) {
      return null; // Can be completed
    }
    
    // Check if window has passed today
    final timeService = TimeService();
    final now = timeService.now();
    
    if (habit.type == HabitType.dailyTimeWindow) {
      final todayWindowEnd = DateTime(
        now.year, now.month, now.day,
        habit.windowEndTime!.hour, habit.windowEndTime!.minute,
      );
      
      // Handle overnight windows
      if (habit.windowStartTime!.hour > habit.windowEndTime!.hour) {
        todayWindowEnd.add(const Duration(days: 1));
      }
      
      if (now.isAfter(todayWindowEnd)) {
        return '⏰ Today\'s window has closed. Try again tomorrow.';
      } else {
        final timeUntilOpen = _getTimeUntilDailyWindowOpens(habit);
        if (timeUntilOpen != null) {
          final hours = timeUntilOpen.inHours;
          final minutes = timeUntilOpen.inMinutes % 60;
          return '⏰ Window opens in ${hours}h ${minutes}m';
        }
      }
    } else if (habit.type == HabitType.timeWindow) {
      // Check if today is not an available day
      if (habit.availableDays != null && !habit.availableDays!.contains(now.weekday)) {
        return '📅 Not available today';
      }
      
      // Check if window has passed today
      final todayWindowEnd = DateTime(
        now.year, now.month, now.day,
        habit.windowEndTime!.hour, habit.windowEndTime!.minute,
      );
      
      if (now.isAfter(todayWindowEnd)) {
        final timeUntilOpen = getTimeUntilWindowOpens(habit);
        if (timeUntilOpen != null) {
          final hours = timeUntilOpen.inHours;
          final minutes = timeUntilOpen.inMinutes % 60;
          return '⏰ Next window in ${hours}h ${minutes}m';
        }
      } else {
        final timeUntilOpen = getTimeUntilWindowOpens(habit);
        if (timeUntilOpen != null) {
          final hours = timeUntilOpen.inHours;
          final minutes = timeUntilOpen.inMinutes % 60;
          return '⏰ Window opens in ${hours}h ${minutes}m';
        }
      }
    }
    
    return '⏰ Outside time window';
  }

  // ========== UNIVERSAL METHODS ==========

  /// Update all time-based habits and return any updated habits
  List<Habit> updateAllTimedHabits(List<Habit> habits) {
    List<Habit> updatedHabits = [];
    
    for (final habit in habits) {
      // Update alarm habits
      if (habit.type == HabitType.alarmHabit) {
        if (shouldTriggerAlarm(habit)) {
          triggerAlarm(habit.id);
        }
        
        if (isTimedHabitActive(habit.id) && hasTimedOut(habit)) {
          processTimeout(habit.id);
        }
      }
      
      // Update timed sessions
      if (habit.type == HabitType.timedSession) {
        if (isSessionActive(habit.id) && hasSessionExpired(habit)) {
          // Auto-complete the session when timer expires
          final updatedHabit = completeSession(habit);
          updatedHabits.add(updatedHabit);
          expireSession(habit.id);
        }
      }
    }
    
    return updatedHabits;
  }

  /// Get status text for any time-based habit
  String getTimedHabitStatus(Habit habit) {
    final habitService = HabitService();
    
    // If completed today, show completion
    if (habitService.isCompletedToday(habit.id)) {
      return '✅ Completed';
    }
    
    switch (habit.type) {
      case HabitType.alarmHabit:
        return _getAlarmHabitStatus(habit);
      case HabitType.timedSession:
        return _getTimedSessionStatus(habit);
      case HabitType.timeWindow:
      case HabitType.dailyTimeWindow:
        return _getTimeWindowStatus(habit);
      default:
        return '';
    }
  }

  String _getAlarmHabitStatus(Habit habit) {
    if (_timedOut[habit.id] == true) {
      return '❌ Window expired';
    }
    
    if (isTimedHabitActive(habit.id)) {
      final remaining = getRemainingTime(habit);
      if (remaining != null && remaining > Duration.zero) {
        final minutes = remaining.inMinutes;
        final seconds = remaining.inSeconds % 60;
        return '⏳ ${minutes}m ${seconds}s remaining';
      }
    }
    
    if (habit.alarmTime != null) {
      final timeService = TimeService();
      final now = timeService.now();
      final alarmDateTime = DateTime(
        now.year, now.month, now.day,
        habit.alarmTime!.hour, habit.alarmTime!.minute,
      );
      
      if (now.isBefore(alarmDateTime)) {
        return '⏰ Alarm at ${habit.alarmTime!.format24Hour()}';
      }
    }
    
    return '❌ Missed';
  }

  String _getTimedSessionStatus(Habit habit) {
    // If session completed today but not yet checked off
    if (habit.sessionCompletedToday && !isHabitCompletedToday(habit)) {
      return '✅ Ready to check off';
    }
    
    if (isSessionActive(habit.id)) {
      final remaining = getSessionRemainingTime(habit);
      if (remaining != null && remaining > Duration.zero) {
        final minutes = remaining.inMinutes;
        final seconds = remaining.inSeconds % 60;
        final sessionDuration = habit.timeoutMinutes ?? 0;
        
        // Show if we're in grace period (beyond original session time)
        final sessionStart = _activeSessions[habit.id]!;
        final originalEnd = sessionStart.add(Duration(minutes: sessionDuration));
        final timeService = TimeService();
        final isInGracePeriod = timeService.now().isAfter(originalEnd);
        
        if (isInGracePeriod) {
          return '⏱️ ${minutes}m ${seconds}s grace period';
        } else {
          return '⏱️ ${minutes}m ${seconds}s remaining';
        }
      }
    }
    
    // Check if already started today
    if (habit.hasStartedSessionToday()) {
      return '⏱️ Session started today';
    }
    
    final duration = habit.timeoutMinutes ?? 0;
    return '▶️ Click to start ${duration}m session (+15m grace)';
  }

  String _getTimeWindowStatus(Habit habit) {
    if (isTimeWindowAvailable(habit)) {
      final timeService = TimeService();
      final now = timeService.now();
      final endTime = habit.windowEndTime!;
      final endDateTime = DateTime(
        now.year, now.month, now.day,
        endTime.hour, endTime.minute,
      );
      
      // Handle overnight windows
      if (habit.windowStartTime!.hour > endTime.hour) {
        endDateTime.add(const Duration(days: 1));
      }
      
      final remaining = endDateTime.difference(now);
      if (remaining > Duration.zero) {
        final hours = remaining.inHours;
        final minutes = remaining.inMinutes % 60;
        return '🟢 Available (${hours}h ${minutes}m left)';
      }
    }
    
    final timeUntilOpen = getTimeUntilWindowOpens(habit);
    if (timeUntilOpen != null) {
      final hours = timeUntilOpen.inHours;
      final minutes = timeUntilOpen.inMinutes % 60;
      return '🔒 Opens in ${hours}h ${minutes}m';
    }
    
    return '🔒 Not available today';
  }

  /// Reset daily state (call when day advances)
  void resetDailyState() {
    _triggeredAlarms.clear();
    _timedOut.clear();
    _activeSessions.clear();
    print('🔄 All timed habit states reset');
  }

  /// Get debug info for timed habits
  Map<String, dynamic> getDebugInfo() {
    return {
      'triggeredAlarms': _triggeredAlarms.length,
      'timedOutHabits': _timedOut.values.where((v) => v).length,
      'activeAlarms': _triggeredAlarms.keys.where((id) => isTimedHabitActive(id)).length,
      'activeSessions': _activeSessions.length,
    };
  }
}