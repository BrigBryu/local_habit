import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

import '../database/database_service.dart';
import '../database/wallet_collection.dart';
import '../database/ledger_collection.dart';
import '../database/shop_item_collection.dart';
import '../database/owned_item_collection.dart';

enum PurchaseResult {
  success,
  insufficientFunds,
  alreadyOwned,
  itemNotFound,
  error,
}

class ShopPurchaseResponse {
  final PurchaseResult result;
  final String? message;
  final int? remainingBalance;

  const ShopPurchaseResponse({
    required this.result,
    this.message,
    this.remainingBalance,
  });
}

class ShopService {
  static ShopService? _instance;
  static ShopService get instance {
    _instance ??= ShopService._();
    return _instance!;
  }

  ShopService._();

  final _logger = Logger();
  final _db = DatabaseService.instance;

  Future<void> seedShopItems() async {
    try {
      await _db.isar.writeTxn(() async {
        final existingItems = await _db.isar.shopItemCollections.count();
        if (existingItems > 0) {
          _logger.d('Shop items already seeded');
          return;
        }

        final items = [
          ShopItemCollection.create(
            id: 'theme_gruvbox_plus',
            name: 'Gruvbox Plus',
            description: 'Warm retro color scheme with enhanced contrast',
            thumbnailPath: 'assets/themes/gruvbox_plus.png',
            price: 75,
            oneShot: true,
            category: ShopItemCategory.theme,
          ),
          ShopItemCollection.create(
            id: 'theme_nord_frost',
            name: 'Nord Frost',
            description: 'Cool arctic-inspired theme',
            thumbnailPath: 'assets/themes/nord_frost.png',
            price: 85,
            oneShot: true,
            category: ShopItemCategory.theme,
          ),
          ShopItemCollection.create(
            id: 'icons_space_pack',
            name: 'Space Emoji Pack',
            description: 'Stellar collection of space-themed icons',
            thumbnailPath: 'assets/icons/space_pack.png',
            price: 40,
            oneShot: true,
            category: ShopItemCategory.icon,
          ),
          ShopItemCollection.create(
            id: 'badge_golden_streak_100',
            name: 'Golden Streak (100 days)',
            description: 'Prestigious badge for 100-day streaks',
            thumbnailPath: 'assets/badges/golden_100.png',
            price: 0,
            oneShot: true,
            category: ShopItemCategory.badge,
          ),
          ShopItemCollection.create(
            id: 'flair_gradient_sunset',
            name: 'Sunset Gradient',
            description: 'Beautiful sunset background for your dashboard',
            thumbnailPath: 'assets/flair/sunset_gradient.png',
            price: 25,
            oneShot: true,
            category: ShopItemCategory.flair,
          ),
          ShopItemCollection.create(
            id: 'consumable_confetti_burst',
            name: 'Confetti Burst',
            description: 'Celebrate your next completion with style!',
            thumbnailPath: 'assets/consumables/confetti.png',
            price: 10,
            oneShot: false,
            category: ShopItemCategory.consumable,
          ),
        ];

        await _db.isar.shopItemCollections.putAll(items);
        _logger.i('Seeded ${items.length} shop items');
      });
    } catch (e, stackTrace) {
      _logger.e('Failed to seed shop items',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<ShopItemCollection>> getAllItems() async {
    return await _db.isar.shopItemCollections
        .where()
        .sortByCategory()
        .thenByPrice()
        .findAll();
  }

  Future<List<ShopItemCollection>> getItemsByCategory(ShopItemCategory category) async {
    return await _db.isar.shopItemCollections
        .filter()
        .categoryEqualTo(category)
        .sortByPrice()
        .findAll();
  }

  Future<List<OwnedItemCollection>> getOwnedItems(String userId) async {
    return await _db.isar.ownedItemCollections
        .filter()
        .userIdEqualTo(userId)
        .findAll();
  }

  Future<bool> isItemOwned(String userId, String itemId) async {
    final owned = await _db.isar.ownedItemCollections
        .filter()
        .userIdEqualTo(userId)
        .shopItemIdEqualTo(itemId)
        .findFirst();

    return owned != null;
  }

  Future<ShopPurchaseResponse> purchaseItem({
    required String userId,
    required String itemId,
  }) async {
    try {
      return await _db.isar.writeTxn(() async {
        final item = await _db.isar.shopItemCollections
            .filter()
            .idEqualTo(itemId)
            .findFirst();

        if (item == null) {
          return const ShopPurchaseResponse(
            result: PurchaseResult.itemNotFound,
            message: 'Item not found',
          );
        }

        if (item.oneShot && await isItemOwned(userId, itemId)) {
          return const ShopPurchaseResponse(
            result: PurchaseResult.alreadyOwned,
            message: 'Item already owned',
          );
        }

        var wallet = await _db.isar.walletCollections
            .filter()
            .userIdEqualTo(userId)
            .findFirst();

        if (wallet == null) {
          wallet = WalletCollection.create(userId: userId);
          await _db.isar.walletCollections.put(wallet);
        }

        if (wallet.balance < item.price) {
          final needed = item.price - wallet.balance;
          return ShopPurchaseResponse(
            result: PurchaseResult.insufficientFunds,
            message: 'Need $needed more points',
            remainingBalance: wallet.balance,
          );
        }

        wallet.updateBalance(wallet.balance - item.price);
        await _db.isar.walletCollections.put(wallet);

        final ledgerEntry = LedgerCollection.shopPurchase(
          userId: userId,
          itemId: itemId,
          price: item.price,
        );
        await _db.isar.ledgerCollections.put(ledgerEntry);

        final ownedItem = OwnedItemCollection.create(
          userId: userId,
          shopItemId: itemId,
        );
        await _db.isar.ownedItemCollections.put(ownedItem);

        _logger.i('Item purchased: $itemId for ${item.price} points');

        return ShopPurchaseResponse(
          result: PurchaseResult.success,
          message: 'Purchase successful!',
          remainingBalance: wallet.balance,
        );
      });
    } catch (e, stackTrace) {
      _logger.e('Failed to purchase item',
          error: e, stackTrace: stackTrace);
      return const ShopPurchaseResponse(
        result: PurchaseResult.error,
        message: 'Purchase failed',
      );
    }
  }

  Future<void> equipItem({
    required String userId,
    required String itemId,
    required ShopItemCategory category,
  }) async {
    try {
      await _db.isar.writeTxn(() async {
        final ownedItems = await _db.isar.ownedItemCollections
            .filter()
            .userIdEqualTo(userId)
            .findAll();
            
        for (final item in ownedItems) {
          final shopItem = await _db.isar.shopItemCollections
              .filter()
              .idEqualTo(item.shopItemId)
              .findFirst();

          if (shopItem?.category == category) {
            item.unequip();
            await _db.isar.ownedItemCollections.put(item);
          }
        }

        final targetItem = await _db.isar.ownedItemCollections
            .filter()
            .userIdEqualTo(userId)
            .shopItemIdEqualTo(itemId)
            .findFirst();

        if (targetItem != null) {
          targetItem.equip();
          await _db.isar.ownedItemCollections.put(targetItem);
          _logger.i('Item equipped: $itemId');
        }
      });
    } catch (e, stackTrace) {
      _logger.e('Failed to equip item',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<String?> getEquippedItem(String userId, ShopItemCategory category) async {
    final equipped = await _db.isar.ownedItemCollections
        .filter()
        .userIdEqualTo(userId)
        .isEquippedEqualTo(true)
        .findAll();

    for (final item in equipped) {
      final shopItem = await _db.isar.shopItemCollections
          .filter()
          .idEqualTo(item.shopItemId)
          .findFirst();

      if (shopItem?.category == category) {
        return shopItem?.id;
      }
    }

    return null;
  }

  Stream<List<OwnedItemCollection>> watchOwnedItems(String userId) {
    return _db.isar.ownedItemCollections
        .filter()
        .userIdEqualTo(userId)
        .watch(fireImmediately: true);
  }
}