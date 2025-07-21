import 'package:flutter/material.dart';
import 'notification_contracts.dart';
import 'base_notification_types.dart';
import 'base_notification_widget.dart';

/// Base notification manager implementation
class BaseNotificationManager implements INotificationManager {
  static OverlayEntry? _currentNotification;
  static bool _isShowing = false;
  static final List<INotificationConfig> _queue = [];

  final NotificationConfig config;
  final dynamic colors;

  const BaseNotificationManager({
    this.config = const NotificationConfig(),
    this.colors,
  });

  @override
  void show(BuildContext context, INotificationConfig config) {
    if (this.config.queueNotifications && _isShowing) {
      _queue.add(config);
      return;
    }

    // Dismiss any existing notification
    dismiss();

    final overlay = Overlay.of(context);
    _isShowing = true;

    // Create the appropriate widget based on configuration type
    Widget notificationWidget;
    if (config is LoadingNotificationConfig) {
      notificationWidget = LoadingNotificationWidget(
        config: config,
        colors: colors,
        animation: this.config.animation,
        position: this.config.position,
        onDismiss: () => _handleDismiss(),
      );
    } else {
      notificationWidget = BaseNotificationWidget(
        config: config,
        colors: colors,
        animation: this.config.animation,
        gesture: this.config.gesture,
        position: this.config.position,
        onDismiss: () => _handleDismiss(),
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

  @override
  void dismiss() {
    if (_currentNotification != null && _isShowing) {
      _currentNotification?.remove();
      _currentNotification = null;
      _isShowing = false;
    }
  }

  @override
  bool get isShowing => _isShowing;

  @override
  void clear() {
    dismiss();
    _queue.clear();
  }

  void _handleDismiss() {
    dismiss();
    
    // Show next notification in queue if any
    if (_queue.isNotEmpty && config.queueNotifications) {
      final nextConfig = _queue.removeAt(0);
      // Use the current context (this is a limitation of the overlay approach)
      // In a real implementation, you'd want to maintain context reference
      // show(context, nextConfig);
    }
  }
}

/// Easy-to-use notification service implementation
class BaseNotificationService implements INotificationService {
  final INotificationManager _manager;

  const BaseNotificationService({
    required INotificationManager manager,
  }) : _manager = manager;

  @override
  void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    _manager.show(
      context,
      SuccessNotificationConfig(
        message: message,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    _manager.show(
      context,
      ErrorNotificationConfig(
        message: message,
        duration: duration ?? const Duration(seconds: 4),
        action: action,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    _manager.show(
      context,
      WarningNotificationConfig(
        message: message,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    _manager.show(
      context,
      InfoNotificationConfig(
        message: message,
        duration: duration ?? const Duration(seconds: 2),
        action: action,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  void showLoading(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    _manager.show(
      context,
      LoadingNotificationConfig(
        message: message,
        duration: duration ?? const Duration(seconds: 10),
        action: action,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  void dismiss() {
    _manager.dismiss();
  }

  @override
  bool get isShowing => _manager.isShowing;
}

/// Static notification helpers (for backward compatibility)
class Notifications {
  static INotificationManager? _manager;
  static INotificationService? _service;

  /// Initialize with manager and service
  static void initialize({
    required INotificationManager manager,
    required INotificationService service,
  }) {
    _manager = manager;
    _service = service;
  }

  /// Show success notification
  static void success(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    _service?.showSuccess(
      context,
      message,
      duration: duration,
      action: action,
      onDismiss: onDismiss,
    );
  }

  /// Show error notification
  static void error(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    _service?.showError(
      context,
      message,
      duration: duration,
      action: action,
      onDismiss: onDismiss,
    );
  }

  /// Show warning notification
  static void warning(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    _service?.showWarning(
      context,
      message,
      duration: duration,
      action: action,
      onDismiss: onDismiss,
    );
  }

  /// Show info notification
  static void info(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    _service?.showInfo(
      context,
      message,
      duration: duration,
      action: action,
      onDismiss: onDismiss,
    );
  }

  /// Show loading notification
  static void loading(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    _service?.showLoading(
      context,
      message,
      duration: duration,
      action: action,
      onDismiss: onDismiss,
    );
  }

  /// Dismiss current notification
  static void dismiss() {
    _manager?.dismiss();
  }

  /// Check if notification is showing
  static bool get isShowing => _manager?.isShowing ?? false;
}

/// Context extensions for easier usage
extension NotificationContextExtensions on BuildContext {
  /// Show success notification
  void showSuccess(String message, {Duration? duration, Widget? action}) {
    Notifications.success(this, message, duration: duration, action: action);
  }

  /// Show error notification
  void showError(String message, {Duration? duration, Widget? action}) {
    Notifications.error(this, message, duration: duration, action: action);
  }

  /// Show warning notification
  void showWarning(String message, {Duration? duration, Widget? action}) {
    Notifications.warning(this, message, duration: duration, action: action);
  }

  /// Show info notification
  void showInfo(String message, {Duration? duration, Widget? action}) {
    Notifications.info(this, message, duration: duration, action: action);
  }

  /// Show loading notification
  void showLoading(String message, {Duration? duration, Widget? action}) {
    Notifications.loading(this, message, duration: duration, action: action);
  }

  /// Dismiss current notification
  void dismissNotification() {
    Notifications.dismiss();
  }
}