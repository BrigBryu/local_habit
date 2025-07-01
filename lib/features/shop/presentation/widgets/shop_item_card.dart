import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/flexible_theme_system.dart';
import '../../../../core/database/shop_item_collection.dart';
import '../../../../providers/streak_points_provider.dart';

class ShopItemCard extends ConsumerWidget {
  final ShopItemCollection item;
  final bool isOwned;
  final bool isEquipped;
  final VoidCallback? onPurchase;
  final VoidCallback? onEquip;

  const ShopItemCard({
    super.key,
    required this.item,
    this.isOwned = false,
    this.isEquipped = false,
    this.onPurchase,
    this.onEquip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            isOwned
                ? colors.draculaGreen.withOpacity(0.2)
                : colors.draculaCurrentLine.withOpacity(0.6),
            isOwned
                ? colors.draculaGreen.withOpacity(0.1)
                : colors.draculaCurrentLine.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isOwned
              ? colors.draculaGreen.withOpacity(0.4)
              : colors.primaryPurple.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isOwned ? colors.draculaGreen : colors.draculaForeground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.draculaComment,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildActionButton(context, ref, colors),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(colors).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getCategoryColor(colors).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getCategoryName(),
                    style: TextStyle(
                      color: _getCategoryColor(colors),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (isEquipped)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.draculaCyan.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colors.draculaCyan.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'EQUIPPED',
                      style: TextStyle(
                        color: colors.draculaCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (isOwned && !isEquipped)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.draculaGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colors.draculaGreen.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'OWNED',
                      style: TextStyle(
                        color: colors.draculaGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, FlexibleColorScheme colors) {
    if (isOwned) {
      if (item.oneShot && !isEquipped) {
        return _buildEquipButton(colors);
      } else if (item.oneShot && isEquipped) {
        return _buildEquippedIndicator(colors);
      } else {
        return _buildOwnedButton(colors);
      }
    } else {
      return _buildPurchaseButton(colors);
    }
  }

  Widget _buildPurchaseButton(FlexibleColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.primaryPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPurchase,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Icon(
                  Icons.diamond_outlined,
                  color: colors.primaryPurple,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.price}',
                  style: TextStyle(
                    color: colors.primaryPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOwnedButton(FlexibleColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.draculaGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.draculaGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: colors.draculaGreen,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            'OWNED',
            style: TextStyle(
              color: colors.draculaGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipButton(FlexibleColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.draculaCyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.draculaCyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEquip,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Icon(
                  Icons.wear_outlined,
                  color: colors.draculaCyan,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  'EQUIP',
                  style: TextStyle(
                    color: colors.draculaCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEquippedIndicator(FlexibleColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.draculaCyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.draculaCyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            color: colors.draculaCyan,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            'ACTIVE',
            style: TextStyle(
              color: colors.draculaCyan,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(FlexibleColorScheme colors) {
    switch (item.category) {
      case ShopItemCategory.theme:
        return colors.draculaPurple;
      case ShopItemCategory.icon:
        return colors.draculaYellow;
      case ShopItemCategory.badge:
        return colors.draculaGreen;
      case ShopItemCategory.flair:
        return colors.draculaCyan;
      case ShopItemCategory.consumable:
        return colors.draculaRed;
    }
  }

  String _getCategoryName() {
    switch (item.category) {
      case ShopItemCategory.theme:
        return 'THEME';
      case ShopItemCategory.icon:
        return 'ICONS';
      case ShopItemCategory.badge:
        return 'BADGE';
      case ShopItemCategory.flair:
        return 'FLAIR';
      case ShopItemCategory.consumable:
        return 'EFFECT';
    }
  }
}