import 'package:flutter_test/flutter_test.dart';
import 'package:local_habit/core/services/shop_service.dart';
import 'package:local_habit/core/database/database_service.dart';
import 'package:local_habit/core/database/wallet_collection.dart';
import 'package:local_habit/core/database/shop_item_collection.dart';
import 'package:local_habit/core/database/owned_item_collection.dart';

void main() {
  group('ShopService', () {
    late ShopService service;

    setUpAll(() async {
      // Initialize in-memory database for testing
      await DatabaseService.instance.initialize();
      service = ShopService.instance;
    });

    setUp(() async {
      // Clear database before each test
      await DatabaseService.instance.clearAll();
      
      // Seed shop items for testing
      await service.seedShopItems();
    });

    group('purchaseItem', () {
      test('successfully purchases item with sufficient funds', () async {
        const userId = 'test_user';
        const itemId = 'theme_gruvbox_plus'; // 75 points

        // Create wallet with sufficient balance
        final wallet = WalletCollection.create(userId: userId, initialBalance: 100);
        await DatabaseService.instance.isar.writeTxn(() async {
          await DatabaseService.instance.isar.walletCollections.put(wallet);
        });

        // Purchase item
        final result = await service.purchaseItem(
          userId: userId,
          itemId: itemId,
        );

        expect(result.result, equals(PurchaseResult.success));
        expect(result.remainingBalance, equals(25)); // 100 - 75 = 25

        // Verify item is owned
        final isOwned = await service.isItemOwned(userId, itemId);
        expect(isOwned, isTrue);

        // Verify wallet balance updated
        final updatedWallet = await DatabaseService.instance.isar.walletCollections
            .filter()
            .userIdEqualTo(userId)
            .findFirst();
        expect(updatedWallet?.balance, equals(25));
      });

      test('fails purchase with insufficient funds', () async {
        const userId = 'test_user';
        const itemId = 'theme_gruvbox_plus'; // 75 points

        // Create wallet with insufficient balance
        final wallet = WalletCollection.create(userId: userId, initialBalance: 50);
        await DatabaseService.instance.isar.writeTxn(() async {
          await DatabaseService.instance.isar.walletCollections.put(wallet);
        });

        // Attempt purchase
        final result = await service.purchaseItem(
          userId: userId,
          itemId: itemId,
        );

        expect(result.result, equals(PurchaseResult.insufficientFunds));
        expect(result.message, contains('Need 25 more points'));

        // Verify item is not owned
        final isOwned = await service.isItemOwned(userId, itemId);
        expect(isOwned, isFalse);

        // Verify wallet balance unchanged
        final wallet2 = await DatabaseService.instance.isar.walletCollections
            .filter()
            .userIdEqualTo(userId)
            .findFirst();
        expect(wallet2?.balance, equals(50));
      });

      test('prevents purchasing already owned one-shot item', () async {
        const userId = 'test_user';
        const itemId = 'theme_gruvbox_plus';

        // Create wallet with sufficient balance
        final wallet = WalletCollection.create(userId: userId, initialBalance: 200);
        await DatabaseService.instance.isar.writeTxn(() async {
          await DatabaseService.instance.isar.walletCollections.put(wallet);
        });

        // Purchase item first time
        await service.purchaseItem(userId: userId, itemId: itemId);

        // Attempt to purchase again
        final result = await service.purchaseItem(
          userId: userId,
          itemId: itemId,
        );

        expect(result.result, equals(PurchaseResult.alreadyOwned));
        expect(result.message, contains('already owned'));

        // Verify balance was only deducted once
        final updatedWallet = await DatabaseService.instance.isar.walletCollections
            .filter()
            .userIdEqualTo(userId)
            .findFirst();
        expect(updatedWallet?.balance, equals(125)); // 200 - 75 = 125
      });

      test('allows purchasing consumable items multiple times', () async {
        const userId = 'test_user';
        const itemId = 'consumable_confetti_burst'; // 10 points

        // Create wallet with sufficient balance
        final wallet = WalletCollection.create(userId: userId, initialBalance: 50);
        await DatabaseService.instance.isar.writeTxn(() async {
          await DatabaseService.instance.isar.walletCollections.put(wallet);
        });

        // Purchase consumable item twice
        final result1 = await service.purchaseItem(userId: userId, itemId: itemId);
        final result2 = await service.purchaseItem(userId: userId, itemId: itemId);

        expect(result1.result, equals(PurchaseResult.success));
        expect(result2.result, equals(PurchaseResult.success));

        // Verify both purchases deducted from balance
        final updatedWallet = await DatabaseService.instance.isar.walletCollections
            .filter()
            .userIdEqualTo(userId)
            .findFirst();
        expect(updatedWallet?.balance, equals(30)); // 50 - 10 - 10 = 30

        // Verify multiple owned items
        final ownedItems = await service.getOwnedItems(userId);
        final consumableItems = ownedItems.where((item) => item.shopItemId == itemId);
        expect(consumableItems.length, equals(2));
      });

      test('fails with non-existent item', () async {
        const userId = 'test_user';
        const itemId = 'non_existent_item';

        // Create wallet with balance
        final wallet = WalletCollection.create(userId: userId, initialBalance: 100);
        await DatabaseService.instance.isar.writeTxn(() async {
          await DatabaseService.instance.isar.walletCollections.put(wallet);
        });

        // Attempt purchase
        final result = await service.purchaseItem(
          userId: userId,
          itemId: itemId,
        );

        expect(result.result, equals(PurchaseResult.itemNotFound));
        expect(result.message, contains('Item not found'));
      });
    });

    group('equipItem', () {
      test('equips owned theme item and unequips others', () async {
        const userId = 'test_user';
        const itemId1 = 'theme_gruvbox_plus';
        const itemId2 = 'theme_nord_frost';

        // Create wallet and purchase both theme items
        final wallet = WalletCollection.create(userId: userId, initialBalance: 200);
        await DatabaseService.instance.isar.writeTxn(() async {
          await DatabaseService.instance.isar.walletCollections.put(wallet);
        });

        await service.purchaseItem(userId: userId, itemId: itemId1);
        await service.purchaseItem(userId: userId, itemId: itemId2);

        // Equip first theme
        await service.equipItem(
          userId: userId,
          itemId: itemId1,
          category: ShopItemCategory.theme,
        );

        // Verify first theme is equipped
        final equippedTheme = await service.getEquippedItem(userId, ShopItemCategory.theme);
        expect(equippedTheme, equals(itemId1));

        // Equip second theme
        await service.equipItem(
          userId: userId,
          itemId: itemId2,
          category: ShopItemCategory.theme,
        );

        // Verify second theme is equipped and first is unequipped
        final newEquippedTheme = await service.getEquippedItem(userId, ShopItemCategory.theme);
        expect(newEquippedTheme, equals(itemId2));

        // Verify only one theme is equipped
        final ownedItems = await service.getOwnedItems(userId);
        final equippedThemes = ownedItems.where((item) => item.isEquipped);
        expect(equippedThemes.length, equals(1));
        expect(equippedThemes.first.shopItemId, equals(itemId2));
      });
    });

    group('shop item categories', () {
      test('returns items by category', () async {
        final themeItems = await service.getItemsByCategory(ShopItemCategory.theme);
        final iconItems = await service.getItemsByCategory(ShopItemCategory.icon);
        final badgeItems = await service.getItemsByCategory(ShopItemCategory.badge);

        expect(themeItems.length, greaterThan(0));
        expect(iconItems.length, greaterThan(0));
        expect(badgeItems.length, greaterThan(0));

        // Verify items are correctly categorized
        for (final item in themeItems) {
          expect(item.category, equals(ShopItemCategory.theme));
        }
        for (final item in iconItems) {
          expect(item.category, equals(ShopItemCategory.icon));
        }
        for (final item in badgeItems) {
          expect(item.category, equals(ShopItemCategory.badge));
        }
      });

      test('verifies seeded shop items', () async {
        final allItems = await service.getAllItems();

        // Check that all expected items are seeded
        final itemIds = allItems.map((item) => item.id).toSet();
        expect(itemIds.contains('theme_gruvbox_plus'), isTrue);
        expect(itemIds.contains('theme_nord_frost'), isTrue);
        expect(itemIds.contains('icons_space_pack'), isTrue);
        expect(itemIds.contains('badge_golden_streak_100'), isTrue);
        expect(itemIds.contains('flair_gradient_sunset'), isTrue);
        expect(itemIds.contains('consumable_confetti_burst'), isTrue);

        // Check free badge item
        final badgeItem = allItems.firstWhere((item) => item.id == 'badge_golden_streak_100');
        expect(badgeItem.price, equals(0));
        expect(badgeItem.oneShot, isTrue);

        // Check consumable item
        final consumableItem = allItems.firstWhere((item) => item.id == 'consumable_confetti_burst');
        expect(consumableItem.oneShot, isFalse);
      });
    });
  });
}