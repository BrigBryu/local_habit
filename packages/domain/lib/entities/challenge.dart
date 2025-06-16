import '../services/time_service.dart';

/// Enum for different challenge types
enum ChallengeType {
  streak('Complete 3 habits in a row'),
  volume('Complete 5 habits today'),
  variety('Complete 3 different habit types'),
  speed('Complete a habit within 1 hour'),
  perfect('Complete all habits today');

  const ChallengeType(this.description);
  final String description;
}

/// Rolling challenge that appears periodically for bonus XP
class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int xpReward;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final Map<String, dynamic> progress; // Track challenge-specific progress

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.xpReward,
    required this.createdAt,
    required this.expiresAt,
    this.isCompleted = false,
    this.completedAt,
    this.progress = const {},
  });

  /// Factory for creating new challenge
  factory Challenge.create({
    required String title,
    required String description,
    required ChallengeType type,
    required int xpReward,
    required Duration duration,
  }) {
    final timeService = TimeService();
    final now = timeService.now();

    return Challenge(
      id: _generateId(),
      title: title,
      description: description,
      type: type,
      xpReward: xpReward,
      createdAt: now,
      expiresAt: now.add(duration),
    );
  }

  /// Complete this challenge
  Challenge complete() {
    if (isCompleted) return this;

    final timeService = TimeService();
    return Challenge(
      id: id,
      title: title,
      description: description,
      type: type,
      xpReward: xpReward,
      createdAt: createdAt,
      expiresAt: expiresAt,
      isCompleted: true,
      completedAt: timeService.now(),
      progress: progress,
    );
  }

  /// Update challenge progress
  Challenge updateProgress(Map<String, dynamic> newProgress) {
    return Challenge(
      id: id,
      title: title,
      description: description,
      type: type,
      xpReward: xpReward,
      createdAt: createdAt,
      expiresAt: expiresAt,
      isCompleted: isCompleted,
      completedAt: completedAt,
      progress: {...progress, ...newProgress},
    );
  }

  /// Check if challenge has expired
  bool get hasExpired {
    final timeService = TimeService();
    return timeService.now().isAfter(expiresAt) && !isCompleted;
  }

  /// Get time remaining until expiration
  Duration get timeRemaining {
    final timeService = TimeService();
    final remaining = expiresAt.difference(timeService.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    switch (type) {
      case ChallengeType.streak:
        final streakCount = progress['streakCount'] ?? 0;
        return (streakCount / 3).clamp(0.0, 1.0);

      case ChallengeType.volume:
        final completionCount = progress['completionCount'] ?? 0;
        return (completionCount / 5).clamp(0.0, 1.0);

      case ChallengeType.variety:
        final typeCount =
            (progress['completedTypes'] as List<String>?)?.length ?? 0;
        return (typeCount / 3).clamp(0.0, 1.0);

      case ChallengeType.speed:
        return progress['completed'] == true ? 1.0 : 0.0;

      case ChallengeType.perfect:
        final totalHabits = progress['totalHabits'] ?? 1;
        final completedHabits = progress['completedHabits'] ?? 0;
        return (completedHabits / totalHabits).clamp(0.0, 1.0);
    }
  }

  /// Get progress text
  String get progressText {
    switch (type) {
      case ChallengeType.streak:
        final streakCount = progress['streakCount'] ?? 0;
        return '$streakCount/3 streak';

      case ChallengeType.volume:
        final completionCount = progress['completionCount'] ?? 0;
        return '$completionCount/5 habits';

      case ChallengeType.variety:
        final typeCount =
            (progress['completedTypes'] as List<String>?)?.length ?? 0;
        return '$typeCount/3 types';

      case ChallengeType.speed:
        return progress['completed'] == true ? 'Completed!' : 'In progress';

      case ChallengeType.perfect:
        final totalHabits = progress['totalHabits'] ?? 1;
        final completedHabits = progress['completedHabits'] ?? 0;
        return '$completedHabits/$totalHabits habits';
    }
  }

  @override
  String toString() =>
      'Challenge(id: $id, title: $title, progress: ${(progressPercentage * 100).round()}%)';
}

/// Simple ID generator for challenges
String _generateId() {
  final timestamp = TimeService().now().millisecondsSinceEpoch;
  final random = timestamp % 100000;
  return 'challenge_${timestamp}_$random';
}
