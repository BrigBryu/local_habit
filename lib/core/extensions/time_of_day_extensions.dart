import 'package:flutter/material.dart' as flutter;
import 'package:domain/domain.dart' as domain;

/// Extensions to convert between Flutter TimeOfDay and Domain TimeOfDay
extension FlutterTimeOfDayExtension on flutter.TimeOfDay {
  /// Convert Flutter TimeOfDay to Domain TimeOfDay
  domain.TimeOfDay toDomain() {
    return domain.TimeOfDay(hour: hour, minute: minute);
  }
}

extension DomainTimeOfDayExtension on domain.TimeOfDay {
  /// Convert Domain TimeOfDay to Flutter TimeOfDay
  flutter.TimeOfDay toFlutter() {
    return flutter.TimeOfDay(hour: hour, minute: minute);
  }

  /// Format using Flutter's TimeOfDay formatting
  String format(flutter.BuildContext context) {
    return toFlutter().format(context);
  }
}