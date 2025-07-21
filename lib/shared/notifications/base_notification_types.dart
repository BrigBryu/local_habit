import 'package:flutter/material.dart';
import 'notification_contracts.dart';

/// Base notification configuration implementation
abstract class BaseNotificationConfig implements INotificationConfig {
  @override
  final String message;
  @override
  final Duration duration;
  @override
  final Widget? action;
  @override
  final VoidCallback? onDismiss;

  const BaseNotificationConfig({
    required this.message,
    required this.duration,
    this.action,
    this.onDismiss,
  });
}

/// Success notification configuration
class SuccessNotificationConfig extends BaseNotificationConfig {
  const SuccessNotificationConfig({
    required super.message,
    super.duration = const Duration(seconds: 3),
    super.action,
    super.onDismiss,
  });

  @override
  NotificationStyle getStyle(dynamic colors) {
    return NotificationStyle(
      backgroundColor: _getColor(colors, 'success', const Color(0xFF10b981)),
      textColor: Colors.white,
      iconColor: Colors.white,
      icon: Icons.check_circle_outline,
      actionColor: Colors.white,
      elevation: 8,
    );
  }
}

/// Error notification configuration
class ErrorNotificationConfig extends BaseNotificationConfig {
  const ErrorNotificationConfig({
    required super.message,
    super.duration = const Duration(seconds: 4),
    super.action,
    super.onDismiss,
  });

  @override
  NotificationStyle getStyle(dynamic colors) {
    return NotificationStyle(
      backgroundColor: _getColor(colors, 'error', const Color(0xFFef4444)),
      textColor: Colors.white,
      iconColor: Colors.white,
      icon: Icons.error_outline,
      actionColor: Colors.white,
      elevation: 8,
    );
  }
}

/// Warning notification configuration
class WarningNotificationConfig extends BaseNotificationConfig {
  const WarningNotificationConfig({
    required super.message,
    super.duration = const Duration(seconds: 3),
    super.action,
    super.onDismiss,
  });

  @override
  NotificationStyle getStyle(dynamic colors) {
    return NotificationStyle(
      backgroundColor: _getColor(colors, 'warning', const Color(0xFFf59e0b)),
      textColor: Colors.white,
      iconColor: Colors.white,
      icon: Icons.warning_amber_outlined,
      actionColor: Colors.white,
      elevation: 8,
    );
  }
}

/// Info notification configuration
class InfoNotificationConfig extends BaseNotificationConfig {
  const InfoNotificationConfig({
    required super.message,
    super.duration = const Duration(seconds: 2),
    super.action,
    super.onDismiss,
  });

  @override
  NotificationStyle getStyle(dynamic colors) {
    return NotificationStyle(
      backgroundColor: _getColor(colors, 'info', const Color(0xFF3b82f6)),
      textColor: Colors.white,
      iconColor: Colors.white,
      icon: Icons.info_outline,
      actionColor: Colors.white,
      elevation: 8,
    );
  }
}

/// Loading notification configuration
class LoadingNotificationConfig extends BaseNotificationConfig {
  const LoadingNotificationConfig({
    required super.message,
    super.duration = const Duration(seconds: 10),
    super.action,
    super.onDismiss,
  });

  @override
  NotificationStyle getStyle(dynamic colors) {
    return NotificationStyle(
      backgroundColor: _getColor(colors, 'loading', const Color(0xFF6b7280)),
      textColor: Colors.white,
      iconColor: Colors.white,
      icon: Icons.hourglass_empty,
      actionColor: Colors.white,
      elevation: 8,
    );
  }
}

/// Achievement notification configuration
class AchievementNotificationConfig extends BaseNotificationConfig {
  const AchievementNotificationConfig({
    required super.message,
    super.duration = const Duration(seconds: 4),
    super.action,
    super.onDismiss,
  });

  @override
  NotificationStyle getStyle(dynamic colors) {
    return NotificationStyle(
      backgroundColor: _getColor(colors, 'achievement', const Color(0xFF8b5cf6)),
      textColor: Colors.white,
      iconColor: Colors.white,
      icon: Icons.celebration,
      actionColor: Colors.white,
      elevation: 8,
    );
  }
}

/// Custom notification configuration
class CustomNotificationConfig extends BaseNotificationConfig {
  final NotificationStyle style;

  const CustomNotificationConfig({
    required super.message,
    required this.style,
    super.duration = const Duration(seconds: 3),
    super.action,
    super.onDismiss,
  });

  @override
  NotificationStyle getStyle(dynamic colors) => style;
}

/// Helper function to extract color from theme colors
Color _getColor(dynamic colors, String colorName, Color fallback) {
  if (colors == null) return fallback;
  
  try {
    // Try to access color by name
    switch (colorName) {
      case 'success':
        return colors.success ?? fallback;
      case 'error':
        return colors.error ?? fallback;
      case 'warning':
        return colors.warning ?? colors.draculaOrange ?? fallback;
      case 'info':
        return colors.info ?? colors.draculaCyan ?? fallback;
      case 'loading':
        return colors.loading ?? colors.draculaComment ?? fallback;
      case 'achievement':
        return colors.achievement ?? colors.draculaPink ?? fallback;
      default:
        return fallback;
    }
  } catch (e) {
    // If color access fails, return fallback
    return fallback;
  }
}