import 'package:flutter/material.dart';
import 'package:domain/domain.dart';

/// Extension to convert Domain HabitIcon to Flutter IconData
extension HabitIconExtension on HabitIcon {
  IconData toIconData() {
    switch (this) {
      case HabitIcon.basic:
        return Icons.check_circle_outline;
      case HabitIcon.stack:
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