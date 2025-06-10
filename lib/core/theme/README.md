# Theme System Documentation

## Overview
This directory contains the centralized theme system for the Habit Level Up app, providing consistent color management and theming capabilities.

## Structure

### `app_colors.dart`
- **AppColors**: Static class containing all color definitions
- **AppColorSchemes**: Light and dark color schemes for Material 3
- **Key Colors**:
  - Primary purple (`#6A4C93`) - Used for checkmark buttons and primary actions
  - Success green (`#10B981`) - Used for completion states
  - Error red (`#EF4444`) - Used for failures and errors
  - Habit type colors for different habit categories

### `app_theme.dart`
- **AppTheme**: Main theme configuration
- **Light and Dark Themes**: Complete theme definitions
- **Component Themes**: Pre-configured styles for buttons, cards, app bars, etc.

### `theme_extensions.dart`
- **HabitColorsExtension**: Colors specific to different habit types
- **CompletionColorsExtension**: Colors for completion states (completed, incomplete, success, error)
- **ThemeColorsExtension**: Helper methods to access theme colors

## Usage

### Accessing Theme Colors
```dart
// Completion colors (for checkmark buttons)
Theme.of(context).completionColors.completed    // Purple for completed state
Theme.of(context).completionColors.success     // Green for success
Theme.of(context).completionColors.incomplete  // Grey for incomplete

// Habit type colors
Theme.of(context).habitColors.basicHabit       // Blue for basic habits
Theme.of(context).habitColors.avoidanceHabit   // Red for avoidance habits
Theme.of(context).habitColors.bundleHabit      // Purple for bundle habits

// Direct access to colors
AppColors.primaryPurple    // Main purple color
AppColors.success         // Success green
AppColors.error          // Error red
```

### Updated Components
The following components now use the centralized theme:

1. **Checkmark Buttons**:
   - `BasicHabitCheckButton` - Uses purple for completed state
   - `HomeHabitCheckButton` - Consistent purple theming
   - `ViewBasicHabitScreen` - Purple completion button

2. **Snackbars**:
   - Success snackbars use theme success color
   - Error snackbars use theme error color

3. **App-wide Theme**:
   - Primary color scheme uses purple
   - Button themes use purple
   - Floating action buttons use purple

## Key Features

### Purple-First Design
- **Checkmark buttons**: Now use purple instead of green for completion
- **Primary actions**: Purple theme throughout the app
- **Consistent branding**: Purple as the main accent color

### Centralized Color Management
- **No hardcoded colors**: All colors come from the theme system
- **Easy maintenance**: Change colors in one place, updates everywhere
- **Dark mode ready**: Built-in support for light and dark themes

### Theme Extensions
- **Type-safe color access**: IntelliSense support for color properties
- **Context-aware**: Automatically uses light/dark variants
- **Extensible**: Easy to add new color categories

## Migration Notes

Files updated to use the new theme system:
- `main.dart` - Updated to use AppTheme
- `daily_habits_page.dart` - Checkmark buttons use purple theme
- `basic_habit_tile.dart` - Home page tiles use purple theme
- `view_basic_habit_screen.dart` - Completion button uses purple theme

## Benefits

1. **Consistency**: All UI elements use the same color palette
2. **Maintainability**: Colors defined in one place
3. **Accessibility**: Proper contrast ratios and color combinations
4. **Branding**: Purple theme creates cohesive visual identity
5. **Future-proof**: Easy to add new colors or change existing ones