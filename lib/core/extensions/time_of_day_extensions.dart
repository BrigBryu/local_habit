import 'package:flutter/material.dart';
import 'package:domain/entities/time_of_day.dart' as domain;

/// Extensions to convert between Flutter TimeOfDay and Domain TimeOfDay
extension FlutterTimeOfDayExtension on TimeOfDay {
  /// Convert Flutter TimeOfDay to Domain TimeOfDay
  domain.TimeOfDay toDomain() {
    return domain.TimeOfDay(hour: hour, minute: minute);
  }
}

extension DomainTimeOfDayExtension on domain.TimeOfDay {
  /// Convert Domain TimeOfDay to Flutter TimeOfDay
  TimeOfDay toFlutter() {
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Format using Flutter's TimeOfDay formatting
  String format(BuildContext context) {
    return toFlutter().format(context);
  }
}
