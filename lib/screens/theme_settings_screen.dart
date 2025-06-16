import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/flexible_theme_system.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentVariant = ref.watch(themeVariantProvider);
    final colors = ref.watchColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Theme Settings',
          style: TextStyle(color: colors.textPrimary),
        ),
        backgroundColor: colors.cardBackgroundDark,
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      backgroundColor: colors.backgroundDark,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Theme Variant',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.primaryPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All variants preserve your beautiful Dracula aesthetic',
              style: TextStyle(
                fontSize: 16,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: ThemeVariant.values.length,
                itemBuilder: (context, index) {
                  final variant = ThemeVariant.values[index];
                  final isSelected = variant == currentVariant;

                  return _ThemeVariantCard(
                    variant: variant,
                    isSelected: isSelected,
                    onTap: () => ref
                        .read(themeVariantProvider.notifier)
                        .setTheme(variant),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeVariantCard extends StatelessWidget {
  final ThemeVariant variant;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeVariantCard({
    required this.variant,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = FlexibleColors.of(variant);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? colors.primaryPurple : colors.borderLight,
          width: isSelected ? 3 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colors.primaryPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: colors.cardBackgroundDark,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      variant.displayName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.primaryPurple,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: colors.success,
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  variant.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Color preview
                Row(
                  children: [
                    _ColorDot(color: colors.primaryPurple, label: 'Purple'),
                    const SizedBox(width: 8),
                    _ColorDot(color: colors.draculaCyan, label: 'Cyan'),
                    const SizedBox(width: 8),
                    _ColorDot(color: colors.draculaPink, label: 'Pink'),
                    const SizedBox(width: 8),
                    _ColorDot(color: colors.draculaGreen, label: 'Green'),
                    const SizedBox(width: 8),
                    _ColorDot(color: colors.draculaOrange, label: 'Orange'),
                    const SizedBox(width: 8),
                    _ColorDot(color: colors.draculaYellow, label: 'Yellow'),
                  ],
                ),
                const SizedBox(height: 16),

                // Preview habit card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.backgroundDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.borderLight),
                    gradient: LinearGradient(
                      colors: [
                        colors.draculaCurrentLine.withOpacity(0.6),
                        colors.draculaCurrentLine.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors.draculaCyan.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.draculaCyan.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          color: colors.draculaCyan,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sample Habit',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colors.primaryPurple,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Basic Habit',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.draculaCyan,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.draculaPink,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.circle_outlined,
                          color: colors.draculaPink,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
      ),
    );
  }
}
