import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

/// Theme variations that preserve your design language
enum ThemeVariant {
  dracula, // Your current theme (default)
  draculaWarm, // Warmer version of Dracula
  draculaCool, // Cooler version of Dracula
  draculaLight, // Light version maintaining Dracula aesthetics
  gruvboxDark, // Gruvbox dark theme
  gruvboxLight, // Gruvbox light theme
}

/// Theme-aware color provider that preserves your existing colors as default
class FlexibleColors {
  final ThemeVariant variant;

  const FlexibleColors._(this.variant);

  /// Factory constructor that returns appropriate colors based on theme
  factory FlexibleColors.of(ThemeVariant variant) {
    return FlexibleColors._(variant);
  }

  // Core Dracula palette - preserved exactly as you designed
  Color get draculaBackground {
    switch (variant) {
      case ThemeVariant.dracula:
        return AppColors.draculaBackground;
      case ThemeVariant.draculaWarm:
        return const Color(0xFF332838); // Warmer purple-tinted background
      case ThemeVariant.draculaCool:
        return const Color(0xFF1E2A3A); // Cooler blue-tinted background
      case ThemeVariant.draculaLight:
        return const Color(0xFFF8F8F2); // Light background
      case ThemeVariant.gruvboxDark:
        return const Color(0xFF282828); // Gruvbox dark bg
      case ThemeVariant.gruvboxLight:
        return const Color(0xFFFBF1C7); // Gruvbox light bg
    }
  }

  Color get draculaCurrentLine {
    switch (variant) {
      case ThemeVariant.dracula:
        return AppColors.draculaCurrentLine;
      case ThemeVariant.draculaWarm:
        return const Color(0xFF4A435C); // Warmer purple-gray
      case ThemeVariant.draculaCool:
        return const Color(0xFF3F475F); // Cooler blue-gray
      case ThemeVariant.draculaLight:
        return const Color(0xFFE5E7EB); // Light gray
      case ThemeVariant.gruvboxDark:
        return const Color(0xFF3C3836); // Gruvbox dark bg1
      case ThemeVariant.gruvboxLight:
        return const Color(0xFFEBDBB2); // Gruvbox light bg1
    }
  }

  Color get draculaForeground {
    switch (variant) {
      case ThemeVariant.dracula:
        return AppColors.draculaForeground;
      case ThemeVariant.draculaWarm:
        return const Color(0xFFFAF8F3); // Warmer cream-white
      case ThemeVariant.draculaCool:
        return const Color(0xFFF4F6FA); // Cooler blue-white
      case ThemeVariant.draculaLight:
        return const Color(0xFF1F2937); // Dark text for light theme
      case ThemeVariant.gruvboxDark:
        return const Color(0xFFEBDBB2); // Gruvbox dark fg1
      case ThemeVariant.gruvboxLight:
        return const Color(0xFF1D2021); // Much darker color for better contrast
    }
  }

  Color get draculaComment {
    switch (variant) {
      case ThemeVariant.dracula:
        return AppColors.draculaComment;
      case ThemeVariant.draculaWarm:
        return const Color(0xFF6B71A8); // Warmer comment
      case ThemeVariant.draculaCool:
        return const Color(0xFF5F73A0); // Cooler comment
      case ThemeVariant.draculaLight:
        return const Color(0xFF6B7280); // Light theme comment
      case ThemeVariant.gruvboxDark:
        return const Color(0xFF928374); // Gruvbox dark gray
      case ThemeVariant.gruvboxLight:
        return const Color(0xFF928374); // Gruvbox light gray (alt-2)
    }
  }

  // Accent colors - keep the Dracula aesthetic but allow variations
  Color get draculaCyan {
    switch (variant) {
      case ThemeVariant.dracula:
        return AppColors.draculaCyan;
      case ThemeVariant.draculaWarm:
        return const Color(0xFF7BDCEF); // Warmer teal-cyan
      case ThemeVariant.draculaCool:
        return const Color(0xFF69D9FF); // Cooler bright cyan
      case ThemeVariant.draculaLight:
        return const Color(
            0xFF0E7490); // Even darker cyan for better readability
      case ThemeVariant.gruvboxDark:
        return const Color(0xFF689D6A); // Gruvbox dark aqua
      case ThemeVariant.gruvboxLight:
        return const Color(0xFF427B58); // Gruvbox light aqua (alt)
    }
  }

