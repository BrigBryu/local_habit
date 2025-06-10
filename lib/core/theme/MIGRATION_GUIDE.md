# Flexible Theme System Migration Guide

## Overview

Your flexible theme system preserves your existing Dracula colors while allowing theme variations. All existing code continues to work unchanged.

## Current State ✅

All your components currently use `AppColors` directly:
```dart
color: AppColors.draculaPurple
backgroundColor: AppColors.draculaCurrentLine
```

**This continues to work perfectly!** No changes needed.

## Migration Options

### Option 1: Keep Using AppColors (Recommended for most components)
```dart
// This still works and will always show your original Dracula colors
Container(
  color: AppColors.draculaBackground,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.draculaPurple),
  ),
)
```

### Option 2: Opt-in to Flexible Theming (For new components or special cases)
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors; // Get theme-aware colors
    
    return Container(
      color: colors.draculaBackground, // Adapts to current theme variant
      child: Text(
        'Hello',
        style: TextStyle(color: colors.draculaPurple),
      ),
    );
  }
}
```

## Theme Variants Available

1. **Dracula (Default)** - Your exact original colors
2. **Dracula Warm** - Slightly warmer tones
3. **Dracula Cool** - Slightly cooler tones  
4. **Dracula Light** - Light version maintaining your aesthetic

## Benefits

- ✅ **Zero Breaking Changes** - All existing code works unchanged
- ✅ **Gradual Migration** - Opt-in component by component
- ✅ **Preserved Design** - Your original colors remain the default
- ✅ **Consistent Aesthetic** - All variants maintain your design language
- ✅ **User Choice** - Users can pick their preferred variant

## When to Migrate Components

**Migrate when:**
- Creating new components
- Component needs theme awareness
- User specifically requests themeable component

**Don't migrate when:**
- Component works fine as-is
- No user benefit to theming
- Time is better spent elsewhere

## Usage Examples

### Basic Usage (Current - keeps working)
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.draculaCurrentLine,
    border: Border.all(color: AppColors.draculaPurple),
  ),
  child: Text(
    'Habit Name',
    style: TextStyle(color: AppColors.draculaForeground),
  ),
)
```

### Theme-Aware Usage (Optional upgrade)
```dart
Consumer(
  builder: (context, ref, child) {
    final colors = ref.watchColors;
    
    return Container(
      decoration: BoxDecoration(
        color: colors.draculaCurrentLine,
        border: Border.all(color: colors.draculaPurple),
      ),
      child: Text(
        'Habit Name',
        style: TextStyle(color: colors.draculaForeground),
      ),
    );
  },
)
```

## Key Principle

**Your existing colors and design language are preserved as the foundation.** Theme variants are subtle variations that maintain your aesthetic, not completely different themes.