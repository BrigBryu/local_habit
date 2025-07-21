import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/theme_controller.dart';
import '../providers/habits_provider.dart';
import '../core/services/time_service.dart';
import '../settings/theme_gallery_page.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isAdvancing = false;
  bool _isResetting = false;

  @override
  Widget build(BuildContext context) {
    final colors = ref.watchColors;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                colors.draculaPink.withValues(alpha: 0.1),
                colors.draculaPurple.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: colors.draculaPink.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.settings,
                size: 48,
                color: colors.draculaPink,
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
                        color: colors.draculaForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Simplified habit tracking app',
                      style: TextStyle(
                        fontSize: 16,
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

        // Appearance section
        _buildSettingsSection(
          context,
          ref,
          'Appearance',
          [
            _buildSettingsTile(
              context,
              ref,
              icon: Icons.palette,
              title: 'Themes',
              subtitle: 'Choose your preferred theme',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeGalleryPage(),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Data Management section
        _buildSettingsSection(
          context,
          ref,
          'Data Management',
          [
            _buildSettingsTile(
              context,
              ref,
              icon: Icons.delete_sweep,
              title: 'Mass Delete Habits',
              subtitle: 'Select and delete multiple habits at once',
              onTap: () => _showMassDeleteDialog(context, ref),
            ),
            _buildSettingsTile(
              context,
              ref,
              icon: Icons.refresh,
              title: 'Reset All Habits',
              subtitle: 'Clear all habit data and start fresh',
              onTap: () => _showResetConfirmation(context, ref),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Testing Tools section
        _buildSettingsSection(
          context,
          ref,
          'Testing Tools',
          [
            _buildCurrentDateTile(context, ref),
            _buildSettingsTile(
              context,
              ref,
              icon: Icons.fast_forward,
              title: 'Advance Day',
              subtitle: _isAdvancing ? 'Processing...' : 'Move forward 1 day to test streaks',
              onTap: _isAdvancing ? null : () => _advanceDay(context, ref),
            ),
            _buildSettingsTile(
              context,
              ref,
              icon: Icons.calendar_today,
              title: 'Reset to Today',
              subtitle: _isResetting ? 'Processing...' : 'Reset to real current date',
              onTap: _isResetting ? null : () => _resetToToday(context, ref),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // About section
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
              subtitle: 'v1.0.0 - Simplified Local-Only',
              onTap: null,
            ),
            _buildSettingsTile(
              context,
              ref,
              icon: Icons.storage,
              title: 'Storage',
              subtitle: 'Isar Local Database',
              onTap: null,
            ),
          ],
        ),
      ],
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
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.draculaPink,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.draculaCurrentLine,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.draculaComment.withValues(alpha: 0.3),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.draculaPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
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
                        fontWeight: FontWeight.w500,
                        color: colors.draculaForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.draculaComment,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: colors.draculaComment,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.draculaCurrentLine,
        title: Text(
          'Reset All Habits',
          style: TextStyle(color: colors.draculaForeground),
        ),
        content: Text(
          'This will permanently delete all your habits and their data. This action cannot be undone.',
          style: TextStyle(color: colors.draculaComment),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.draculaComment),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final habitService = ref.read(habitServiceProvider.notifier);
              final habits = ref.read(habitServiceProvider).value ?? [];
              for (final habit in habits) {
                await habitService.deleteHabit(habit);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All habits have been reset')),
              );
            },
            child: Text(
              'Reset',
              style: TextStyle(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentDateTile(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;
    final timeState = ref.watch(timeServiceProvider);

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.draculaGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.today,
                color: colors.draculaGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colors.draculaForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${timeState.formattedDate} (${timeState.offsetStatus})',
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
    );
  }

  Future<void> _advanceDay(BuildContext context, WidgetRef ref) async {
    setState(() => _isAdvancing = true);
    final colors = ref.colors; // Get colors before async operation
    
    try {
      final timeService = ref.read(timeServiceProvider.notifier);
      await timeService.addDays(1);
      
      // Force UI refresh
      ref.invalidate(habitServiceProvider);
      ref.invalidate(habitListProvider);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Advanced to ${timeService.formatCurrentDate()}'),
            backgroundColor: colors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAdvancing = false);
      }
    }
  }

  Future<void> _resetToToday(BuildContext context, WidgetRef ref) async {
    setState(() => _isResetting = true);
    final colors = ref.colors; // Get colors before async operation
    
    try {
      final timeService = ref.read(timeServiceProvider.notifier);
      await timeService.resetToRealDate();
      
      // Force UI refresh
      ref.invalidate(habitServiceProvider);
      ref.invalidate(habitListProvider);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Reset to ${timeService.formatCurrentDate()}'),
            backgroundColor: colors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
      }
    }
  }

  void _showMassDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _MassDeleteDialog(),
    );
  }
}

class _MassDeleteDialog extends ConsumerStatefulWidget {
  const _MassDeleteDialog();

  @override
  ConsumerState<_MassDeleteDialog> createState() => _MassDeleteDialogState();
}

class _MassDeleteDialogState extends ConsumerState<_MassDeleteDialog> {
  final Set<int> _selectedHabits = {};
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitListProvider);
    final colors = ref.watchColors;

    return AlertDialog(
      backgroundColor: colors.draculaCurrentLine,
      title: Row(
        children: [
          Icon(Icons.delete_sweep, color: colors.draculaRed),
          const SizedBox(width: 8),
          Text(
            'Mass Delete Habits',
            style: TextStyle(color: colors.draculaForeground),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: habitsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text(
            'Error loading habits: $error',
            style: TextStyle(color: colors.error),
          ),
          data: (habits) {
            if (habits.isEmpty) {
              return Center(
                child: Text(
                  'No habits to delete',
                  style: TextStyle(color: colors.draculaComment),
                ),
              );
            }

            return Column(
              children: [
                // Select all/none buttons
                Row(
                  children: [
                    TextButton(
                      onPressed: () => setState(() {
                        _selectedHabits.clear();
                        _selectedHabits.addAll(habits.map((h) => h.id));
                      }),
                      child: Text(
                        'Select All',
                        style: TextStyle(color: colors.draculaPink),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => setState(() => _selectedHabits.clear()),
                      child: Text(
                        'Select None',
                        style: TextStyle(color: colors.draculaComment),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Habit list
                Expanded(
                  child: ListView.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      final isSelected = _selectedHabits.contains(habit.id);

                      return CheckboxListTile(
                        title: Text(
                          habit.displayName,
                          style: TextStyle(
                            color: colors.draculaForeground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Streak: ${habit.streak}',
                          style: TextStyle(
                            color: colors.draculaComment,
                            fontSize: 12,
                          ),
                        ),
                        value: isSelected,
                        activeColor: colors.draculaRed,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedHabits.add(habit.id);
                            } else {
                              _selectedHabits.remove(habit.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Selection count
                Text(
                  '${_selectedHabits.length} habit(s) selected',
                  style: TextStyle(
                    color: colors.draculaComment,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: colors.draculaComment),
          ),
        ),
        TextButton(
          onPressed: _isDeleting || _selectedHabits.isEmpty 
              ? null 
              : () => _deleteSelectedHabits(context),
          child: _isDeleting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.error),
                  ),
                )
              : Text(
                  'Delete (${_selectedHabits.length})',
                  style: TextStyle(color: colors.error),
                ),
        ),
      ],
    );
  }

  Future<void> _deleteSelectedHabits(BuildContext context) async {
    if (_selectedHabits.isEmpty) return;

    final colors = ref.read(flexibleColorsProviderBridged);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.draculaCurrentLine,
        title: Text(
          'Confirm Deletion',
          style: TextStyle(color: colors.draculaForeground),
        ),
        content: Text(
          'Are you sure you want to delete ${_selectedHabits.length} habit(s)? This action cannot be undone.',
          style: TextStyle(color: colors.draculaComment),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.draculaComment),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: colors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
      final habits = ref.read(habitListProvider).value ?? [];
      
      // Delete selected habits
      for (final habitId in _selectedHabits) {
        final habit = habits.firstWhere((h) => h.id == habitId);
        await habitsNotifier.removeHabit(habit);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedHabits.length} habit(s) deleted successfully'),
            backgroundColor: colors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting habits: $error'),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }
}