import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

/// Service for validation and runtime guards
class ValidationService {
  static ValidationService? _instance;
  static ValidationService get instance => _instance ??= ValidationService._();

  ValidationService._();

  final Logger _logger = Logger();

  /// Validate username according to production rules
  ValidationResult validateUsername(String username) {
    if (username.isEmpty) {
      return ValidationResult.error('Username cannot be empty');
    }

    final trimmed = username.trim();
    if (trimmed.length < 1 || trimmed.length > 32) {
      return ValidationResult.error('Username must be 1-32 characters');
    }

    if (trimmed != username) {
      return ValidationResult.error(
          'Username cannot have leading or trailing spaces');
    }

    // Check for valid characters (basic validation)
    if (!RegExp(r'^[a-zA-Z0-9_\s-]+$').hasMatch(trimmed)) {
      return ValidationResult.error('Username contains invalid characters');
    }

    return ValidationResult.success();
  }

  /// Validate habit name according to production rules
  ValidationResult validateHabitName(String habitName) {
    if (habitName.isEmpty) {
      return ValidationResult.error('Habit name cannot be empty');
    }

    final trimmed = habitName.trim();
    final utf8Length = trimmed.runes.length;

    if (utf8Length < 1 || utf8Length > 64) {
      return ValidationResult.error('Habit name must be 1-64 characters');
    }

    return ValidationResult.success();
  }

  /// Runtime guard to prevent self-partnership
  void guardAgainstSelfPartnership(String userId, String partnerId) {
    if (userId == partnerId) {
      _logger.e(
          'CRITICAL: Attempted self-partnership detected - userId: $userId, partnerId: $partnerId');
      throw StateError('Cannot partner with self');
    }
  }

  /// Runtime guard to ensure non-null username
  void guardUsernameExists(String? username) {
    if (username == null || username.trim().isEmpty) {
      _logger.e('CRITICAL: Null or empty username detected in production');
      throw StateError('Username must be set before accessing this feature');
    }
  }

  /// Show blocking dialog for impossible states
  static void showBlockingErrorDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onFixNow,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton.icon(
            onPressed: onFixNow,
            icon: const Icon(Icons.build_circle),
            label: const Text('Fix Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Show sign out dialog for unfixable states
  static void showSignOutDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onSignOut,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton.icon(
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Sanitize user text input
  String sanitizeUserText(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Rate limiting for writes
  static DateTime? _lastWrite;
  static const Duration _writeInterval = Duration(milliseconds: 500);

  bool canPerformWrite() {
    final now = DateTime.now();
    if (_lastWrite == null || now.difference(_lastWrite!) >= _writeInterval) {
      _lastWrite = now;
      return true;
    }
    return false;
  }

  /// Check for duplicate username collision
  ValidationResult checkUsernameDuplicate(
      String username, List<String> existingUsernames) {
    final normalizedUsername = username.toLowerCase().trim();
    final normalizedExisting =
        existingUsernames.map((u) => u.toLowerCase().trim()).toList();

    if (normalizedExisting.contains(normalizedUsername)) {
      return ValidationResult.error(
          'Username already taken. Please choose a different one.');
    }

    return ValidationResult.success();
  }
}

/// Result of validation operations
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult._(this.isValid, this.errorMessage);

  factory ValidationResult.success() => ValidationResult._(true, null);
  factory ValidationResult.error(String message) =>
      ValidationResult._(false, message);
}
