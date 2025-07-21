/// Shared Theme System
/// 
/// A comprehensive, reusable theme system that provides:
/// - Abstract contracts for theme components
/// - Base implementations for common use cases
/// - Theme registry for managing multiple palettes
/// - Consistent styling across applications
/// 
/// Usage:
/// ```dart
/// // Register themes
/// final registry = ThemeRegistry();
/// registry.registerDefaultThemes();
/// 
/// // Create theme config
/// final config = BaseThemeConfig();
/// final palette = registry.getTheme('dracula')!;
/// final theme = config.createTheme(palette);
/// 
/// // Use in MaterialApp
/// MaterialApp(
///   theme: theme,
///   // ...
/// )
/// ```

export 'theme_contracts.dart';
export 'base_color_palette.dart';
export 'base_theme_config.dart';
export 'theme_registry.dart';