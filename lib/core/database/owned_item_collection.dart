import 'package:isar/isar.dart';

part 'owned_item_collection.g.dart';

@Collection()
class OwnedItemCollection {
  Id isarId = Isar.autoIncrement;

  late String id;
  late String userId;
  late String shopItemId;
  late DateTime purchasedAt;
  bool isEquipped = false;

  OwnedItemCollection();

  factory OwnedItemCollection.create({
    required String userId,
    required String shopItemId,
  }) {
    final purchasedAt = DateTime.now();
    return OwnedItemCollection()
      ..id = '${userId}_$shopItemId'
      ..userId = userId
      ..shopItemId = shopItemId
      ..purchasedAt = purchasedAt
      ..isEquipped = false;
  }

  void equip() {
    isEquipped = true;
  }

  void unequip() {
    isEquipped = false;
  }
}