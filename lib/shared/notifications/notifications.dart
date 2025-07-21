/// Shared Notification System
/// 
/// A comprehensive, reusable notification system that provides:
/// - Abstract contracts for notification components
/// - Base implementations for common notification types
/// - Smooth animations and gesture handling
/// - Consistent styling and behavior
/// - Easy-to-use API with context extensions
/// 
/// Usage:
/// ```dart
/// // Initialize the notification system
/// final manager = BaseNotificationManager(colors: yourColors);
/// final service = BaseNotificationService(manager: manager);
/// Notifications.initialize(manager: manager, service: service);
/// 
/// // Show notifications
/// context.showSuccess('Operation completed!');
/// context.showError('Something went wrong');
/// context.showLoading('Processing...');
/// 
/// // Or use static methods
/// Notifications.success(context, 'Success!');
/// Notifications.error(context, 'Error occurred');
/// 
/// // With custom actions
/// Notifications.success(
///   context,
///   'Item deleted',
///   action: TextButton(
///     onPressed: () => undo(),
///     child: Text('Undo'),
///   ),
/// );
/// ```

export 'notification_contracts.dart';
export 'base_notification_types.dart';
export 'base_notification_widget.dart';
export 'notification_manager.dart';