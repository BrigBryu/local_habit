import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model for utility items in the shop
class UtilityItem {
  final int id;
  final String name;
  final int tier;
  final int price;
  final bool permanent;
  final bool consumable;
  final String description;
  final String iconName;

  const UtilityItem({
    required this.id,
    required this.name,
    required this.tier,
    required this.price,
    required this.permanent,
    required this.consumable,
    required this.description,
    required this.iconName,
  });

  factory UtilityItem.fromMap(Map<String, dynamic> map) {
    return UtilityItem(
      id: map['id'] as int,
      name: map['name'] as String,
      tier: map['tier'] as int,
      price: map['price'] as int,
      permanent: map['permanent'] as bool,
      consumable: map['consumable'] as bool,
      description: map['description'] as String,
      iconName: map['icon_name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tier': tier,
      'price': price,
      'permanent': permanent,
      'consumable': consumable,
      'description': description,
      'icon_name': iconName,
    };
  }
}

/// Collection manager for utility items
class UtilityItemCollection {
  static const String tableName = 'utility_items';

  /// Default utility items seeded into the database
  static final List<UtilityItem> defaultItems = [
    // Tier 1 items (available to all users)
    const UtilityItem(
      id: 1,
      name: 'Extra Habit Slot',
      tier: 1,
      price: 25,
      permanent: true,
      consumable: false,
      description: 'Add one more daily habit slot',
      iconName: 'add_circle',
    ),
    const UtilityItem(
      id: 2,
      name: 'Streak Saver',
      tier: 1,
      price: 15,
      permanent: false,
      consumable: true,
      description: 'Protect one streak from breaking',
      iconName: 'shield',
    ),
    
    // Tier 2 items (3+ refreshes)
    const UtilityItem(
      id: 3,
      name: 'Habit Bundle Slot',
      tier: 2,
      price: 40,
      permanent: true,
      consumable: false,
      description: 'Add a habit bundle slot',
      iconName: 'folder_open',
    ),
    const UtilityItem(
      id: 4,
      name: 'Double XP Boost',
      tier: 2,
      price: 20,
      permanent: false,
      consumable: true,
      description: 'Double XP for 24 hours',
      iconName: 'rocket_launch',
    ),
    
    // Tier 3 items (7+ refreshes)
    const UtilityItem(
      id: 5,
      name: 'Premium Analytics',
      tier: 3,
      price: 60,
      permanent: true,
      consumable: false,
      description: 'Unlock advanced analytics dashboard',
      iconName: 'analytics',
    ),
    const UtilityItem(
      id: 6,
      name: 'Mega Streak Saver',
      tier: 3,
      price: 35,
      permanent: false,
      consumable: true,
      description: 'Protect all streaks for 7 days',
      iconName: 'security',
    ),
  ];

  /// Gets utility items for a specific tier or below
  static List<UtilityItem> getItemsForTier(int userTier) {
    return defaultItems.where((item) => item.tier <= userTier).toList();
  }

  /// Gets utility items grouped by permanent/consumable
  static Map<String, List<UtilityItem>> getGroupedItems(int userTier) {
    final availableItems = getItemsForTier(userTier);
    
    return {
      'Upgrades': availableItems.where((item) => item.permanent).toList(),
      'Consumables': availableItems.where((item) => item.consumable).toList(),
    };
  }
}

/// Provider for utility items by tier
final utilityItemsByTierProvider = Provider.family<List<UtilityItem>, int>(
  (ref, tier) => UtilityItemCollection.getItemsForTier(tier),
);

/// Provider for grouped utility items
final groupedUtilityItemsProvider = Provider.family<Map<String, List<UtilityItem>>, int>(
  (ref, tier) => UtilityItemCollection.getGroupedItems(tier),
);