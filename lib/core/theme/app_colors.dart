import 'package:flutter/material.dart';

/// Centralized color definitions for the entire app - Dracula theme
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Dracula palette
  static const Color draculaBackground = Color(0xFF282A36);
  static const Color draculaCurrentLine = Color(0xFF44475A);
  static const Color draculaForeground = Color(0xFFF8F8F2);
  static const Color draculaComment = Color(0xFF6272A4);
  static const Color draculaCyan = Color(0xFF8BE9FD);
  static const Color draculaGreen = Color(0xFF50FA7B);
  static const Color draculaOrange = Color(0xFFFFB86C);
  static const Color draculaPink = Color(0xFFFF79C6);
  static const Color draculaPurple = Color(0xFFBD93F9);
  static const Color draculaRed = Color(0xFFFF5555);
  static const Color draculaYellow = Color(0xFFF1FA8C);

  // Primary colors - Dracula Purple theme
  static const Color primaryPurple = draculaPurple;
  static const Color lightPurple = Color(0xFFD4C5F9);
  static const Color darkPurple = Color(0xFF9580F4);
  static const Color purpleAccent = draculaPink;

  // Action colors - Dracula theme
  static const Color success = draculaGreen;
  static const Color successLight = Color(0xFF7CFBA4);
  static const Color successDark = Color(0xFF2EF94E);

  static const Color warning = draculaYellow;
  static const Color warningLight = Color(0xFFF4FBA9);
  static const Color warningDark = Color(0xFFEDF970);

  static const Color error = draculaRed;
  static const Color errorLight = Color(0xFFFF7A7A);
  static const Color errorDark = Color(0xFFFF3030);

  // Habit type colors - Dracula theme
  static const Color basicHabit = draculaCyan;
  static const Color avoidanceHabit = draculaRed;
  static const Color bundleHabit = draculaPurple;
  static const Color stackHabit = draculaOrange;

  // UI colors - Dracula theme with high contrast
  static const Color backgroundLight = draculaForeground;
  static const Color backgroundDark = draculaBackground;
  static const Color cardBackground = Color(0xFFF5F5F5);
  static const Color cardBackgroundDark = draculaCurrentLine;
  static const Color surfaceBackground = draculaForeground;
  static const Color habitCardBackground = draculaCurrentLine;

  static const Color textPrimary = draculaBackground;
  static const Color textSecondary = draculaComment;
  static const Color textTertiary = Color(0xFF8892B0);
  static const Color textLight = draculaForeground;

  // Border and divider colors - Dracula theme with high contrast
  static const Color borderLight = draculaCurrentLine;
  static const Color borderMedium = draculaComment;
  static const Color borderDark = Color(0xFF4A5568);

  // Interactive states - Dracula theme
  static const Color disabled = draculaComment;
  static const Color disabledBackground = draculaCurrentLine;
  static const Color hover = Color(0xFF5A6374);
  static const Color pressed = Color(0xFF4A5568);

  // Completion states - Dracula theme
  static const Color completed = draculaGreen;
  static const Color completedBackground = Color(0xFFE8FDF0);
  static const Color incomplete = draculaComment;
  static const Color incompleteBackground = Color(0xFFF8F8F2);
}

/// Extension to provide easy access to app colors from BuildContext
extension AppColorsExtension on BuildContext {
  // Access AppColors static properties directly
}

/// Color schemes for different themes
class AppColorSchemes {
  static ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primaryPurple,
    brightness: Brightness.light,
    primary: AppColors.primaryPurple,
    onPrimary: AppColors.textLight,
    secondary: AppColors.lightPurple,
    onSecondary: AppColors.textLight,
    surface: AppColors.cardBackground,
    onSurface: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.textLight,
  );

  static ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primaryPurple,
    brightness: Brightness.dark,
    primary: AppColors.lightPurple,
    onPrimary: AppColors.textPrimary,
    secondary: AppColors.purpleAccent,
    onSecondary: AppColors.textPrimary,
    surface: AppColors.cardBackgroundDark,
    onSurface: AppColors.textLight,
    error: AppColors.errorLight,
    onError: AppColors.textPrimary,
  );
}
