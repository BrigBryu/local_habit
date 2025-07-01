import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

import '../database/database_service.dart';
import '../database/wallet_collection.dart';
import '../database/ledger_collection.dart';
import '../database/habit_collection.dart';
import '../database/completion_collection.dart';

class StreakRewardService {
  static StreakRewardService? _instance;
  static StreakRewardService get instance {
    _instance ??= StreakRewardService._();
    return _instance!;
  }

  StreakRewardService._();

  final _logger = Logger();
  final _db = DatabaseService.instance;

  Future<int?> processStreakReward({
    required String habitId,
    required String userId,
    required DateTime completedAt,
  }) async {
    try {
      return await _db.isar.writeTxn(() async {
        final habit = await _db.isar.habitCollections
            .filter()
            .idEqualTo(habitId)
            .findFirst();

        if (habit == null) {
          _logger.w('Habit not found: $habitId');
          return null;
        }

        final today = DateTime.now();
        final completionDate = DateTime(
          completedAt.year,
          completedAt.month,
          completedAt.day,
        );
        final todayDate = DateTime(today.year, today.month, today.day);

        if (!completionDate.isAtSameMomentAs(todayDate)) {
          _logger.d('Completion not for today, no streak reward');
          return null;
        }

        final existingCompletionToday = await _db.isar.completionCollections
            .filter()
            .habitIdEqualTo(habitId)
            .userIdEqualTo(userId)
            .completedAtBetween(
              DateTime(today.year, today.month, today.day),
              DateTime(today.year, today.month, today.day, 23, 59, 59),
            )
            .count();

        if (existingCompletionToday > 1) {
          _logger.d('Multiple completions today, no additional streak reward');
          return null;
        }

        final newStreakLength = await _calculateNewStreakLength(
          habitId,
          userId,
          completedAt,
        );

        if (newStreakLength <= habit.currentStreak) {
          _logger.d('No streak extension, current: ${habit.currentStreak}, new: $newStreakLength');
          return null;
        }

        habit.currentStreak = newStreakLength;
        await _db.isar.habitCollections.put(habit);

        final pointsAwarded = newStreakLength;
        await _awardPoints(userId, habitId, pointsAwarded);

        _logger.i('Streak reward: $pointsAwarded points for habit $habitId (streak: $newStreakLength)');
        return pointsAwarded;
      });
    } catch (e, stackTrace) {
      _logger.e('Failed to process streak reward',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> recordStreakBreak({
    required String habitId,
    required String userId,
  }) async {
    try {
      await _db.isar.writeTxn(() async {
        final habit = await _db.isar.habitCollections
            .filter()
            .idEqualTo(habitId)
            .findFirst();

        if (habit == null) return;

        final oldStreak = habit.currentStreak;
        habit.currentStreak = 0;
        await _db.isar.habitCollections.put(habit);

        if (oldStreak > 0) {
          final ledgerEntry = LedgerCollection.streakBreak(
            userId: userId,
            habitId: habitId,
          );
          await _db.isar.ledgerCollections.put(ledgerEntry);

          _logger.i('Streak broken for habit $habitId (was $oldStreak days)');
        }
      });
    } catch (e, stackTrace) {
      _logger.e('Failed to record streak break',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<int> _calculateNewStreakLength(
    String habitId,
    String userId,
    DateTime completedAt,
  ) async {
    final completionsQuery = _db.isar.completionCollections
        .filter()
        .habitIdEqualTo(habitId)
        .userIdEqualTo(userId)
        .sortByCompletedAtDesc();

    final recentCompletions = await completionsQuery.findAll();

    if (recentCompletions.isEmpty) return 1;

    var streakLength = 1;
    var currentDate = DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );

    for (final completion in recentCompletions) {
      final completionDate = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );

      final previousDay = currentDate.subtract(const Duration(days: 1));

      if (completionDate.isAtSameMomentAs(previousDay)) {
        streakLength++;
        currentDate = previousDay;
      } else if (completionDate.isAtSameMomentAs(currentDate)) {
        continue;
      } else {
        break;
      }
    }

    return streakLength;
  }

  Future<void> _awardPoints(String userId, String habitId, int points) async {
    var wallet = await _db.isar.walletCollections
        .filter()
        .userIdEqualTo(userId)
        .findFirst();

    if (wallet == null) {
      wallet = WalletCollection.create(userId: userId);
    }

    wallet.updateBalance(wallet.balance + points);
    await _db.isar.walletCollections.put(wallet);

    final ledgerEntry = LedgerCollection.streakCredit(
      userId: userId,
      habitId: habitId,
      streakLength: points,
    );
    await _db.isar.ledgerCollections.put(ledgerEntry);
  }

  Future<int> getWalletBalance(String userId) async {
    final wallet = await _db.isar.walletCollections
        .filter()
        .userIdEqualTo(userId)
        .findFirst();

    return wallet?.balance ?? 0;
  }

  Stream<int> watchWalletBalance(String userId) {
    return _db.isar.walletCollections
        .filter()
        .userIdEqualTo(userId)
        .watch(fireImmediately: true)
        .map((wallets) => wallets.firstOrNull?.balance ?? 0);
  }

  Future<List<LedgerCollection>> getLedgerHistory(String userId) async {
    return await _db.isar.ledgerCollections
        .filter()
        .userIdEqualTo(userId)
        .sortByTimestampDesc()
        .findAll();
  }
}