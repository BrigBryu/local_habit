/// Shared Systems Library
/// 
/// This library contains reusable, abstracted code systems that can be easily
/// ported to different app projects. All systems follow clean architecture
/// principles and provide consistent, maintainable solutions.
/// 
/// ## Available Systems:
/// 
/// ### Theme System
/// - Abstract theme contracts and interfaces
/// - Base color palette implementations
/// - Theme configuration and management
/// - Runtime theme switching with persistence
/// 
/// ### Notification System
/// - Type-safe notification configurations
/// - Smooth animations and gesture handling
/// - Multiple notification types (success, error, warning, info, loading, achievement)
/// - Easy-to-use APIs with context extensions
/// 
/// ## Quick Start:
/// 
/// ```dart
/// import 'package:your_app/shared/shared.dart';
/// 
/// // Initialize theme system
/// final registry = ThemeRegistry();
/// registry.registerDefaultThemes();
/// 
/// // Initialize notification system
/// final manager = BaseNotificationManager(colors: yourColors);
/// final service = BaseNotificationService(manager: manager);
/// Notifications.initialize(manager: manager, service: service);
/// 
/// // Use in your app
/// context.showSuccess('Hello from shared systems!');
/// ```

// Theme System Exports
export 'theme/theme.dart';

// Notification System Exports
export 'notifications/notifications.dart';