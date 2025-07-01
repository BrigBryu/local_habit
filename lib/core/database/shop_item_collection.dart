import 'package:isar/isar.dart';

part 'shop_item_collection.g.dart';

enum ShopItemCategory {
  theme,
  icon,
  badge,
  flair,
  consumable,
}

@Collection()
class ShopItemCollection {
  Id isarId = Isar.autoIncrement;

  late String id;
  late String name;
  late String description;
  late String thumbnailPath;
  late int price;
  late bool oneShot;

  @Enumerated(EnumType.name)
  late ShopItemCategory category;

  ShopItemCollection();

  factory ShopItemCollection.create({
    required String id,
    required String name,
    required String description,
    required String thumbnailPath,
    required int price,
    required bool oneShot,
    required ShopItemCategory category,
  }) {
    return ShopItemCollection()
      ..id = id
      ..name = name
      ..description = description
      ..thumbnailPath = thumbnailPath
      ..price = price
      ..oneShot = oneShot
      ..category = category;
  }
}