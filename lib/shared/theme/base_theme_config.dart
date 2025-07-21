import 'package:flutter/material.dart';
import 'theme_contracts.dart';

/// Base implementation of theme configuration
class BaseThemeConfig implements IThemeConfig {
  const BaseThemeConfig();

  @override
  ThemeData createTheme(IColorPalette palette) {
    final brightness = getBrightness(palette);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: brightness,
    ).copyWith(
      primary: palette.primary,
      secondary: palette.secondary,
      surface: palette.surface,
      error: palette.error,
      onPrimary: palette.onPrimary,
      onSecondary: palette.onSecondary,
      onSurface: palette.onSurface,
      onError: palette.onError,
      outline: palette.divider,
      shadow: palette.shadow,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      dividerColor: palette.divider,
      shadowColor: palette.shadow,
      disabledColor: palette.disabled,
      hintColor: palette.hint,
      
      // Component themes
      appBarTheme: createAppBarTheme(palette),
      cardTheme: createCardTheme(palette),
      elevatedButtonTheme: createElevatedButtonTheme(palette),
      textButtonTheme: createTextButtonTheme(palette),
      inputDecorationTheme: createInputTheme(palette),
      snackBarTheme: createSnackBarTheme(palette),
      
      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),
      
      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),
      
      // Icon theme
      iconTheme: IconThemeData(
        color: palette.onSurface,
      ),
      
      // FAB theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.accent,
        foregroundColor: palette.onPrimary,
      ),
      
      // Text theme
      textTheme: _createTextTheme(palette),
    );
  }

  @override
  Brightness getBrightness(IColorPalette palette) {
    final luminance = palette.surface.computeLuminance();
    return luminance > 0.5 ? Brightness.light : Brightness.dark;
  }

  @override
  AppBarTheme createAppBarTheme(IColorPalette palette) {
    return AppBarTheme(
      backgroundColor: palette.surface,
      foregroundColor: palette.onSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: palette.onSurface),
    );
  }

  @override
  CardThemeData createCardTheme(IColorPalette palette) {
    return CardThemeData(
      color: palette.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  ElevatedButtonThemeData createElevatedButtonTheme(IColorPalette palette) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    );
  }

  @override
  TextButtonThemeData createTextButtonTheme(IColorPalette palette) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: palette.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  InputDecorationTheme createInputTheme(IColorPalette palette) {
    return InputDecorationTheme(
      filled: true,
      fillColor: palette.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: palette.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: palette.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: palette.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: palette.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: palette.error, width: 2),
      ),
      labelStyle: TextStyle(color: palette.hint),
      hintStyle: TextStyle(color: palette.hint),
    );
  }

  @override
  SnackBarThemeData createSnackBarTheme(IColorPalette palette) {
    return SnackBarThemeData(
      backgroundColor: palette.surface,
      contentTextStyle: TextStyle(
        color: palette.onSurface,
        fontWeight: FontWeight.w500,
      ),
      actionTextColor: palette.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      dismissDirection: DismissDirection.down,
      insetPadding: const EdgeInsets.all(16),
      actionOverflowThreshold: 0.25,
    );
  }

  /// Create text theme based on palette
  TextTheme _createTextTheme(IColorPalette palette) {
    return TextTheme(
      headlineLarge: TextStyle(color: palette.onSurface),
      headlineMedium: TextStyle(color: palette.onSurface),
      headlineSmall: TextStyle(color: palette.onSurface),
      titleLarge: TextStyle(color: palette.onSurface),
      titleMedium: TextStyle(color: palette.onSurface),
      titleSmall: TextStyle(color: palette.onSurface),
      bodyLarge: TextStyle(color: palette.onSurface),
      bodyMedium: TextStyle(color: palette.onSurface),
      bodySmall: TextStyle(color: palette.hint),
      labelLarge: TextStyle(color: palette.onSurface),
      labelMedium: TextStyle(color: palette.onSurface),
      labelSmall: TextStyle(color: palette.hint),
    );
  }
}