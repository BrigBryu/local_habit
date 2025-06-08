/// Service to manage time for testing and simulation
class TimeService {
  static final TimeService _instance = TimeService._internal();
  factory TimeService() => _instance;
  TimeService._internal();

  DateTime? _simulatedDate;

  /// Get the current date (real or simulated)
  DateTime now() {
    return _simulatedDate ?? DateTime.now();
  }

  /// Set a simulated date for testing
  void setSimulatedDate(DateTime date) {
    _simulatedDate = date;
    print('📅 Simulated date set to: ${_formatDate(date)}');
  }

  /// Advance to the next day
  void nextDay() {
    final currentDate = now();
    _simulatedDate = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day + 1,
    );
    print('📅 Advanced to next day: ${_formatDate(_simulatedDate!)}');
  }

  /// Reset to real time
  void resetToRealTime() {
    _simulatedDate = null;
    print('📅 Reset to real time: ${_formatDate(DateTime.now())}');
  }

  /// Get today as date-only (for comparison)
  DateTime today() {
    final current = now();
    return DateTime(current.year, current.month, current.day);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Check if two dates are the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Calculate days between two dates
  int daysBetween(DateTime date1, DateTime date2) {
    final d1 = DateTime(date1.year, date1.month, date1.day);
    final d2 = DateTime(date2.year, date2.month, date2.day);
    return d2.difference(d1).inDays;
  }
}