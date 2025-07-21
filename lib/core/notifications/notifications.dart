/// Comprehensive notification system for the app
/// 
/// This module provides a reusable, consistent notification system with:
/// - Multiple notification types (success, error, warning, info, loading, achievement)
/// - Smooth animations (slide, fade, scale)
/// - Consistent styling across the app
/// - Easy-to-use API
/// - Support for actions and callbacks
/// 
/// Usage Examples:
/// 
/// ```dart
/// // Simple success notification
/// Notifications.success(context, 'Habit created successfully!');
/// 
/// // Error with custom duration
/// Notifications.error(context, 'Failed to save', duration: Duration(seconds: 5));
/// 
/// // Success with action button
/// Notifications.success(
///   context,
///   'Habit deleted',
///   action: TextButton(
///     onPressed: () => undoDelete(),
///     child: Text('Undo'),
///   ),
/// );
/// 
/// // Using context extensions
/// context.showSuccess('Operation completed!');
/// context.showError('Something went wrong');
/// context.showLoading('Saving changes...');
/// 
/// // Loading notification that can be dismissed manually
/// context.showLoading('Syncing data...');
/// // ... later
/// context.dismissNotification();
/// ```

export 'notification_types.dart';
export 'notification_widget.dart';
export 'notification_manager.dart';