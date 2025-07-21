import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

/// Base notification configuration
abstract class NotificationConfig {
  final String message;
  final Duration duration;
  final Widget? action;
  final VoidCallback? onDismiss;

  const NotificationConfig({
    required this.message,
    this.duration = const Duration(seconds: 3),
    this.action,
    this.onDismiss,
  });

  /// Get the notification style based on type
  NotificationStyle getStyle(dynamic colors);
}

/// Notification visual style configuration
class NotificationStyle {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;
  final Color? actionColor;

  const NotificationStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.icon,
    this.actionColor,
  });
}

/// Success notification - for positive actions
class SuccessNotification extends NotificationConfig {
  const SuccessNotification({
    required super.message,
    super.duration = const Duration(seconds: 3),
    super.action,
    super.onDismiss,
  });

  @override
  NotificationStyle getStyle(dynamic colors) {
    return NotificationStyle(
      backgroundColor: colors.success,
      textColor: Colors.white,
      iconColor: Colors.white,
      icon: Icons.check_circle_outline,
      actionColor: Colors.white,
    );
  }
}

/// Error notification - for failures and errors
class ErrorNotification extends NotificationConfig {
  const ErrorNotification({
    required super.message,
    super.duration = const Duration(seconds: 4),
    super.action,
    super.onDismiss,
  });

  @override
  NotificationStyle getStyle(dynamic colors) {
    return NotificationStyle(
      backgroundColor: colors.error,
      textColor: Colors.white,
      iconColor: Colors.white,
      icon: Icons.error_outline,
      actionColor: Colors.white,
    );
  }
}

/// Warning notification - for important information
class WarningNotification extends NotificationConfig {
  const WarningNotification({
    required super.message,
    super.duration = const Duration(seconds: 3),
    super.action,
    super.onDismiss,
  });

  @override
  NotificationStyle getStyle(dynamic colors) {
    return NotificationStyle(
      backgroundColor: colors.draculaOrange,
      textColor: Colors.white,
      iconColor: Colors.white,
      icon: Icons.warning_amber_outlined,
      actionColor: Colors.white,
    );
  }
}

/// Info notification - for general information
class InfoNotification extends NotificationConfig {
  const InfoNotification({
    required super.message,
    super.duration = const Duration(seconds: 2),
    super.action,
    super.onDismiss,
  });

  @override
  NotificationStyle getStyle(dynamic colors) {
    return NotificationStyle(
      backgroundColor: colors.draculaCyan,
      textColor: colors.draculaBackground,
      iconColor: colors.draculaBackground,
      icon: Icons.info_outline,
      actionColor: colors.draculaBackground,
    );
  }
}

/// Loading notification - for ongoing operations
class LoadingNotification extends NotificationConfig {
  const LoadingNotification({
    required super.message,
    super.duration = const Duration(seconds: 10),
    super.action,
    super.onDismiss,
  });

  @override
  NotificationStyle getStyle(dynamic colors) {
    return NotificationStyle(
      backgroundColor: colors.draculaComment,
      textColor: Colors.white,
      iconColor: Colors.white,
      icon: Icons.hourglass_empty,
      actionColor: Colors.white,
    );
  }
}

/// Achievement notification - for celebrations and achievements
class AchievementNotification extends NotificationConfig {
  const AchievementNotification({
    required super.message,
    super.duration = const Duration(seconds: 4),
    super.action,
    super.onDismiss,
  });

  @override
  NotificationStyle getStyle(dynamic colors) {
    return NotificationStyle(
      backgroundColor: colors.draculaPink,
      textColor: Colors.white,
      iconColor: Colors.white,
      icon: Icons.celebration,
      actionColor: Colors.white,
    );
  }
}