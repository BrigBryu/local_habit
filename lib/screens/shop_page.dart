import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/flexible_theme_system.dart';
import '../core/database/utility_item_collection.dart';
import '../core/services/utility_refresh_service.dart';

final shopTabProvider = StateProvider<int>((ref) => 0);

class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;
    final selectedTab = ref.watch(shopTabProvider);

    return Column(
      children: [
        // Shop Tab Bar
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.draculaCurrentLine.withOpacity(0.3),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: colors.draculaCurrentLine.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  context,
                  ref,
                  index: 0,
                  icon: Icons.palette,
                  label: 'Themes',
                  isSelected: selectedTab == 0,
                ),
              ),
              Expanded(
                child: _buildTabButton(
                  context,
                  ref,
                  index: 1,
                  icon: Icons.build,
                  label: 'Utilities',
                  isSelected: selectedTab == 1,
                ),
              ),
            ],
          ),
        ),
        
        // Tab Content
        Expanded(
          child: IndexedStack(
            index: selectedTab,
            children: const [
              _ThemesTab(),
              _UtilitiesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    WidgetRef ref, {
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final colors = ref.watchColors;
    
    return GestureDetector(
      onTap: () => ref.read(shopTabProvider.notifier).state = index,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? colors.draculaPink.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? colors.draculaPink : colors.draculaComment,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? colors.draculaPink : colors.draculaComment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemesTab extends ConsumerWidget {
  const _ThemesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;
    final currentVariant = ref.watch(themeVariantProvider);
    final availableThemes = ThemeVariant.values;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Themes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.draculaForeground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your app appearance',
            style: TextStyle(
              color: colors.draculaComment,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: availableThemes.length,
              itemBuilder: (context, index) {
                final theme = availableThemes[index];
                final isSelected = theme == currentVariant;
                
                return _ThemeCard(
                  theme: theme,
                  isSelected: isSelected,
                  onTap: () => _selectTheme(ref, theme),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _selectTheme(WidgetRef ref, ThemeVariant theme) {
    ref.read(themeVariantProvider.notifier).setTheme(theme);
  }
}

class _UtilitiesTab extends ConsumerWidget {
  const _UtilitiesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;
    final refreshService = ref.watch(utilityRefreshServiceProvider);
    
    // Mock user refresh total - in real app, get from user data
    const userRefreshTotal = 1; // Placeholder
    final userTier = refreshService.getUserTier(userRefreshTotal);
    final refreshCost = refreshService.calculateRefreshCost(userRefreshTotal);
    
    final groupedItems = ref.watch(groupedUtilityItemsProvider(userTier));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      'Utilities (Tier $userTier)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colors.draculaForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tier-gated utility items',
                      style: TextStyle(
                        color: colors.draculaComment,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildRefreshButton(ref, refreshCost, context),
            ],
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView(
              children: [
                ...groupedItems.entries.map((entry) => [
                  _buildGroupHeader(colors, entry.key),
                  const SizedBox(height: 12),
                  ...entry.value.map((item) => Column(
                    children: [
                      _buildUtilityItemCard(ref, item),
                      const SizedBox(height: 12),
                    ],
                  )),
                  const SizedBox(height: 12),
                ]).expand((widgets) => widgets),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityCard(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final colors = ref.watchColors;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              colors.draculaCurrentLine.withOpacity(0.6),
              colors.draculaCurrentLine.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: colors.draculaCurrentLine,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.draculaPink.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.draculaPink.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: colors.draculaPink,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.draculaForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.draculaComment,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.draculaComment,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshButton(WidgetRef ref, int cost, BuildContext context) {
    final colors = ref.watchColors;
    
    return ElevatedButton.icon(
      onPressed: () => _handleRefresh(ref, context),
      icon: Icon(Icons.refresh, size: 18),
      label: Text('Refresh ($cost coins)'),
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.draculaCyan,
        foregroundColor: colors.draculaBackground,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildGroupHeader(colors, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.draculaCyan,
      ),
    );
  }

  Widget _buildUtilityItemCard(WidgetRef ref, UtilityItem item) {
    final colors = ref.watchColors;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            colors.draculaCurrentLine.withOpacity(0.6),
            colors.draculaCurrentLine.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.draculaCurrentLine,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.draculaPink.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.draculaPink.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              _getIconData(item.iconName),
              color: colors.draculaPink,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.draculaForeground,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.draculaYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.draculaYellow.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${item.price} coins',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.draculaYellow,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.draculaComment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'add_circle':
        return Icons.add_circle;
      case 'shield':
        return Icons.shield;
      case 'folder_open':
        return Icons.folder_open;
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'analytics':
        return Icons.analytics;
      case 'security':
        return Icons.security;
      default:
        return Icons.extension;
    }
  }

  void _handleRefresh(WidgetRef ref, BuildContext context) {
    // Mock refresh implementation
    // In real app, this would call the utility refresh service
    final colors = ref.read(themeVariantProvider.notifier).colors;
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Utilities refreshed! New items unlocked.',
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
}

class _ThemeCard extends ConsumerWidget {
  final ThemeVariant theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? colors.draculaPink
                : colors.draculaCurrentLine,
            width: isSelected ? 2 : 1,
          ),
          gradient: LinearGradient(
            colors: [
              colors.draculaCurrentLine.withOpacity(0.6),
              colors.draculaCurrentLine.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getThemePreviewColor(),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          theme.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.draculaForeground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    theme.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.draculaComment,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.draculaPink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: colors.draculaBackground,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getThemePreviewColor() {
    switch (theme) {
      case ThemeVariant.dracula:
        return const Color(0xFFBD93F9);
      case ThemeVariant.draculaWarm:
        return const Color(0xFFFF79C6);
      case ThemeVariant.draculaCool:
        return const Color(0xFF8BE9FD);
      case ThemeVariant.draculaLight:
        return const Color(0xFF6272A4);
      case ThemeVariant.gruvboxDark:
        return const Color(0xFFD79921);
      case ThemeVariant.gruvboxLight:
        return const Color(0xFFCC241D);
    }
  }
}