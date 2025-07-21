import 'dart:convert';
import 'package:isar/isar.dart';
import '../services/time_service.dart';

part 'habit.g.dart';

/// Enum for different habit types
enum HabitType {
  basic('Basic Habit'),
  avoidance('Avoidance Habit'),
  stack('Habit Stack'),
  bundle('Bundle Habit'),
  interval('Interval Habit'),
  weekly('Weekly Habit');

  const HabitType(this.displayName);
  final String displayName;
}

/// Simplified Habit model with Isar persistence
@Collection()
class Habit {
  Id id = Isar.autoIncrement;

  late String name;
  
  String description = '';

  @Enumerated(EnumType.name)
  late HabitType type;

  DateTime? lastCompletedAt;

  late int streak;

  // Type-specific configuration stored as JSON string
  String? config;

  DateTime? createdAt;

  // Convenience getters for type-specific config
  @ignore
  Map<String, dynamic> get configMap {
    if (config == null) return {};
    try {
      return Map<String, dynamic>.from(
        const JsonDecoder().convert(config!)
      );
    } catch (e) {
      return {};
    }
  }

  void setConfig(Map<String, dynamic> configData) {
    config = const JsonEncoder().convert(configData);
  }

  // Weekly habit helpers
  @ignore
  int? get weekdayMask => configMap['weekdayMask'] as int?;
  set weekdayMask(int? value) {
    final map = configMap;
    if (value != null) {
      map['weekdayMask'] = value;
    } else {
      map.remove('weekdayMask');
    }
    setConfig(map);
  }

  // Interval habit helpers
  @ignore
  int? get intervalDays => configMap['intervalDays'] as int?;
  set intervalDays(int? value) {
    final map = configMap;
    if (value != null) {
      map['intervalDays'] = value;
    } else {
      map.remove('intervalDays');
    }
    setConfig(map);
  }

  // Bundle habit helpers
  @ignore
  List<String>? get bundleChildIds {
    final list = configMap['bundleChildIds'] as List<dynamic>?;
    return list?.cast<String>();
  }
  
  set bundleChildIds(List<String>? value) {
    final map = configMap;
    if (value != null) {
      map['bundleChildIds'] = value;
    } else {
      map.remove('bundleChildIds');
    }
    setConfig(map);
  }

  // Stack habit helpers
  @ignore
  List<String>? get stackChildIds {
    final list = configMap['stackChildIds'] as List<dynamic>?;
    return list?.cast<String>();
  }
  
  set stackChildIds(List<String>? value) {
    final map = configMap;
    if (value != null) {
      map['stackChildIds'] = value;
    } else {
      map.remove('stackChildIds');
    }
    setConfig(map);
  }

  @ignore
  int get currentChildIndex => configMap['currentChildIndex'] as int? ?? 0;
  set currentChildIndex(int value) {
    final map = configMap;
    map['currentChildIndex'] = value;
    setConfig(map);
  }

  Habit();

  /// Factory constructor for creating new habits
  Habit.create({
    required this.name,
    required this.type,
    Map<String, dynamic>? configData,
  }) {
    createdAt = DateTime.now();
    streak = 0;
    lastCompletedAt = null;
    if (configData != null) {
      setConfig(configData);
    }
  }

  /// Check if habit was completed today
  @ignore
  bool get isCompletedToday {
    if (lastCompletedAt == null) return false;
    final timeService = TimeService.instance;
    return timeService.isToday(lastCompletedAt!);
  }

  /// Get display name with type emoji
  @ignore
  String get displayName {
    switch (type) {
      case HabitType.stack:
        return '$name 📚';
      case HabitType.bundle:
        return '$name 📦';
      case HabitType.avoidance:
        return '$name 🚫';
      case HabitType.interval:
        return '$name ⟳';
      case HabitType.weekly:
        return '$name 📅';
      case HabitType.basic:
        return name;
    }
  }

  @override
  String toString() => 'Habit(id: $id, name: $name, type: ${type.displayName}, streak: $streak)';
}

