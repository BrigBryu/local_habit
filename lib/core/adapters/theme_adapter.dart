import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/theme.dart';
import '../theme/color_palette.dart' as app_palette;
import '../theme/theme_controller.dart' as app_theme;

/// Adapter to bridge between app's theme system and shared theme system
class ThemeAdapter {
  /// Convert app ColorPalette to shared IColorPalette
  static BaseColorPalette fromAppPalette(app_palette.ColorPalette palette) {
    return BaseColorPalette(
      name: palette.name,
      primary: palette.primary,
      primaryVariant: palette.primaryVariant,
      secondary: palette.secondary,
      accent: palette.accent,
      surface: palette.surface,
      background: palette.background,
      error: palette.error,
      success: palette.green ?? palette.accent, // Fallback to accent if green not available
      onPrimary: palette.onPrimary,
      onSecondary: palette.onSecondary,
      onSurface: palette.onSurface,
      onError: palette.onError,
      divider: palette.divider,
      shadow: palette.shadow,
      disabled: palette.disabled,
      hint: palette.hint,
    );
  }

  /// Convert shared IColorPalette to app ColorPalette
  static app_palette.ColorPalette toAppPalette(IColorPalette palette) {
    return app_palette.ColorPalette(
      name: palette.name,
      primary: palette.primary,
      primaryVariant: palette.primaryVariant,
      secondary: palette.secondary,
      secondaryVariant: palette.secondary, // Use secondary as variant
      surface: palette.surface,
      background: palette.background,
      error: palette.error,
      onPrimary: palette.onPrimary,
      onSecondary: palette.onSecondary,
      onSurface: palette.onSurface,
      onBackground: palette.onSurface, // Use onSurface as fallback
      onError: palette.onError,
      accent: palette.accent,
      divider: palette.divider,
      shadow: palette.shadow,
      disabled: palette.disabled,
      hint: palette.hint,
    );
  }

  /// Initialize shared theme registry with app themes
  static void initializeSharedThemes() {
    final registry = ThemeRegistry();
    
    // Register default themes from shared system
    registry.registerDefaultThemes();
    
    // If app has custom themes, register them here
    // registry.registerTheme('custom', customPalette);
  }

  /// Get current theme colors in a format compatible with shared notifications
  static dynamic getCompatibleColors(WidgetRef ref) {
    final colors = ref.watch(app_theme.flexibleColorsProviderBridged);
    return colors;
  }
}

/// Provider for theme adapter
final themeAdapterProvider = Provider<ThemeAdapter>((ref) {
  return ThemeAdapter();
});