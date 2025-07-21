import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State class for TimeService
class TimeServiceState {
  final int dayOffset;
  final DateTime currentDate;
  final String formattedDate;
  final String offsetStatus;

  const TimeServiceState({
    required this.dayOffset,
    required this.currentDate,
    required this.formattedDate,
    required this.offsetStatus,
  });

  TimeServiceState copyWith({
    int? dayOffset,
    DateTime? currentDate,
    String? formattedDate,
    String? offsetStatus,
  }) {
    return TimeServiceState(
      dayOffset: dayOffset ?? this.dayOffset,
      currentDate: currentDate ?? this.currentDate,
      formattedDate: formattedDate ?? this.formattedDate,
      offsetStatus: offsetStatus ?? this.offsetStatus,
    );
  }
}

/// Service for managing time/date with ability to simulate date advancement for testing
class TimeService extends StateNotifier<TimeServiceState> {
  static TimeService? _instance;
  
  static TimeService get instance {
    _instance ??= TimeService._internal();
    return _instance!;
  }
  
  TimeService._internal() : super(TimeServiceState(
    dayOffset: 0,
    currentDate: DateTime.now(),
    formattedDate: _formatDate(DateTime.now()),
    offsetStatus: 'Real time',
  ));

  // Callback for when the date changes (used to trigger habit checks)
  Function()? _onDateChanged;

  // Key for storing the simulated date offset in SharedPreferences
  static const String _dateOffsetKey = 'time_service_date_offset';
  
  bool _isInitialized = false;

  /// Initialize the service by loading any stored offset
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final savedOffset = prefs.getInt(_dateOffsetKey) ?? 0;
    
    _updateState(savedOffset);
    _isInitialized = true;
  }

  /// Helper method to format date
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Update the internal state and notify listeners
  void _updateState(int newOffset) {
    final realNow = DateTime.now();
    final adjustedNow = realNow.add(Duration(days: newOffset));
    
    String offsetStatus;
    if (newOffset == 0) {
      offsetStatus = 'Real time';
    } else if (newOffset > 0) {
      offsetStatus = '+$newOffset days';
    } else {
      offsetStatus = '$newOffset days';
    }

    state = TimeServiceState(
      dayOffset: newOffset,
      currentDate: adjustedNow,
      formattedDate: _formatDate(adjustedNow),
      offsetStatus: offsetStatus,
    );
  }

  /// Get the current date (real date + any offset for testing)
  DateTime get now {
    return state.currentDate;
  }

  /// Get today's date (just date part, no time)
  DateTime get today {
    final current = state.currentDate;
    return DateTime(current.year, current.month, current.day);
  }

  /// Get yesterday's date
  DateTime get yesterday => today.subtract(const Duration(days: 1));

  /// Get the current day offset (for testing purposes)
  int get dayOffset => state.dayOffset;

  /// Set callback for when date changes (used by HabitService)
  void setDateChangeCallback(Function() callback) {
    _onDateChanged = callback;
  }

  /// Add days to the current date (for testing streak functionality)
  Future<void> addDays(int days) async {
    final newOffset = state.dayOffset + days;
    _updateState(newOffset);
    await _saveOffset(newOffset);
    await _notifyDateChanged();
  }

  /// Set a specific day offset (for testing purposes)
  Future<void> setDayOffset(int offset) async {
    _updateState(offset);
    await _saveOffset(offset);
    await _notifyDateChanged();
  }

  /// Reset to real current date (remove any offset)
  Future<void> resetToRealDate() async {
    _updateState(0);
    await _saveOffset(0);
    await _notifyDateChanged();
  }

  /// Notify that the date has changed
  Future<void> _notifyDateChanged() async {
    if (_onDateChanged != null) {
      _onDateChanged!();
    }
  }

  /// Format the current date for display
  String formatCurrentDate() {
    return state.formattedDate;
  }

  /// Check if a given date is today
  bool isToday(DateTime date) {
    final todayDate = today;
    return date.year == todayDate.year &&
           date.month == todayDate.month &&
           date.day == todayDate.day;
  }

  /// Check if a given date is yesterday
  bool isYesterday(DateTime date) {
    final yesterdayDate = yesterday;
    return date.year == yesterdayDate.year &&
           date.month == yesterdayDate.month &&
           date.day == yesterdayDate.day;
  }

  /// Get the difference in days between two dates
  int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  /// Save the current offset to SharedPreferences
  Future<void> _saveOffset(int offset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dateOffsetKey, offset);
  }

  /// Get a formatted string showing the offset status
  String getOffsetStatus() {
    return state.offsetStatus;
  }
}

/// Provider for TimeService
final timeServiceProvider = StateNotifierProvider<TimeService, TimeServiceState>((ref) {
  return TimeService.instance;
});

/// Convenience provider for just the TimeService instance
final timeServiceInstanceProvider = Provider<TimeService>((ref) {
  return ref.read(timeServiceProvider.notifier);
});