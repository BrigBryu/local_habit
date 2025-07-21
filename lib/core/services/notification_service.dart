import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_controller.dart';
import '../widgets/animated_notification.dart';

/// Centralized notification service for consistent SnackBar behavior
class NotificationService {
  static void showSuccess(BuildContext context, String message, {
    WidgetRef? ref,
    Duration? duration,
    Widget? action,
  }) {
    NotificationOverlay.show(
      context,
      message,
      NotificationType.success,
      duration: duration ?? const Duration(seconds: 3),
      action: action,
    );
  }

  static void showError(BuildContext context, String message, {
    WidgetRef? ref,
    Duration? duration,
    Widget? action,
  }) {
    NotificationOverlay.show(
      context,
      message,
      NotificationType.error,
      duration: duration ?? const Duration(seconds: 4),
      action: action,
    );
  }

  static void showInfo(BuildContext context, String message, {
    WidgetRef? ref,
    Duration? duration,
    Widget? action,
  }) {
    NotificationOverlay.show(
      context,
      message,
      NotificationType.info,
      duration: duration ?? const Duration(seconds: 2),
      action: action,
    );
  }

  static void showWarning(BuildContext context, String message, {
    WidgetRef? ref,
    Duration? duration,
    Widget? action,
  }) {
    NotificationOverlay.show(
      context,
      message,
      NotificationType.warning,
      duration: duration ?? const Duration(seconds: 3),
      action: action,
    );
  }

}

/// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});