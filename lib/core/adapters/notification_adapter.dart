import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/notifications/notifications.dart';
import 'theme_adapter.dart';

/// Adapter to bridge between app's notification system and shared notification system
class NotificationAdapter {
  static BaseNotificationManager? _manager;
  static BaseNotificationService? _service;
  static bool _initialized = false;

  /// Initialize the notification adapter with app theme colors
  static void initialize(dynamic ref) {
    if (_initialized) return;
    
    final colors = _getColorsFromRef(ref);
    
    _manager = BaseNotificationManager(
      colors: colors,
      config: const NotificationConfig(
        animation: NotificationAnimation(
          entranceDuration: Duration(milliseconds: 350),
          exitDuration: Duration(milliseconds: 300),
          entranceCurve: Curves.elasticOut,
          exitCurve: Curves.easeInQuart,
        ),
        gesture: NotificationGesture(
          enableSwipeToDismiss: true,
          swipeThreshold: 4.0,
        ),
        position: NotificationPosition(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
        ),
      ),
    );
    
    _service = BaseNotificationService(manager: _manager!);
    
    // Initialize static helpers for backward compatibility
    Notifications.initialize(manager: _manager!, service: _service!);
    
    _initialized = true;
  }

  /// Get the notification manager instance
  static BaseNotificationManager get manager {
    if (!_initialized) {
      throw NotificationException('NotificationAdapter not initialized. Call initialize() first.');
    }
    return _manager!;
  }

  /// Get the notification service instance
  static BaseNotificationService get service {
    if (!_initialized) {
      throw NotificationException('NotificationAdapter not initialized. Call initialize() first.');
    }
    return _service!;
  }

  /// Check if adapter is initialized
  static bool get isInitialized => _initialized;

  /// Force reinitialization (useful for theme changes)
  static void reinitialize(dynamic ref) {
    _initialized = false;
    initialize(ref);
  }

  /// Helper to get colors from different ref types
  static dynamic _getColorsFromRef(dynamic ref) {
    try {
      if (ref is WidgetRef) {
        return ThemeAdapter.getCompatibleColors(ref);
      } else if (ref is ProviderRef) {
        // For ProviderRef, we need to handle differently
        return null; // Will use fallback colors
      }
      return null;
    } catch (e) {
      return null; // Fallback to default colors
    }
  }
}

/// Provider for notification adapter
final notificationAdapterProvider = Provider<NotificationAdapter>((ref) {
  // Initialize adapter when provider is first accessed
  NotificationAdapter.initialize(ref);
  return NotificationAdapter();
});

/// Provider that watches for theme changes and reinitializes notifications
final notificationAdapterWatcherProvider = Provider<NotificationAdapter>((ref) {
  // Watch theme changes
  ref.watch(themeAdapterProvider);
  
  // Reinitialize when theme changes
  if (NotificationAdapter.isInitialized) {
    NotificationAdapter.reinitialize(ref);
  } else {
    NotificationAdapter.initialize(ref);
  }
  
  return NotificationAdapter();
});