  Color get draculaGreen {
    switch (variant) {
      case ThemeVariant.dracula:
        return AppColors.draculaGreen;
      case ThemeVariant.draculaWarm:
        return const Color(0xFF5DFA7D); // Warmer yellow-green
      case ThemeVariant.draculaCool:
        return const Color(0xFF3BFA73); // Cooler mint-green
      case ThemeVariant.draculaLight:
        return const Color(0xFF059669); // Darker green for light theme
      case ThemeVariant.gruvboxDark:
        return const Color(0xFF98971A); // Gruvbox dark green
      case ThemeVariant.gruvboxLight:
        return const Color(0xFF79740E); // Gruvbox light green (alt)
    }
  }

  Color get draculaOrange {
    switch (variant) {
      case ThemeVariant.dracula:
        return AppColors.draculaOrange;
      case ThemeVariant.draculaWarm:
        return const Color(0xFFFF9F5C); // Warmer red-orange
      case ThemeVariant.draculaCool:
        return const Color(0xFFFFCA7C); // Cooler yellow-orange
      case ThemeVariant.draculaLight:
        return const Color(0xFFEA580C); // Darker orange for light theme
      case ThemeVariant.gruvboxDark:
        return const Color(0xFFD65D0E); // Gruvbox dark orange
      case ThemeVariant.gruvboxLight:
        return const Color(0xFFAF3A03); // Gruvbox light orange (alt)
    }
  }

  Color get draculaPink {
    switch (variant) {
      case ThemeVariant.dracula:
        return AppColors.draculaPink;
      case ThemeVariant.draculaWarm:
        return const Color(0xFFFF69B4); // Warmer hot pink
      case ThemeVariant.draculaCool:
        return const Color(0xFFFF8ADB); // Cooler lavender pink
      case ThemeVariant.draculaLight:
        return const Color(
            0xFFBE185D); // Even darker pink for better readability
      case ThemeVariant.gruvboxDark:
        return const Color(0xFFB16286); // Gruvbox dark purple
      case ThemeVariant.gruvboxLight:
        return const Color(0xFF8F3F71); // Gruvbox light purple (alt)
    }
  }

  Color get draculaPurple {
    switch (variant) {
      case ThemeVariant.dracula:
        return AppColors.draculaPurple;
      case ThemeVariant.draculaWarm:
        return const Color(0xFFC77DFF); // Warmer violet-purple
      case ThemeVariant.draculaCool:
        return const Color(0xFFA885FF); // Cooler blue-purple
      case ThemeVariant.draculaLight:
        return const Color(
            0xFF6D28D9); // Even darker purple for better readability
      case ThemeVariant.gruvboxDark:
        return const Color(0xFF458588); // Gruvbox dark blue
      case ThemeVariant.gruvboxLight:
        return const Color(0xFF076678); // Gruvbox light blue (alt)
    }
  }

  Color get draculaRed {
    switch (variant) {
      case ThemeVariant.dracula:
        return AppColors.draculaRed;
      case ThemeVariant.draculaWarm:
        return const Color(0xFFFF4444); // Warmer scarlet red
      case ThemeVariant.draculaCool:
        return const Color(0xFFFF6B6B); // Cooler coral red
      case ThemeVariant.draculaLight:
        return const Color(0xFFDC2626); // Darker red for light theme
      case ThemeVariant.gruvboxDark:
        return const Color(0xFFCC241D); // Gruvbox dark red
      case ThemeVariant.gruvboxLight:
        return const Color(0xFF9D0006); // Gruvbox light red (alt)
    }
  }

  Color get draculaYellow {
    switch (variant) {
      case ThemeVariant.dracula:
        return AppColors.draculaYellow;
      case ThemeVariant.draculaWarm:
        return const Color(0xFFFFF176); // Warmer golden yellow
      case ThemeVariant.draculaCool:
        return const Color(0xFFE8F5A2); // Cooler lime yellow
      case ThemeVariant.draculaLight:
        return const Color(
            0xFFB45309); // Even darker yellow for better readability
      case ThemeVariant.gruvboxDark:
        return const Color(0xFFD79921); // Gruvbox dark yellow
      case ThemeVariant.gruvboxLight:
        return const Color(0xFFB57614); // Gruvbox light yellow (alt)
    }
  }

  // Semantic colors mapped to your existing system
  Color get primaryPurple => draculaPurple;
  Color get lightPurple {
    switch (variant) {
      case ThemeVariant.dracula:
        return AppColors.lightPurple;
      case ThemeVariant.draculaWarm:
        return const Color(0xFFD6C7F9);
      case ThemeVariant.draculaCool:
        return const Color(0xFFD2C3F9);
      case ThemeVariant.draculaLight:
        return const Color(0xFFDDD6FE);
      case ThemeVariant.gruvboxDark:
        return const Color(0xFF83A598); // Gruvbox dark blue (lighter)
      case ThemeVariant.gruvboxLight:
        return const Color(0xFFBDAE93); // Gruvbox light fg3
    }
  }

