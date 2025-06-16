import 'package:flutter/material.dart';
import 'package:domain/domain.dart';

/// Extension to convert Domain HabitIcon to Flutter IconData
extension HabitIconExtension on HabitIcon {
  IconData toIconData() {
    switch (this) {
      case HabitIcon.basic:
        return Icons.check_circle_outline;
      case HabitIcon.exercise:
        return Icons.directions_run;
      case HabitIcon.water:
        return Icons.local_drink;
      case HabitIcon.book:
        return Icons.book;
      case HabitIcon.sleep:
        return Icons.bedtime;
      case HabitIcon.meditation:
        return Icons.self_improvement;
      case HabitIcon.food:
        return Icons.restaurant;
      case HabitIcon.work:
        return Icons.work;
      case HabitIcon.social:
        return Icons.people;
      case HabitIcon.creative:
        return Icons.brush;
      case HabitIcon.learning:
        return Icons.school;
      case HabitIcon.layers:
        return Icons.layers;
      case HabitIcon.alarm:
        return Icons.alarm;
      case HabitIcon.timer:
        return Icons.timer;
      case HabitIcon.schedule:
        return Icons.schedule;
    }
  }
}
