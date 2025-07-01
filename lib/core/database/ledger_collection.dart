import 'package:isar/isar.dart';

part 'ledger_collection.g.dart';

@Collection()
class LedgerCollection {
  Id isarId = Isar.autoIncrement;

  late String id;
  late String userId;
  late int amount;
  late String reason;
  late DateTime timestamp;

  LedgerCollection();

  factory LedgerCollection.create({
    required String userId,
    required int amount,
    required String reason,
  }) {
    final timestamp = DateTime.now();
    return LedgerCollection()
      ..id = '${userId}_${timestamp.millisecondsSinceEpoch}'
      ..userId = userId
      ..amount = amount
      ..reason = reason
      ..timestamp = timestamp;
  }

  factory LedgerCollection.streakCredit({
    required String userId,
    required String habitId,
    required int streakLength,
  }) {
    return LedgerCollection.create(
      userId: userId,
      amount: streakLength,
      reason: 'streak:$habitId',
    );
  }

  factory LedgerCollection.shopPurchase({
    required String userId,
    required String itemId,
    required int price,
  }) {
    return LedgerCollection.create(
      userId: userId,
      amount: -price,
      reason: 'shop:$itemId',
    );
  }

  factory LedgerCollection.streakBreak({
    required String userId,
    required String habitId,
  }) {
    return LedgerCollection.create(
      userId: userId,
      amount: 0,
      reason: 'streakBreak:$habitId',
    );
  }

  bool get isCredit => amount > 0;
  bool get isDebit => amount < 0;
  bool get isStreakReward => reason.startsWith('streak:');
  bool get isShopPurchase => reason.startsWith('shop:');
  bool get isStreakBreak => reason.startsWith('streakBreak:');
}