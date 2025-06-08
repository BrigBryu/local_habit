/// Simple time representation for domain layer (no Flutter dependency)
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  /// Format as 24-hour string
  String format24Hour() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Convert to minutes since midnight
  int toMinutes() {
    return hour * 60 + minute;
  }

  /// Create from minutes since midnight
  factory TimeOfDay.fromMinutes(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Check if this time is before another time
  bool isBefore(TimeOfDay other) {
    return toMinutes() < other.toMinutes();
  }

  /// Check if this time is after another time
  bool isAfter(TimeOfDay other) {
    return toMinutes() > other.toMinutes();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeOfDay && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;

  @override
  String toString() => format24Hour();
}