  Color get darkPurple => AppColors.darkPurple;
  Color get purpleAccent => draculaPink;

  // Action colors - light/dark variants (main colors defined below)
  Color get successLight => AppColors.successLight;
  Color get successDark => AppColors.successDark;
  Color get warningLight => AppColors.warningLight;
  Color get warningDark => AppColors.warningDark;
  Color get errorLight => AppColors.errorLight;
  Color get errorDark => AppColors.errorDark;

  // Habit type colors - keep your exact assignments
  Color get basicHabit => draculaCyan;
  Color get avoidanceHabit => draculaRed;
  Color get bundleHabit => draculaPurple;
  Color get stackHabit => draculaOrange;

  // UI colors - adapted to theme but preserving your design intent
  Color get backgroundLight {
    switch (variant) {
      case ThemeVariant.draculaLight:
        return draculaForeground; // White background for light theme
      default:
        return AppColors.backgroundLight;
    }
  }

  Color get backgroundDark => draculaBackground;

  Color get cardBackground {
    switch (variant) {
      case ThemeVariant.draculaLight:
        return const Color(0xFFFFFFFF);
      default:
        return AppColors.cardBackground;
    }
  }

  Color get cardBackgroundDark => draculaCurrentLine;
  Color get surfaceBackground => draculaForeground;
  Color get habitCardBackground => draculaCurrentLine;

  Color get textPrimary {
    switch (variant) {
      case ThemeVariant.draculaLight:
        return draculaForeground; // Dark text for light theme
      default:
        return AppColors.textPrimary;
    }
  }

  Color get textSecondary => draculaComment;
  Color get textTertiary => AppColors.textTertiary;
  Color get textLight => draculaForeground;

  // Border colors
  Color get borderLight => draculaCurrentLine;
  Color get borderMedium => draculaComment;
  Color get borderDark => AppColors.borderDark;

  // Interactive states
  Color get disabled => draculaComment;
  Color get disabledBackground => draculaCurrentLine;
  Color get hover => AppColors.hover;
  Color get pressed => AppColors.pressed;

  // Completion states
  Color get completed => draculaGreen;
  Color get incomplete => draculaComment;
  Color get incompleteBackground => AppColors.incompleteBackground;

  // Action colors - theme-aware success, error, warning
  Color get success {
    switch (variant) {
      case ThemeVariant.dracula:
        return AppColors.success;
      case ThemeVariant.draculaWarm:
        return const Color(0xFF4AFA73); // Warmer green
      case ThemeVariant.draculaCool:
        return const Color(0xFF46FA83); // Cooler green
      case ThemeVariant.draculaLight:
        return const Color(0xFF059669); // Dark green for light theme
      case ThemeVariant.gruvboxDark:
        return const Color(0xFF98971A); // Gruvbox dark green
      case ThemeVariant.gruvboxLight:
        return const Color(0xFF79740E); // Gruvbox light green (alt)
    }
  }

  Color get error {
    switch (variant) {
      case ThemeVariant.dracula:
        return AppColors.error;
      case ThemeVariant.draculaWarm:
        return const Color(0xFFFF5050); // Warmer red
      case ThemeVariant.draculaCool:
        return const Color(0xFFFF5A5A); // Cooler red
      case ThemeVariant.draculaLight:
        return const Color(0xFFDC2626); // Dark red for light theme
      case ThemeVariant.gruvboxDark:
        return const Color(0xFFCC241D); // Gruvbox dark red
      case ThemeVariant.gruvboxLight:
        return const Color(0xFF9D0006); // Gruvbox light red (alt)
    }
  }

  Color get warning {
    switch (variant) {
      case ThemeVariant.dracula:
        return AppColors.warning;
      case ThemeVariant.draculaWarm:
        return const Color(0xFFF1FA86); // Warmer yellow
      case ThemeVariant.draculaCool:
        return const Color(0xFFF1FA92); // Cooler yellow
      case ThemeVariant.draculaLight:
        return const Color(0xFFB45309); // Dark yellow for light theme
      case ThemeVariant.gruvboxDark:
        return const Color(0xFFD79921); // Gruvbox dark yellow
      case ThemeVariant.gruvboxLight:
        return const Color(0xFFB57614); // Gruvbox light yellow (alt)
    }
  }

  // Form field colors - better contrast for light theme
  Color get formFieldLabel {
    switch (variant) {
      case ThemeVariant.draculaLight:
        return const Color(
            0xFF374151); // Much darker gray for light theme readability
      case ThemeVariant.gruvboxLight:
        return const Color(0xFF3C3836); // Gruvbox light fg (primary)
      default:
        return draculaCyan; // Original cyan for dark themes
    }
  }

