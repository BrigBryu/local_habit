import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/flexible_theme_system.dart';
import '../../../../core/database/shop_item_collection.dart';
import '../../../../providers/streak_points_provider.dart';
import '../../../../providers/repository_init_provider.dart';
import '../widgets/shop_item_card.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watchColors;
    // Mock user ID for offline mode
    const userId = 'local_user';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: colors.draculaForeground,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Streak Shop',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.draculaForeground,
                    ),
                  ),
                  const Spacer(),
                  _buildBalanceChip(userId, colors),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTabBar(colors),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCategoryView(ShopItemCategory.theme, userId),
                  _buildCategoryView(ShopItemCategory.icon, userId),
                  _buildCategoryView(ShopItemCategory.badge, userId),
                  _buildCategoryView(ShopItemCategory.flair, userId),
                  _buildCategoryView(ShopItemCategory.consumable, userId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceChip(String userId, FlexibleColorScheme colors) {
    return Consumer(
      builder: (context, ref, child) {
        final balanceAsync = ref.watch(walletBalanceProvider(userId));
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.primaryPurple.withOpacity(0.2),
                colors.primaryPurple.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.primaryPurple.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.diamond,
                color: colors.primaryPurple,
                size: 18,
              ),
              const SizedBox(width: 6),
              balanceAsync.when(
                data: (balance) => Text(
                  balance.toString(),
                  style: TextStyle(
                    color: colors.primaryPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                loading: () => SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(colors.primaryPurple),
                  ),
                ),
                error: (_, __) => Text(
                  '0',
                  style: TextStyle(
                    color: colors.draculaRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar(FlexibleColorScheme colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.draculaCurrentLine.withOpacity(0.3),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: colors.draculaCurrentLine.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: [
          _buildTab(Icons.palette, 'Themes', colors),
          _buildTab(Icons.emoji_emotions, 'Icons', colors),
          _buildTab(Icons.military_tech, 'Badges', colors),
          _buildTab(Icons.auto_awesome, 'Flair', colors),
          _buildTab(Icons.celebration, 'Effects', colors),
        ],
        indicator: BoxDecoration(
          color: colors.primaryPurple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        labelColor: colors.primaryPurple,
        unselectedLabelColor: colors.draculaComment,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  Widget _buildTab(IconData icon, String label, FlexibleColorScheme colors) {
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 2),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildCategoryView(ShopItemCategory category, String userId) {
    return Consumer(
      builder: (context, ref, child) {
        final itemsAsync = ref.watch(shopItemsByCategoryProvider(category));
        final ownedItemsAsync = ref.watch(ownedItemsProvider(userId));

        return itemsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return _buildEmptyState(category);
            }

            return ownedItemsAsync.when(
              data: (ownedItems) {
                final ownedItemIds = ownedItems.map((item) => item.shopItemId).toSet();
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isOwned = ownedItemIds.contains(item.id);
                    final ownedItem = ownedItems.firstWhere(
                      (owned) => owned.shopItemId == item.id,
                      orElse: () => ownedItems.first, // This won't be used if !isOwned
                    );
                    final isEquipped = isOwned && ownedItem.isEquipped;

                    return ShopItemCard(
                      item: item,
                      isOwned: isOwned,
                      isEquipped: isEquipped,
                      onPurchase: isOwned ? null : () => _purchaseItem(item.id, userId),
                      onEquip: (isOwned && !isEquipped && item.oneShot) 
                          ? () => _equipItem(item.id, userId, category) 
                          : null,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(error),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorState(error),
        );
      },
    );
  }

  Widget _buildEmptyState(ShopItemCategory category) {
    final colors = ref.watchColors;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            color: colors.draculaComment,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No ${_getCategoryDisplayName(category)} Available',
            style: TextStyle(
              color: colors.draculaComment,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon for new items!',
            style: TextStyle(
              color: colors.draculaComment,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    final colors = ref.watchColors;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: colors.draculaRed,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load shop items',
            style: TextStyle(
              color: colors.draculaRed,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              color: colors.draculaComment,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(ShopItemCategory category) {
    switch (category) {
      case ShopItemCategory.theme:
        return 'themes';
      case ShopItemCategory.icon:
        return 'icon packs';
      case ShopItemCategory.badge:
        return 'badges';
      case ShopItemCategory.flair:
        return 'dashboard flair';
      case ShopItemCategory.consumable:
        return 'effects';
    }
  }

  void _purchaseItem(String itemId, String userId) async {
    try {
      await ref.read(shopPurchaseProvider.notifier).purchaseItem(userId, itemId);
      
      final purchaseResult = ref.read(shopPurchaseProvider);
      purchaseResult.whenData((result) {
        if (result != null) {
          _showPurchaseResult(result);
        }
      });
    } catch (e) {
      _showErrorSnackBar('Purchase failed: $e');
    }
  }

  void _equipItem(String itemId, String userId, ShopItemCategory category) async {
    try {
      await ref.read(shopPurchaseProvider.notifier).equipItem(userId, itemId, category);
      _showSuccessSnackBar('Item equipped successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to equip item: $e');
    }
  }

  void _showPurchaseResult(ShopPurchaseResponse result) {
    final colors = ref.read(colorsProvider);
    
    String message;
    Color backgroundColor;
    Color textColor;

    switch (result.result) {
      case PurchaseResult.success:
        message = result.message ?? 'Purchase successful!';
        backgroundColor = colors.draculaGreen;
        textColor = colors.draculaBackground;
        break;
      case PurchaseResult.insufficientFunds:
        message = result.message ?? 'Insufficient funds';
        backgroundColor = colors.draculaYellow;
        textColor = colors.draculaBackground;
        break;
      case PurchaseResult.alreadyOwned:
        message = result.message ?? 'Item already owned';
        backgroundColor = colors.draculaCyan;
        textColor = colors.draculaBackground;
        break;
      default:
        message = result.message ?? 'Purchase failed';
        backgroundColor = colors.draculaRed;
        textColor = colors.draculaBackground;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    final colors = ref.read(colorsProvider);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: colors.draculaBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colors.draculaGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    final colors = ref.read(colorsProvider);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: colors.draculaBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colors.draculaRed,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}