import 'package:isar/isar.dart';

part 'wallet_collection.g.dart';

@Collection()
class WalletCollection {
  Id isarId = Isar.autoIncrement;

  late String id;
  late String userId;
  late int balance;
  late DateTime updatedAt;

  WalletCollection();

  factory WalletCollection.create({
    required String userId,
    int initialBalance = 0,
  }) {
    return WalletCollection()
      ..id = 'wallet_$userId'
      ..userId = userId
      ..balance = initialBalance
      ..updatedAt = DateTime.now();
  }

  void updateBalance(int newBalance) {
    balance = newBalance;
    updatedAt = DateTime.now();
  }
}