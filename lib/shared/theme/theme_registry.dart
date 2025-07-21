import 'package:flutter/material.dart';
import 'theme_contracts.dart';
import 'base_color_palette.dart';

/// Registry for managing multiple theme palettes
class ThemeRegistry implements IThemeRegistry {
  final Map<String, IColorPalette> _themes = {};
  
  /// Singleton instance
  static final ThemeRegistry _instance = ThemeRegistry._internal();
  factory ThemeRegistry() => _instance;
  ThemeRegistry._internal();

  @override
  void registerTheme(String id, IColorPalette palette) {
    _themes[id] = palette;
  }

  @override
  IColorPalette? getTheme(String id) {
    return _themes[id];
  }

  @override
  Map<String, IColorPalette> get allThemes => Map.unmodifiable(_themes);

  @override
  bool hasTheme(String id) => _themes.containsKey(id);

  @override
  List<String> get themeIds => _themes.keys.toList();

  /// Register multiple themes at once
  void registerThemes(Map<String, IColorPalette> themes) {
    _themes.addAll(themes);
  }

  /// Remove a theme
  void removeTheme(String id) {
    _themes.remove(id);
  }

  /// Clear all themes
  void clearThemes() {
    _themes.clear();
  }

  /// Get theme or throw exception
  IColorPalette getThemeOrThrow(String id) {
    final theme = getTheme(id);
    if (theme == null) {
      throw ThemeException('Theme not found: $id', themeId: id);
    }
    return theme;
  }

  /// Register default themes
  void registerDefaultThemes() {
    // Dracula theme
    registerTheme(
      'dracula',
      const BaseColorPalette(
        name: 'Dracula',
        primary: Color(0xFFbd93f9),
        primaryVariant: Color(0xFF9580e6),
        secondary: Color(0xFF8be9fd),
        accent: Color(0xFFffb86c),
        surface: Color(0xFF44475a),
        background: Color(0xFF282a36),
        error: Color(0xFFff5555),
        success: Color(0xFF50fa7b),
        onPrimary: Color(0xFF282a36),
        onSecondary: Color(0xFF282a36),
        onSurface: Color(0xFFf8f8f2),
        onError: Color(0xFFf8f8f2),
        divider: Color(0xFF6272a4),
        shadow: Color(0xFF1a1b23),
        disabled: Color(0xFF6272a4),
        hint: Color(0xFF6272a4),
      ),
    );

    // Gruvbox theme
    registerTheme(
      'gruvbox',
      const BaseColorPalette(
        name: 'Gruvbox',
        primary: Color(0xFFfb4934),
        primaryVariant: Color(0xFFcc241d),
        secondary: Color(0xFF83a598),
        accent: Color(0xFFfe8019),
        surface: Color(0xFF3c3836),
        background: Color(0xFF282828),
        error: Color(0xFFfb4934),
        success: Color(0xFFb8bb26),
        onPrimary: Color(0xFFfbf1c7),
        onSecondary: Color(0xFFfbf1c7),
        onSurface: Color(0xFFebdbb2),
        onError: Color(0xFFfbf1c7),
        divider: Color(0xFF665c54),
        shadow: Color(0xFF1d2021),
        disabled: Color(0xFF928374),
        hint: Color(0xFF928374),
      ),
    );

    // Light theme
    registerTheme(
      'light',
      const BaseColorPalette(
        name: 'Light',
        primary: Color(0xFF2563eb),
        primaryVariant: Color(0xFF1d4ed8),
        secondary: Color(0xFF059669),
        accent: Color(0xFFf59e0b),
        surface: Color(0xFFffffff),
        background: Color(0xFFf9fafb),
        error: Color(0xFFdc2626),
        success: Color(0xFF059669),
        onPrimary: Color(0xFFffffff),
        onSecondary: Color(0xFFffffff),
        onSurface: Color(0xFF111827),
        onError: Color(0xFFffffff),
        divider: Color(0xFFe5e7eb),
        shadow: Color(0xFF6b7280),
        disabled: Color(0xFF9ca3af),
        hint: Color(0xFF6b7280),
      ),
    );

    // Dark theme
    registerTheme(
      'dark',
      const BaseColorPalette(
        name: 'Dark',
        primary: Color(0xFF3b82f6),
        primaryVariant: Color(0xFF2563eb),
        secondary: Color(0xFF10b981),
        accent: Color(0xFFf59e0b),
        surface: Color(0xFF1f2937),
        background: Color(0xFF111827),
        error: Color(0xFFef4444),
        success: Color(0xFF10b981),
        onPrimary: Color(0xFFffffff),
        onSecondary: Color(0xFFffffff),
        onSurface: Color(0xFFf9fafb),
        onError: Color(0xFFffffff),
        divider: Color(0xFF374151),
        shadow: Color(0xFF000000),
        disabled: Color(0xFF6b7280),
        hint: Color(0xFF9ca3af),
      ),
    );
  }
}