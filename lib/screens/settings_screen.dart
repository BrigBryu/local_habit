import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../core/theme/theme_controller.dart';
import '../core/auth/username_auth_service.dart';
import '../core/auth/auth_wrapper.dart';
import '../providers/repository_init_provider.dart';
import '../features/shop/presentation/pages/shop_screen.dart';
import '../features/shop/presentation/widgets/balance_chip.dart';
import 'theme_gallery_page.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(currentPaletteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: palette.surface,
        foregroundColor: palette.onSurface,
      ),
      backgroundColor: palette.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  palette.primary.withValues(alpha: 0.1),
                  palette.secondary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  size: 48,
                  color: palette.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Local Habit',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: palette.primary,
                        ),
                      ),
                      Text(
                        'Customize your experience',
                        style: TextStyle(
                          fontSize: 14,
                          color: palette.disabled,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const BalanceChip(showLabel: false),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Settings sections
          _buildSettingsSection(
            context,
            ref,
            'Streak Points',
            [
              _buildSettingsTile(
                context,
                ref,
                icon: Icons.diamond,
                title: 'Streak Shop',
                subtitle: 'Spend your points on themes and rewards',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ShopScreen(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildSettingsSection(
            context,
            ref,
            'Appearance',
            [
              _buildSettingsTile(
                context,
                ref,
                icon: Icons.palette,
                title: 'Theme Settings',
                subtitle: 'Change colors and appearance',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ThemeGalleryPage(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),


          _buildSettingsSection(
            context,
            ref,
            'About',
            [
              _buildSettingsTile(
                context,
                ref,
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: 'v1.0.0 - Local Development',
                onTap: null,
              ),
              _buildSettingsTile(
                context,
                ref,
                icon: Icons.code,
                title: 'Repository Mode',
                subtitle: 'Simple Memory Repository',
                onTap: null,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sign Out section
          _buildSettingsSection(
            context,
            ref,
            'Account',
            [
              _buildSignOutTile(context, ref),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<Widget> children,
  ) {
    final palette = ref.watch(currentPaletteProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: palette.accent,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: palette.divider,
              width: 1,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final palette = ref.watch(currentPaletteProvider);
    final isClickable = onTap != null;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: palette.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: palette.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: palette.primary,
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
                          color: palette.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: palette.disabled,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isClickable)
                  Icon(
                    Icons.chevron_right,
                    color: palette.disabled,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutTile(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(currentPaletteProvider);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        // Show confirmation dialog
        final shouldSignOut = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        );

        if (shouldSignOut == true) {
          final logger = Logger();
          logger.i('=== SIGNING OUT USER ===');

          try {
            // Sign out from auth service
            await UsernameAuthService.instance.signOut();
            logger.i('Username auth service signed out');

            // Reset the stream listener and force refresh auth state
            ref.read(authStateNotifierProvider.notifier).resetStreamListener();
            
            // Add a small delay and refresh again to ensure state propagation
            await Future.delayed(const Duration(milliseconds: 100));
            ref.read(authStateNotifierProvider.notifier).refresh();

            // Invalidate all providers to clear user data
            ref.invalidate(repositoryProvider);
            logger.i('Repository provider invalidated');

            // Close the settings screen immediately
            if (context.mounted) {
              Navigator.of(context).pop();
              logger.i('Settings screen closed');
            }

            logger.i('Sign out completed successfully');
          } catch (e) {
            logger.e('Error during sign out: $e');
            // Force refresh auth state even on error
            ref.read(authStateNotifierProvider.notifier).refresh();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sign out of your account',
                    style: TextStyle(
                      fontSize: 13,
                      color: palette.disabled,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: palette.disabled,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
