import 'package:domain/domain.dart';

/// Abstract repository interface for habit operations.
/// Provides streams for reactive UI updates and supports both local and remote data sources.
abstract class HabitsRepository {
  /// Stream of habits owned by the current user
  Stream<List<Habit>> ownHabits();

  /// Stream of habits owned by a specific partner
  /// Returns empty list if partnerId is invalid or no access granted
  Stream<List<Habit>> partnerHabits(String partnerId);

  /// Add a new habit for the current user
  Future<String?> addHabit(Habit habit);

  /// Update an existing habit
  Future<String?> updateHabit(Habit habit);

  /// Remove a habit by ID
  Future<String?> removeHabit(String habitId);

  /// Complete a habit and award XP
  Future<String?> completeHabit(String habitId, {int xpAwarded = 0});

  /// Complete the current child in a stack habit
  Future<String?> completeStackChild(String stackId);

  /// Record a failure for an avoidance habit
  Future<String?> recordFailure(String habitId);

  /// Get the current user ID
  String getCurrentUserId();

  /// Set the current user ID (for authentication integration)
  Future<void> setCurrentUserId(String userId);

  /// Initialize the repository (setup database connections, etc.)
  Future<void> initialize();

  /// Cleanup resources
  Future<void> dispose();
}

/// Exception thrown when repository operations fail
class RepositoryException implements Exception {
  final String message;
  final Object? originalError;

  const RepositoryException(this.message, [this.originalError]);

  @override
  String toString() => 'RepositoryException: $message';
}
