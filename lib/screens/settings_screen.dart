import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../core/theme/flexible_theme_system.dart';
import '../core/auth/username_auth_service.dart';
import '../core/auth/auth_wrapper.dart';
import '../providers/repository_init_provider.dart';
import 'theme_settings_screen.dart';
import 'partner_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colors.draculaCurrentLine,
        foregroundColor: colors.draculaForeground,
      ),
      backgroundColor: colors.draculaBackground,
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
                  colors.draculaPurple.withOpacity(0.1),
                  colors.draculaPink.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: colors.draculaPurple.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  size: 48,
                  color: colors.draculaPurple,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Habit Level Up',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.draculaPurple,
                        ),
                      ),
                      Text(
                        'Customize your experience',
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
          ),

          const SizedBox(height: 24),

          // Settings sections
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
                    builder: (context) => const ThemeSettingsScreen(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildSettingsSection(
            context,
            ref,
            'Social',
            [
              _buildSettingsTile(
                context,
                ref,
                icon: Icons.people,
                title: 'Partner Settings',
                subtitle: 'Connect with accountability partners',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PartnerSettingsScreen(),
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
    final colors = ref.watchColors;

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
              color: colors.draculaCyan,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.draculaCurrentLine,
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
    final colors = ref.watchColors;
    final isClickable = onTap != null;

    return Container(
      decoration: BoxDecoration(
        color: colors.draculaCurrentLine.withOpacity(0.3),
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
                    color: colors.draculaPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.draculaPurple.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: colors.draculaPurple,
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
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.draculaComment,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isClickable)
                  Icon(
                    Icons.chevron_right,
                    color: colors.draculaComment,
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
    final colors = ref.watchColors;

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
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
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
}
