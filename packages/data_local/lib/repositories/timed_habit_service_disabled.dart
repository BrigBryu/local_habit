// ignore_for_file: directives_ordering, unused_import, dead_code, unused_local_variable, undefined_enum_constant, undefined_getter, undefined_method, unused_field, unreachable_code

// TODO(bridger): Re-enable after rewrite. Currently EXCLUDED.
// TimedHabitService is temporarily disabled to resolve TimeOfDay conflicts and
// simplify the domain model. Will be re-enabled in a future iteration.

import 'package:flutter/material.dart';
import 'package:domain/entities/habit.dart';
import 'package:domain/services/time_service.dart';
import 'habit_service.dart';
import 'package:domain/services/level_service.dart';

/// Service to handle all time-based habits (timed stacks, sessions, windows)
/// NOTE: This service is DISABLED to avoid compilation errors with undefined enums/methods
class TimedHabitService {
  static final TimedHabitService _instance = TimedHabitService._internal();
  factory TimedHabitService() => _instance;
  TimedHabitService._internal();

  final Map<String, DateTime> _triggeredAlarms = {};
  final Map<String, bool> _timedOut = {};
  final Map<String, DateTime> _activeSessions = {};

  // ALL METHODS DISABLED - return stub values to prevent compilation errors

  bool shouldTriggerAlarm(Habit habit) => false;
  void triggerAlarm(String habitId) {}
  bool hasTimedOut(Habit habit) => false;
  bool isTimedHabitActive(String habitId) => false;
  Duration? getRemainingTime(Habit habit) => null;
  void processTimeout(String habitId) {}
  void updateTimedHabits(List<Habit> habits) {}

  // Timed session methods - all disabled
  Habit? startSession(Habit habit) => null;
  bool isSessionActive(String habitId) => false;
  Duration? getSessionRemainingTime(Habit habit) => null;
  bool hasSessionExpired(Habit habit) => false;
  Habit completeSession(Habit habit) => habit;
  void expireSession(String habitId) {}

  // Time window methods - all disabled
  bool isTimeWindowAvailable(Habit habit) => false;
  Duration? getTimeUntilWindowOpens(Habit habit) => null;
  String? validateTimeWindowCompletion(Habit habit) => null;

  // Universal methods - all disabled
  List<Habit> updateAllTimedHabits(List<Habit> habits) => [];
  String getTimedHabitStatus(Habit habit) => '';

  // Helper methods - all disabled
  void resetDailyState() {}
  Map<String, dynamic> getDebugInfo() => {
    'service': 'disabled',
    'triggeredAlarms': 0,
    'timedOutHabits': 0,
    'activeAlarms': 0,
    'activeSessions': 0,
  };
}

// Helper function - disabled
bool isHabitCompletedToday(Habit habit) => false;