  Color get formFieldBorder {
    switch (variant) {
      case ThemeVariant.draculaLight:
        return const Color(0xFF6B7280); // Medium gray for light theme borders
      case ThemeVariant.gruvboxLight:
        return const Color(0xFF928374); // Gruvbox light gray (alt-2)
      default:
        return draculaCyan; // Original cyan for dark themes
    }
  }

  Color get completedTextOnGreen {
    switch (variant) {
      case ThemeVariant.draculaLight:
        return const Color(
            0xFF065F46); // Very dark green text on light green background
      case ThemeVariant.gruvboxLight:
        return const Color(0xFF3C3836); // Gruvbox light fg (primary)
      default:
        return draculaForeground; // White text on dark themes
    }
  }
  
  // Gruvbox colors from AppColors for compatibility
  Color get gruvboxYellow => AppColors.gruvboxYellow;
  Color get gruvboxBlue => AppColors.gruvboxBlue;
  Color get gruvboxRed => AppColors.gruvboxRed;
  Color get gruvboxGreen => AppColors.gruvboxGreen;
  Color get gruvboxFg => AppColors.gruvboxFg;
  Color get gruvboxBg => AppColors.gruvboxBg;
  Color get gruvboxBg2 => AppColors.gruvboxBg2;

  // Completion background colors - lighter in light mode for better visibility
  Color get completedBackground {
    switch (variant) {
      case ThemeVariant.draculaLight:
        return const Color(
            0xFFD1FAE5); // Light green background for light theme
      case ThemeVariant.gruvboxLight:
        return const Color(0xFFD5C4A1); // Gruvbox light bg2 with green tint
      default:
        return draculaGreen; // Original green for dark themes
    }
  }

  Color get completedBorder {
    switch (variant) {
      case ThemeVariant.draculaLight:
        return const Color(0xFF34D399); // Medium green border for light theme
      case ThemeVariant.gruvboxLight:
        return const Color(0xFF79740E); // Gruvbox light green (alt)
      default:
        return draculaGreen; // Original green for dark themes
    }
  }
}

/// Theme state management
class ThemeNotifier extends StateNotifier<ThemeVariant> {
  static const String _key = 'theme_variant';

  ThemeNotifier() : super(ThemeVariant.dracula) {
    _loadTheme();
  }

  Future<void> setTheme(ThemeVariant variant) async {
    state = variant;
    await _saveTheme(variant);
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_key);
      if (themeIndex != null && themeIndex < ThemeVariant.values.length) {
        state = ThemeVariant.values[themeIndex];
      }
    } catch (e) {
      // Keep default theme on error
    }
  }

  Future<void> _saveTheme(ThemeVariant variant) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, variant.index);
    } catch (e) {
      // Ignore save errors
    }
  }
}

/// Providers for theme system
final themeVariantProvider =
    StateNotifierProvider<ThemeNotifier, ThemeVariant>((ref) {
  return ThemeNotifier();
});

final flexibleColorsProvider = Provider<FlexibleColors>((ref) {
  final variant = ref.watch(themeVariantProvider);
  return FlexibleColors.of(variant);
});

/// Extension for easy access to theme-aware colors
extension ThemeAwareColors on WidgetRef {
  /// Get theme-aware colors (preserves your existing color design)
  FlexibleColors get colors => read(flexibleColorsProvider);

  /// Watch theme-aware colors for rebuilds
  FlexibleColors get watchColors => watch(flexibleColorsProvider);
}

/// Helper for theme names
extension ThemeVariantExtension on ThemeVariant {
  String get displayName {
    switch (this) {
      case ThemeVariant.dracula:
        return 'Dracula (Default)';
      case ThemeVariant.draculaWarm:
        return 'Dracula Warm';
      case ThemeVariant.draculaCool:
        return 'Dracula Cool';
      case ThemeVariant.draculaLight:
        return 'Dracula Light';
      case ThemeVariant.gruvboxDark:
        return 'Gruvbox Dark';
      case ThemeVariant.gruvboxLight:
        return 'Gruvbox Light';
    }
  }

  String get description {
    switch (this) {
      case ThemeVariant.dracula:
        return 'Your original beautiful dark theme';
      case ThemeVariant.draculaWarm:
        return 'Warmer tones for cozy environments';
      case ThemeVariant.draculaCool:
        return 'Cooler tones for focused work';
      case ThemeVariant.draculaLight:
        return 'Light theme maintaining Dracula aesthetics';
      case ThemeVariant.gruvboxDark:
        return 'Warm and earthy dark theme inspired by Gruvbox';
      case ThemeVariant.gruvboxLight:
        return 'Light and warm theme with retro vibes';
    }
  }
}
