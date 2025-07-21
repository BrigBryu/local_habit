import 'package:flutter/material.dart';

/// Abstract contract for notification configurations
abstract class INotificationConfig {
  /// Message to display
  String get message;
  
  /// Duration to show notification
  Duration get duration;
  
  /// Optional action widget
  Widget? get action;
  
  /// Callback when notification is dismissed
  VoidCallback? get onDismiss;
  
  /// Get visual style for this notification
  NotificationStyle getStyle(dynamic colors);
}

/// Visual style configuration for notifications
class NotificationStyle {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;
  final Color? actionColor;
  final Color? borderColor;
  final double? elevation;

  const NotificationStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.icon,
    this.actionColor,
    this.borderColor,
    this.elevation,
  });
}

/// Abstract contract for notification widgets
abstract class INotificationWidget extends Widget {
  /// Configuration for this notification
  INotificationConfig get config;
  
  /// Dismiss callback
  VoidCallback? get onDismiss;
}

/// Abstract contract for notification manager
abstract class INotificationManager {
  /// Show a notification
  void show(BuildContext context, INotificationConfig config);
  
  /// Dismiss current notification
  void dismiss();
  
  /// Check if notification is currently showing
  bool get isShowing;
  
  /// Clear all notifications
  void clear();
}

/// Abstract contract for notification service
abstract class INotificationService {
  /// Show success notification
  void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  });
  
  /// Show error notification
  void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  });
  
  /// Show warning notification
  void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  });
  
  /// Show info notification
  void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  });
  
  /// Show loading notification
  void showLoading(
    BuildContext context,
    String message, {
    Duration? duration,
    Widget? action,
    VoidCallback? onDismiss,
  });
  
  /// Dismiss current notification
  void dismiss();
  
  /// Check if notification is showing
  bool get isShowing;
}

/// Notification animation configuration
class NotificationAnimation {
  final Duration entranceDuration;
  final Duration exitDuration;
  final Curve entranceCurve;
  final Curve exitCurve;
  final Offset slideBegin;
  final Offset slideEnd;
  final double fadeBegin;
  final double fadeEnd;
  final double scaleBegin;
  final double scaleEnd;

  const NotificationAnimation({
    this.entranceDuration = const Duration(milliseconds: 350),
    this.exitDuration = const Duration(milliseconds: 300),
    this.entranceCurve = Curves.elasticOut,
    this.exitCurve = Curves.easeInQuart,
    this.slideBegin = const Offset(0, 1.2),
    this.slideEnd = Offset.zero,
    this.fadeBegin = 0.0,
    this.fadeEnd = 1.0,
    this.scaleBegin = 0.8,
    this.scaleEnd = 1.0,
  });
}

/// Notification gesture configuration
class NotificationGesture {
  final bool enableSwipeToDismiss;
  final double swipeThreshold;
  final bool enableTapToDismiss;
  final bool enableDoubleTapAction;

  const NotificationGesture({
    this.enableSwipeToDismiss = true,
    this.swipeThreshold = 4.0,
    this.enableTapToDismiss = false,
    this.enableDoubleTapAction = false,
  });
}

/// Notification positioning configuration
class NotificationPosition {
  final AlignmentGeometry alignment;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double? maxWidth;
  final double? minHeight;

  const NotificationPosition({
    this.alignment = Alignment.bottomCenter,
    this.margin = const EdgeInsets.all(16),
    this.padding = const EdgeInsets.all(16),
    this.maxWidth,
    this.minHeight,
  });
}

/// Complete notification configuration
class NotificationConfig {
  final NotificationAnimation animation;
  final NotificationGesture gesture;
  final NotificationPosition position;
  final bool dismissOnTap;
  final bool showCloseButton;
  final bool queueNotifications;

  const NotificationConfig({
    this.animation = const NotificationAnimation(),
    this.gesture = const NotificationGesture(),
    this.position = const NotificationPosition(),
    this.dismissOnTap = false,
    this.showCloseButton = false,
    this.queueNotifications = false,
  });
}

/// Notification type enumeration
enum NotificationType {
  success,
  error,
  warning,
  info,
  loading,
  achievement,
  custom,
}

/// Exception for notification-related errors
class NotificationException implements Exception {
  final String message;
  final NotificationType? type;
  final dynamic originalError;

  const NotificationException(
    this.message, {
    this.type,
    this.originalError,
  });

  @override
  String toString() => 'NotificationException: $message${type != null ? ' (type: $type)' : ''}';
}