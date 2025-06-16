import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Global error handler for the application
class GlobalErrorHandler {
  static GlobalErrorHandler? _instance;
  static GlobalErrorHandler get instance =>
      _instance ??= GlobalErrorHandler._();

  GlobalErrorHandler._();

  final Logger _logger = Logger();

  /// Initialize global error handling
  static void initialize() {
    // Capture Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      instance._logError(details.exception, details.stack, details.context);
      instance._reportToSentry(details.exception, details.stack);
    };

    // Capture async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      instance._logError(error, stack, 'PlatformDispatcher');
      instance._reportToSentry(error, stack);
      return true;
    };

    // Capture zone errors
    runZonedGuarded(() {
      // App initialization happens here
    }, (error, stack) {
      instance._logError(error, stack, 'ZoneGuarded');
      instance._reportToSentry(error, stack);
    });

    instance._logger.i('Global error handler initialized');
  }

  void _logError(Object error, StackTrace? stack, Object? context) {
    _logger.e('Global error caught', error: error, stackTrace: stack);

    // Log additional context if available
    if (context != null) {
      _logger.d('Error context: $context');
    }
  }

  void _reportToSentry(Object error, StackTrace? stack) {
    try {
      Sentry.captureException(error, stackTrace: stack);
    } catch (e) {
      _logger.w('Failed to report error to Sentry: $e');
    }
  }

  /// Show user-friendly error dialog
  static void showErrorDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Result wrapper for safe operations
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const Result._(this.data, this.error, this.isSuccess);

  factory Result.success(T data) => Result._(data, null, true);
  factory Result.failure(String error) => Result._(null, error, false);

  /// Execute a function and return the result or throw
  T unwrap() {
    if (isSuccess && data != null) {
      return data!;
    } else {
      throw Exception(error ?? 'Unknown error');
    }
  }

  /// Execute a function with the data if successful
  Result<U> map<U>(U Function(T) transform) {
    if (isSuccess && data != null) {
      try {
        return Result.success(transform(data!));
      } catch (e) {
        return Result.failure(e.toString());
      }
    } else {
      return Result.failure(error ?? 'No data available');
    }
  }

  /// Execute a function that returns a Result
  Result<U> flatMap<U>(Result<U> Function(T) transform) {
    if (isSuccess && data != null) {
      try {
        return transform(data!);
      } catch (e) {
        return Result.failure(e.toString());
      }
    } else {
      return Result.failure(error ?? 'No data available');
    }
  }
}

/// Safe wrapper for async operations
Future<Result<T>> safeCall<T>(
  Future<T> Function() operation, {
  String? context,
  Logger? logger,
}) async {
  final log = logger ?? Logger();

  try {
    final result = await operation();
    return Result.success(result);
  } catch (e, stackTrace) {
    final errorMessage = e.toString();
    log.e('SafeCall failed${context != null ? ' in $context' : ''}',
        error: e, stackTrace: stackTrace);

    // Report to Sentry
    try {
      await Sentry.captureException(e, stackTrace: stackTrace);
    } catch (sentryError) {
      log.w('Failed to report to Sentry: $sentryError');
    }

    // Return user-friendly error message
    String userMessage;
    if (e is TimeoutException) {
      userMessage = 'Operation timed out. Please check your connection.';
    } else if (e.toString().contains('network') ||
        e.toString().contains('connection')) {
      userMessage =
          'Network error. Please check your connection and try again.';
    } else if (e.toString().contains('permission') ||
        e.toString().contains('unauthorized')) {
      userMessage = 'Permission denied. Please sign in again.';
    } else {
      userMessage = 'An unexpected error occurred. Please try again.';
    }

    return Result.failure(userMessage);
  }
}

/// Safe wrapper for synchronous operations
Result<T> safeSyncCall<T>(
  T Function() operation, {
  String? context,
  Logger? logger,
}) {
  final log = logger ?? Logger();

  try {
    final result = operation();
    return Result.success(result);
  } catch (e, stackTrace) {
    final errorMessage = e.toString();
    log.e('SafeSyncCall failed${context != null ? ' in $context' : ''}',
        error: e, stackTrace: stackTrace);

    // Report to Sentry
    try {
      Sentry.captureException(e, stackTrace: stackTrace);
    } catch (sentryError) {
      log.w('Failed to report to Sentry: $sentryError');
    }

    return Result.failure('An unexpected error occurred. Please try again.');
  }
}

/// Extension methods for easier error handling
extension SafeOperations<T> on Future<T> {
  Future<Result<T>> safe({String? context}) =>
      safeCall(() => this, context: context);
}

extension SafeSyncOperations<T> on T Function() {
  Result<T> safe({String? context}) => safeSyncCall(this, context: context);
}
