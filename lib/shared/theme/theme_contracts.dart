import 'package:flutter/material.dart';

/// Abstract contract for color palettes
abstract class IColorPalette {
  /// Palette identification
  String get name;
  
  /// Primary colors
  Color get primary;
  Color get primaryVariant;
  Color get secondary;
  Color get accent;
  
  /// Surface colors
  Color get surface;
  Color get background;
  Color get error;
  Color get success;
  
  /// Text colors
  Color get onPrimary;
  Color get onSecondary;
  Color get onSurface;
  Color get onError;
  
  /// Utility colors
  Color get divider;
  Color get shadow;
  Color get disabled;
  Color get hint;
  
  /// Convert to map for serialization
  Map<String, dynamic> toMap();
}

/// Abstract contract for theme configuration
abstract class IThemeConfig {
  /// Create Flutter ThemeData from color palette
  ThemeData createTheme(IColorPalette palette);
  
  /// Get brightness based on palette
  Brightness getBrightness(IColorPalette palette);
  
  /// Create component themes
  AppBarTheme createAppBarTheme(IColorPalette palette);
  CardThemeData createCardTheme(IColorPalette palette);
  ElevatedButtonThemeData createElevatedButtonTheme(IColorPalette palette);
  TextButtonThemeData createTextButtonTheme(IColorPalette palette);
  InputDecorationTheme createInputTheme(IColorPalette palette);
  SnackBarThemeData createSnackBarTheme(IColorPalette palette);
}

/// Abstract contract for theme controller
abstract class IThemeController {
  /// Current theme state
  IColorPalette get currentPalette;
  ThemeData get currentTheme;
  bool get isLoading;
  
  /// Theme management
  Future<void> loadTheme();
  Future<void> setTheme(String themeId);
  Future<void> resetToDefault();
  
  /// Available themes
  List<String> get availableThemes;
  String get currentThemeId;
  
  /// Persistence
  Future<void> saveThemePreference(String themeId);
  Future<String?> loadThemePreference();
}

/// Abstract contract for theme registry
abstract class IThemeRegistry {
  /// Register a theme palette
  void registerTheme(String id, IColorPalette palette);
  
  /// Get theme by ID
  IColorPalette? getTheme(String id);
  
  /// Get all available themes
  Map<String, IColorPalette> get allThemes;
  
  /// Check if theme exists
  bool hasTheme(String id);
  
  /// Get theme names
  List<String> get themeIds;
}

/// Theme event types for state management
enum ThemeEvent {
  load,
  change,
  reset,
  error,
}

/// Theme state for reactive programming
class ThemeState {
  final IColorPalette palette;
  final ThemeData themeData;
  final bool isLoading;
  final String? error;
  final ThemeEvent? lastEvent;

  const ThemeState({
    required this.palette,
    required this.themeData,
    this.isLoading = false,
    this.error,
    this.lastEvent,
  });

  ThemeState copyWith({
    IColorPalette? palette,
    ThemeData? themeData,
    bool? isLoading,
    String? error,
    ThemeEvent? lastEvent,
  }) {
    return ThemeState(
      palette: palette ?? this.palette,
      themeData: themeData ?? this.themeData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastEvent: lastEvent ?? this.lastEvent,
    );
  }
}

/// Exception for theme-related errors
class ThemeException implements Exception {
  final String message;
  final String? themeId;
  final dynamic originalError;

  const ThemeException(
    this.message, {
    this.themeId,
    this.originalError,
  });

  @override
  String toString() => 'ThemeException: $message${themeId != null ? ' (theme: $themeId)' : ''}';
}