import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/streak_reward_service.dart';
import '../core/services/shop_service.dart';
import '../core/database/shop_item_collection.dart';
import '../core/database/owned_item_collection.dart';
import '../core/database/ledger_collection.dart';

final streakRewardServiceProvider = Provider<StreakRewardService>((ref) {
  return StreakRewardService.instance;
});

final shopServiceProvider = Provider<ShopService>((ref) {
  return ShopService.instance;
});

final walletBalanceProvider = StreamProvider.family<int, String>((ref, userId) {
  final service = ref.watch(streakRewardServiceProvider);
  return service.watchWalletBalance(userId);
});

final shopItemsProvider = FutureProvider<List<ShopItemCollection>>((ref) {
  final service = ref.watch(shopServiceProvider);
  return service.getAllItems();
});

final shopItemsByCategoryProvider = FutureProvider.family<List<ShopItemCollection>, ShopItemCategory>((ref, category) {
  final service = ref.watch(shopServiceProvider);
  return service.getItemsByCategory(category);
});

final ownedItemsProvider = StreamProvider.family<List<OwnedItemCollection>, String>((ref, userId) {
  final service = ref.watch(shopServiceProvider);
  return service.watchOwnedItems(userId);
});

final isItemOwnedProvider = FutureProvider.family<bool, ({String userId, String itemId})>((ref, params) {
  final service = ref.watch(shopServiceProvider);
  return service.isItemOwned(params.userId, params.itemId);
});

final equippedItemProvider = FutureProvider.family<String?, ({String userId, ShopItemCategory category})>((ref, params) {
  final service = ref.watch(shopServiceProvider);
  return service.getEquippedItem(params.userId, params.category);
});

final ledgerHistoryProvider = FutureProvider.family<List<LedgerCollection>, String>((ref, userId) {
  final service = ref.watch(streakRewardServiceProvider);
  return service.getLedgerHistory(userId);
});

class StreakPointsNotifier extends StateNotifier<StreakRewardData?> {
  StreakPointsNotifier() : super(null);

  void showReward({
    required int points,
    required int streakLength,
    required String habitName,
  }) {
    state = StreakRewardData(
      points: points,
      streakLength: streakLength,
      habitName: habitName,
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        state = null;
      }
    });
  }

  void clearReward() {
    state = null;
  }
}

class StreakRewardData {
  final int points;
  final int streakLength;
  final String habitName;

  const StreakRewardData({
    required this.points,
    required this.streakLength,
    required this.habitName,
  });
}

final streakPointsNotificationProvider = StateNotifierProvider<StreakPointsNotifier, StreakRewardData?>((ref) {
  return StreakPointsNotifier();
});

class ShopPurchaseNotifier extends StateNotifier<AsyncValue<ShopPurchaseResponse?>> {
  final ShopService _shopService;

  ShopPurchaseNotifier(this._shopService) : super(const AsyncValue.data(null));

  Future<void> purchaseItem(String userId, String itemId) async {
    state = const AsyncValue.loading();
    try {
      final result = await _shopService.purchaseItem(
        userId: userId,
        itemId: itemId,
      );
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> equipItem(String userId, String itemId, ShopItemCategory category) async {
    try {
      await _shopService.equipItem(
        userId: userId,
        itemId: itemId,
        category: category,
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearPurchaseResult() {
    state = const AsyncValue.data(null);
  }
}

final shopPurchaseProvider = StateNotifierProvider<ShopPurchaseNotifier, AsyncValue<ShopPurchaseResponse?>>((ref) {
  final shopService = ref.watch(shopServiceProvider);
  return ShopPurchaseNotifier(shopService);
});