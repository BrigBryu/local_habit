import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
import 'color_palette.dart';

/// Theme variations that preserve your design language
enum ThemeVariant {
  dracula, // Your current theme (default)
  draculaWarm, // Warmer version of Dracula
  draculaCool, // Cooler version of Dracula
  draculaLight, // Light version maintaining Dracula aesthetics
  gruvboxDark, // Gruvbox dark theme
  gruvboxLight, // Gruvbox light theme
  // Popular theme variants from local_notes
  nord, // Nord arctic theme
  solarizedDark, // Solarized dark theme
  solarizedLight, // Solarized light theme
  monokai, // Monokai theme
  oneDark, // Atom One Dark theme
  tokyoNightStorm, // Tokyo Night Storm theme
  catppuccinMocha, // Catppuccin Mocha theme
  vampire, // Vampire theme
}

/// Theme-aware color provider that preserves your existing colors as default
class FlexibleColors {
  final ThemeVariant variant;
  final ColorPalette? palette;

  const FlexibleColors._(this.variant, [this.palette]);

  /// Factory constructor that returns appropriate colors based on theme
  factory FlexibleColors.of(ThemeVariant variant, [ColorPalette? palette]) {
    return FlexibleColors._(variant, palette);
  }

  // Core Dracula palette - now dynamically sourced from ColorPalette when available
  Color get draculaBackground {
    // Use palette background if available, otherwise fall back to theme-specific colors
    if (palette != null) {
      return palette!.background;
    }
    
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
      case ThemeVariant.nord:
        return const Color(0xFF2e3440); // Nord polar night
      case ThemeVariant.solarizedDark:
        return const Color(0xFF002b36); // Solarized dark base03
      case ThemeVariant.solarizedLight:
        return const Color(0xFFfdf6e3); // Solarized light base3
      case ThemeVariant.monokai:
        return const Color(0xFF272822); // Monokai background
      case ThemeVariant.oneDark:
        return const Color(0xFF282c34); // One Dark background
      case ThemeVariant.tokyoNightStorm:
        return const Color(0xFF24283b); // Tokyo Night Storm background
      case ThemeVariant.catppuccinMocha:
        return const Color(0xFF1e1e2e); // Catppuccin Mocha base
      case ThemeVariant.vampire:
        return const Color(0xFF1a1a1a); // Vampire dark background
    }
  }

  Color get draculaCurrentLine {
    // Use palette surface if available, otherwise fall back to theme-specific colors
    if (palette != null) {
      return palette!.surface;
    }
    
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
      case ThemeVariant.nord:
        return const Color(0xFF3b4252); // Nord polar night darker
      case ThemeVariant.solarizedDark:
        return const Color(0xFF073642); // Solarized dark base02
      case ThemeVariant.solarizedLight:
        return const Color(0xFFeee8d5); // Solarized light base2
      case ThemeVariant.monokai:
        return const Color(0xFF383830); // Monokai surface
      case ThemeVariant.oneDark:
        return const Color(0xFF3e4451); // One Dark surface
      case ThemeVariant.tokyoNightStorm:
        return const Color(0xFF32344a); // Tokyo Night Storm surface
      case ThemeVariant.catppuccinMocha:
        return const Color(0xFF313244); // Catppuccin Mocha surface
      case ThemeVariant.vampire:
        return const Color(0xFF2d1b21); // Vampire surface
    }
  }

  Color get draculaForeground {
    // Use palette onBackground if available, otherwise fall back to theme-specific colors
    if (palette != null) {
      return palette!.onBackground;
    }
    
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
      case ThemeVariant.nord:
        return const Color(0xFFd8dee9); // Nord snow storm
      case ThemeVariant.solarizedDark:
        return const Color(0xFF839496); // Solarized dark base0
      case ThemeVariant.solarizedLight:
        return const Color(0xFF586e75); // Solarized light base01
      case ThemeVariant.monokai:
        return const Color(0xFFf8f8f2); // Monokai foreground
      case ThemeVariant.oneDark:
        return const Color(0xFFabb2bf); // One Dark foreground
      case ThemeVariant.tokyoNightStorm:
        return const Color(0xFFa9b1d6); // Tokyo Night Storm foreground
      case ThemeVariant.catppuccinMocha:
        return const Color(0xFFcdd6f4); // Catppuccin Mocha text
      case ThemeVariant.vampire:
        return const Color(0xFFe0d4e7); // Vampire foreground
    }
  }

  Color get draculaComment {
    // Use palette disabled if available, otherwise fall back to theme-specific colors
    if (palette != null) {
      return palette!.disabled;
    }
    
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
      case ThemeVariant.nord:
        return const Color(0xFF616e88); // Nord frost muted
      case ThemeVariant.solarizedDark:
        return const Color(0xFF586e75); // Solarized dark base01
      case ThemeVariant.solarizedLight:
        return const Color(0xFF839496); // Solarized light base00
      case ThemeVariant.monokai:
        return const Color(0xFF75715e); // Monokai comment
      case ThemeVariant.oneDark:
        return const Color(0xFF5c6370); // One Dark comment
      case ThemeVariant.tokyoNightStorm:
        return const Color(0xFF565f89); // Tokyo Night Storm comment
      case ThemeVariant.catppuccinMocha:
        return const Color(0xFF6c7086); // Catppuccin Mocha overlay0
      case ThemeVariant.vampire:
        return const Color(0xFF6b5563); // Vampire disabled
    }
  }

  // Accent colors - now mapped to palette colors when available
  Color get draculaCyan {
    // Use palette cyan if available, otherwise fall back to theme-specific colors
    if (palette != null && palette!.cyan != null) {
      return palette!.cyan!;
    }
    
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
      case ThemeVariant.nord:
        return const Color(0xFF88c0d0); // Nord frost cyan
      case ThemeVariant.solarizedDark:
        return const Color(0xFF2aa198); // Solarized dark cyan
      case ThemeVariant.solarizedLight:
        return const Color(0xFF2aa198); // Solarized light cyan
      case ThemeVariant.monokai:
        return const Color(0xFF66d9ef); // Monokai cyan
      case ThemeVariant.oneDark:
        return const Color(0xFF56b6c2); // One Dark cyan
      case ThemeVariant.tokyoNightStorm:
        return const Color(0xFF7dcfff); // Tokyo Night Storm cyan
      case ThemeVariant.catppuccinMocha:
        return const Color(0xFF94e2d5); // Catppuccin Mocha teal
      case ThemeVariant.vampire:
        return const Color(0xFF80ffea); // Vampire cyan
    }
  }

  Color get draculaGreen {
    // Use palette green if available, otherwise fall back to theme-specific colors
    if (palette != null && palette!.green != null) {
      return palette!.green!;
    }
    
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
      case ThemeVariant.nord:
        return const Color(0xFFa3be8c); // Nord aurora green
      case ThemeVariant.solarizedDark:
        return const Color(0xFF859900); // Solarized dark green
      case ThemeVariant.solarizedLight:
        return const Color(0xFF859900); // Solarized light green
      case ThemeVariant.monokai:
        return const Color(0xFFa6e22e); // Monokai green
      case ThemeVariant.oneDark:
        return const Color(0xFF98c379); // One Dark green
      case ThemeVariant.tokyoNightStorm:
        return const Color(0xFF9ece6a); // Tokyo Night Storm green
      case ThemeVariant.catppuccinMocha:
        return const Color(0xFFa6e3a1); // Catppuccin Mocha green
      case ThemeVariant.vampire:
        return const Color(0xFFa9dc76); // Vampire green
    }
  }

  Color get draculaOrange {
    // Use palette accent if available (mapped to orange), otherwise fall back to theme-specific colors
    if (palette != null) {
      return palette!.accent;
    }
    
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
      case ThemeVariant.nord:
        return const Color(0xFFd08770); // Nord aurora orange
      case ThemeVariant.solarizedDark:
        return const Color(0xFFcb4b16); // Solarized dark orange
      case ThemeVariant.solarizedLight:
        return const Color(0xFFcb4b16); // Solarized light orange
      case ThemeVariant.monokai:
        return const Color(0xFFfd971f); // Monokai orange
      case ThemeVariant.oneDark:
        return const Color(0xFFd19a66); // One Dark orange
      case ThemeVariant.tokyoNightStorm:
        return const Color(0xFFff9e64); // Tokyo Night Storm orange
      case ThemeVariant.catppuccinMocha:
        return const Color(0xFFfab387); // Catppuccin Mocha peach
      case ThemeVariant.vampire:
        return const Color(0xFFffb86c); // Vampire orange
    }
  }

  Color get draculaPink {
    // Use palette magenta if available (mapped to pink), otherwise fall back to theme-specific colors
    if (palette != null && palette!.magenta != null) {
      return palette!.magenta!;
    }
    
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
      case ThemeVariant.nord:
        return const Color(0xFFb48ead); // Nord aurora magenta
      case ThemeVariant.solarizedDark:
        return const Color(0xFFd33682); // Solarized dark magenta
      case ThemeVariant.solarizedLight:
        return const Color(0xFFd33682); // Solarized light magenta
      case ThemeVariant.monokai:
        return const Color(0xFFf92672); // Monokai pink
      case ThemeVariant.oneDark:
        return const Color(0xFFe06c75); // One Dark red (as pink)
      case ThemeVariant.tokyoNightStorm:
        return const Color(0xFFf7768e); // Tokyo Night Storm red
      case ThemeVariant.catppuccinMocha:
        return const Color(0xFFf5c2e7); // Catppuccin Mocha pink
      case ThemeVariant.vampire:
        return const Color(0xFFff5b5b); // Vampire red
    }
  }

  Color get draculaPurple {
    // Use palette blue if available (mapped to purple), otherwise fall back to theme-specific colors
    if (palette != null && palette!.blue != null) {
      return palette!.blue!;
    }
    
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
      case ThemeVariant.nord:
        return const Color(0xFF5e81ac); // Nord frost blue
      case ThemeVariant.solarizedDark:
        return const Color(0xFF268bd2); // Solarized dark blue
      case ThemeVariant.solarizedLight:
        return const Color(0xFF268bd2); // Solarized light blue
      case ThemeVariant.monokai:
        return const Color(0xFFae81ff); // Monokai purple
      case ThemeVariant.oneDark:
        return const Color(0xFFc678dd); // One Dark purple
      case ThemeVariant.tokyoNightStorm:
        return const Color(0xFFbb9af7); // Tokyo Night Storm purple
      case ThemeVariant.catppuccinMocha:
        return const Color(0xFFcba6f7); // Catppuccin Mocha mauve
      case ThemeVariant.vampire:
        return const Color(0xFFab9df2); // Vampire purple
    }
  }

  Color get draculaRed {
    // Use palette red if available, otherwise fall back to theme-specific colors
    if (palette != null && palette!.red != null) {
      return palette!.red!;
    }
    
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
      case ThemeVariant.nord:
        return const Color(0xFFbf616a); // Nord aurora red
      case ThemeVariant.solarizedDark:
        return const Color(0xFFdc322f); // Solarized dark red
      case ThemeVariant.solarizedLight:
        return const Color(0xFFdc322f); // Solarized light red
      case ThemeVariant.monokai:
        return const Color(0xFFf92672); // Monokai red
      case ThemeVariant.oneDark:
        return const Color(0xFFe06c75); // One Dark red
      case ThemeVariant.tokyoNightStorm:
        return const Color(0xFFf7768e); // Tokyo Night Storm red
      case ThemeVariant.catppuccinMocha:
        return const Color(0xFFf38ba8); // Catppuccin Mocha red
      case ThemeVariant.vampire:
        return const Color(0xFFff5b5b); // Vampire red
    }
  }

  Color get draculaYellow {
    // Use palette yellow if available, otherwise fall back to theme-specific colors
    if (palette != null && palette!.yellow != null) {
      return palette!.yellow!;
    }
    
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
      case ThemeVariant.nord:
        return const Color(0xFFebcb8b); // Nord aurora yellow
      case ThemeVariant.solarizedDark:
        return const Color(0xFFb58900); // Solarized dark yellow
      case ThemeVariant.solarizedLight:
        return const Color(0xFFb58900); // Solarized light yellow
      case ThemeVariant.monokai:
        return const Color(0xFFe6db74); // Monokai yellow
      case ThemeVariant.oneDark:
        return const Color(0xFFe5c07b); // One Dark yellow
      case ThemeVariant.tokyoNightStorm:
        return const Color(0xFFe0af68); // Tokyo Night Storm yellow
      case ThemeVariant.catppuccinMocha:
        return const Color(0xFFf9e2af); // Catppuccin Mocha yellow
      case ThemeVariant.vampire:
        return const Color(0xFFffd866); // Vampire yellow
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
      case ThemeVariant.nord:
        return const Color(0xFFd8dee9); // Nord snow storm (lighter)
      case ThemeVariant.solarizedDark:
        return const Color(0xFF93a1a1); // Solarized dark base1
      case ThemeVariant.solarizedLight:
        return const Color(0xFF93a1a1); // Solarized light base1
      case ThemeVariant.monokai:
        return const Color(0xFFae81ff); // Monokai purple (lighter)
      case ThemeVariant.oneDark:
        return const Color(0xFFc678dd); // One Dark purple (lighter)
      case ThemeVariant.tokyoNightStorm:
        return const Color(0xFFbb9af7); // Tokyo Night Storm purple (lighter)
      case ThemeVariant.catppuccinMocha:
        return const Color(0xFFcba6f7); // Catppuccin Mocha mauve (lighter)
      case ThemeVariant.vampire:
        return const Color(0xFFab9df2); // Vampire purple (lighter)
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

  // Action colors - now mapped to palette colors when available
  Color get success {
    return draculaGreen; // Use the palette-aware draculaGreen getter
  }

  Color get error {
    // Use palette error if available, otherwise use palette-aware draculaRed
    if (palette != null) {
      return palette!.error;
    }
    return draculaRed; // Use the palette-aware draculaRed getter
  }

  Color get warning {
    return draculaYellow; // Use the palette-aware draculaYellow getter
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

  // Success background color for completed states
  Color get successBg => completedBackground;

  // Success foreground color for text/icons on success backgrounds
  Color get successFg {
    switch (variant) {
      case ThemeVariant.draculaLight:
        return const Color(0xFF065F46); // Dark green text for light backgrounds
      case ThemeVariant.gruvboxLight:
        return const Color(0xFF427B58); // Gruvbox dark green for light theme
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
  // For now, we'll pass null as the palette - this can be updated later
  // when you have a way to provide ColorPalette instances
  return FlexibleColors.of(variant, null);
});

/// Extension for easy access to theme-aware colors (DEPRECATED - use theme_controller.dart)
extension ThemeAwareColorsOld on WidgetRef {
  /// Get theme-aware colors (preserves your existing color design)
  FlexibleColors get colorsOld => read(flexibleColorsProvider);

  /// Watch theme-aware colors for rebuilds
  FlexibleColors get watchColorsOld => watch(flexibleColorsProvider);
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
      case ThemeVariant.nord:
        return 'Nord';
      case ThemeVariant.solarizedDark:
        return 'Solarized Dark';
      case ThemeVariant.solarizedLight:
        return 'Solarized Light';
      case ThemeVariant.monokai:
        return 'Monokai';
      case ThemeVariant.oneDark:
        return 'One Dark';
      case ThemeVariant.tokyoNightStorm:
        return 'Tokyo Night Storm';
      case ThemeVariant.catppuccinMocha:
        return 'Catppuccin Mocha';
      case ThemeVariant.vampire:
        return 'Vampire';
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
      case ThemeVariant.nord:
        return 'Arctic, north-bluish color palette';
      case ThemeVariant.solarizedDark:
        return 'Precision colors for machines and people';
      case ThemeVariant.solarizedLight:
        return 'Light version of the precision color scheme';
      case ThemeVariant.monokai:
        return 'Vibrant syntax highlighting theme';
      case ThemeVariant.oneDark:
        return 'Dark theme from Atom One Dark';
      case ThemeVariant.tokyoNightStorm:
        return 'Clean, dark theme inspired by Tokyo nights';
      case ThemeVariant.catppuccinMocha:
        return 'Soothing pastel theme for coders';
      case ThemeVariant.vampire:
        return 'Dark theme with subtle red undertones';
    }
  }
}
