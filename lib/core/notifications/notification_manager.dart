import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_types.dart';
import 'notification_widget.dart';

/// Global notification manager for consistent notification handling
class NotificationManager {
  static OverlayEntry? _currentNotification;
  static bool _isShowing = false;

  /// Show a notification with the given configuration
  static void show(BuildContext context, NotificationConfig config) {
    // Dismiss any existing notification
    dismiss();

    final overlay = Overlay.of(context);
    _isShowing = true;

    // Create the appropriate widget based on notification type
    Widget notificationWidget;
    if (config is LoadingNotification) {
      notificationWidget = LoadingNotificationWidget(
        config: config,
      );
    } else {
      notificationWidget = UniversalNotification(
        config: config,
      );
    }

    _currentNotification = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: notificationWidget,
        ),
      ),
    );

    overlay.insert(_currentNotification!);
  }

  /// Dismiss the current notification
  static void dismiss() {
    if (_currentNotification != null && _isShowing) {
      _currentNotification?.remove();
      _currentNotification = null;
      _isShowing = false;
    }
  }

  /// Check if a notification is currently showing
  static bool get isShowing => _isShowing;
}

/// Easy-to-use notification API
class Notifications {
  /// Show a success notification
  static void success(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    NotificationManager.show(
      context,
      SuccessNotification(
        message: message,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        onDismiss: onDismiss,
      ),
    );
  }

  /// Show an error notification
  static void error(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    NotificationManager.show(
      context,
      ErrorNotification(
        message: message,
        duration: duration ?? const Duration(seconds: 4),
        action: action,
        onDismiss: onDismiss,
      ),
    );
  }

  /// Show a warning notification
  static void warning(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    NotificationManager.show(
      context,
      WarningNotification(
        message: message,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        onDismiss: onDismiss,
      ),
    );
  }

  /// Show an info notification
  static void info(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    NotificationManager.show(
      context,
      InfoNotification(
        message: message,
        duration: duration ?? const Duration(seconds: 2),
        action: action,
        onDismiss: onDismiss,
      ),
    );
  }

  /// Show a loading notification
  static void loading(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    NotificationManager.show(
      context,
      LoadingNotification(
        message: message,
        duration: duration ?? const Duration(seconds: 10),
        action: action,
        onDismiss: onDismiss,
      ),
    );
  }

  /// Show an achievement notification
  static void achievement(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    NotificationManager.show(
      context,
      AchievementNotification(
        message: message,
        duration: duration ?? const Duration(seconds: 4),
        action: action,
        onDismiss: onDismiss,
      ),
    );
  }

  /// Dismiss any currently showing notification
  static void dismiss() {
    NotificationManager.dismiss();
  }

  /// Check if a notification is currently showing
  static bool get isShowing => NotificationManager.isShowing;
}

/// Riverpod provider for notification manager
final notificationManagerProvider = Provider<NotificationManager>((ref) {
  return NotificationManager();
});

/// Extension methods for easier usage with context
extension NotificationContext on BuildContext {
  /// Show a success notification
  void showSuccess(String message, {Duration? duration, Widget? action}) {
    Notifications.success(this, message, duration: duration, action: action);
  }

  /// Show an error notification
  void showError(String message, {Duration? duration, Widget? action}) {
    Notifications.error(this, message, duration: duration, action: action);
  }

  /// Show a warning notification
  void showWarning(String message, {Duration? duration, Widget? action}) {
    Notifications.warning(this, message, duration: duration, action: action);
  }

  /// Show an info notification
  void showInfo(String message, {Duration? duration, Widget? action}) {
    Notifications.info(this, message, duration: duration, action: action);
  }

  /// Show a loading notification
  void showLoading(String message, {Duration? duration, Widget? action}) {
    Notifications.loading(this, message, duration: duration, action: action);
  }

  /// Show an achievement notification
  void showAchievement(String message, {Duration? duration, Widget? action}) {
    Notifications.achievement(this, message, duration: duration, action: action);
  }

  /// Dismiss current notification
  void dismissNotification() {
    Notifications.dismiss();
  }
}