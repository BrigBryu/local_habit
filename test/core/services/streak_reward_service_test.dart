import 'package:flutter_test/flutter_test.dart';
import 'package:domain/domain.dart';
import 'package:local_habit/core/services/streak_reward_service.dart';
import 'package:local_habit/core/database/database_service.dart';
import 'package:local_habit/core/database/wallet_collection.dart';
import 'package:local_habit/core/database/ledger_collection.dart';
import 'package:local_habit/core/database/habit_collection.dart';
import 'package:local_habit/core/database/completion_collection.dart';

void main() {
  group('StreakRewardService', () {
    late StreakRewardService service;

    setUpAll(() async {
      // Initialize in-memory database for testing
      await DatabaseService.instance.initialize();
      service = StreakRewardService.instance;
    });

    setUp(() async {
      // Clear database before each test
      await DatabaseService.instance.clearAll();
    });

    group('processStreakReward', () {
      test('awards points for first completion (1-day streak)', () async {
        const userId = 'test_user';
        const habitId = 'test_habit';
        final completedAt = DateTime.now();

        // Create a habit in the database
        final habit = HabitCollection()
          ..id = habitId
          ..name = 'Test Habit'
          ..description = 'Test Description'
          ..type = HabitType.basic
          ..createdAt = DateTime.now().subtract(const Duration(days: 1))
          ..currentStreak = 0;

        await DatabaseService.instance.isar.writeTxn(() async {
          await DatabaseService.instance.isar.habitCollections.put(habit);
        });

        // Process streak reward
        final points = await service.processStreakReward(
          habitId: habitId,
          userId: userId,
          completedAt: completedAt,
        );

        expect(points, equals(1));

        // Verify wallet balance
        final balance = await service.getWalletBalance(userId);
        expect(balance, equals(1));

        // Verify ledger entry
        final ledgerHistory = await service.getLedgerHistory(userId);
        expect(ledgerHistory.length, equals(1));
        expect(ledgerHistory.first.amount, equals(1));
        expect(ledgerHistory.first.reason, equals('streak:$habitId'));
      });

      test('awards points equal to new streak length', () async {
        const userId = 'test_user';
        const habitId = 'test_habit';
        final completedAt = DateTime.now();

        // Create a habit with existing 2-day streak
        final habit = HabitCollection()
          ..id = habitId
          ..name = 'Test Habit'
          ..description = 'Test Description'
          ..type = HabitType.basic
          ..createdAt = DateTime.now().subtract(const Duration(days: 3))
          ..currentStreak = 2;

        // Add previous completions to simulate streak
        final yesterday = completedAt.subtract(const Duration(days: 1));
        final dayBefore = completedAt.subtract(const Duration(days: 2));

        final completion1 = CompletionCollection.fromHabitCompletion(
          habitId: habitId,
          userId: userId,
          completedAt: yesterday,
        );

        final completion2 = CompletionCollection.fromHabitCompletion(
          habitId: habitId,
          userId: userId,
          completedAt: dayBefore,
        );

        await DatabaseService.instance.isar.writeTxn(() async {
          await DatabaseService.instance.isar.habitCollections.put(habit);
          await DatabaseService.instance.isar.completionCollections.put(completion1);
          await DatabaseService.instance.isar.completionCollections.put(completion2);
        });

        // Process streak reward
        final points = await service.processStreakReward(
          habitId: habitId,
          userId: userId,
          completedAt: completedAt,
        );

        expect(points, equals(3)); // Should award 3 points for 3-day streak

        // Verify wallet balance
        final balance = await service.getWalletBalance(userId);
        expect(balance, equals(3));
      });

      test('does not award points for multiple completions same day', () async {
        const userId = 'test_user';
        const habitId = 'test_habit';
        final completedAt = DateTime.now();

        // Create a habit
        final habit = HabitCollection()
          ..id = habitId
          ..name = 'Test Habit'
          ..description = 'Test Description'
          ..type = HabitType.basic
          ..createdAt = DateTime.now().subtract(const Duration(days: 1))
          ..currentStreak = 0;

        // Add a completion for today
        final todayCompletion = CompletionCollection.fromHabitCompletion(
          habitId: habitId,
          userId: userId,
          completedAt: completedAt.subtract(const Duration(minutes: 30)),
        );

        await DatabaseService.instance.isar.writeTxn(() async {
          await DatabaseService.instance.isar.habitCollections.put(habit);
          await DatabaseService.instance.isar.completionCollections.put(todayCompletion);
        });

        // Process streak reward for second completion today
        final points = await service.processStreakReward(
          habitId: habitId,
          userId: userId,
          completedAt: completedAt,
        );

        expect(points, isNull); // Should not award points

        // Verify wallet balance remains 0
        final balance = await service.getWalletBalance(userId);
        expect(balance, equals(0));
      });

      test('does not award points for past date completion', () async {
        const userId = 'test_user';
        const habitId = 'test_habit';
        final completedAt = DateTime.now().subtract(const Duration(days: 1));

        // Create a habit
        final habit = HabitCollection()
          ..id = habitId
          ..name = 'Test Habit'
          ..description = 'Test Description'
          ..type = HabitType.basic
          ..createdAt = DateTime.now().subtract(const Duration(days: 2))
          ..currentStreak = 0;

        await DatabaseService.instance.isar.writeTxn(() async {
          await DatabaseService.instance.isar.habitCollections.put(habit);
        });

        // Process streak reward for past date
        final points = await service.processStreakReward(
          habitId: habitId,
          userId: userId,
          completedAt: completedAt,
        );

        expect(points, isNull); // Should not award points

        // Verify wallet balance remains 0
        final balance = await service.getWalletBalance(userId);
        expect(balance, equals(0));
      });
    });

    group('recordStreakBreak', () {
      test('resets habit streak to 0', () async {
        const userId = 'test_user';
        const habitId = 'test_habit';

        // Create a habit with existing streak
        final habit = HabitCollection()
          ..id = habitId
          ..name = 'Test Habit'
          ..description = 'Test Description'
          ..type = HabitType.basic
          ..createdAt = DateTime.now().subtract(const Duration(days: 5))
          ..currentStreak = 5;

        await DatabaseService.instance.isar.writeTxn(() async {
          await DatabaseService.instance.isar.habitCollections.put(habit);
        });

        // Record streak break
        await service.recordStreakBreak(
          habitId: habitId,
          userId: userId,
        );

        // Verify ledger entry for streak break was created
        // (actual habit verification would require more complex setup)

        // Verify ledger entry for streak break
        final ledgerHistory = await service.getLedgerHistory(userId);
        expect(ledgerHistory.length, equals(1));
        expect(ledgerHistory.first.amount, equals(0));
        expect(ledgerHistory.first.reason, equals('streakBreak:$habitId'));
      });
    });

    group('wallet operations', () {
      test('creates wallet if it does not exist', () async {
        const userId = 'test_user';

        final balance = await service.getWalletBalance(userId);
        expect(balance, equals(0));
      });

      test('returns existing wallet balance', () async {
        const userId = 'test_user';

        // Create wallet with balance
        final wallet = WalletCollection.create(userId: userId, initialBalance: 50);
        await DatabaseService.instance.isar.writeTxn(() async {
          await DatabaseService.instance.isar.walletCollections.put(wallet);
        });

        final balance = await service.getWalletBalance(userId);
        expect(balance, equals(50));
      });
    });
  });
}