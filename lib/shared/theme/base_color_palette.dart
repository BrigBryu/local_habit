import 'package:flutter/material.dart';
import 'theme_contracts.dart';

/// Base implementation of color palette with common functionality
class BaseColorPalette implements IColorPalette {
  @override
  final String name;
  
  @override
  final Color primary;
  @override
  final Color primaryVariant;
  @override
  final Color secondary;
  @override
  final Color accent;
  
  @override
  final Color surface;
  @override
  final Color background;
  @override
  final Color error;
  @override
  final Color success;
  
  @override
  final Color onPrimary;
  @override
  final Color onSecondary;
  @override
  final Color onSurface;
  @override
  final Color onError;
  
  @override
  final Color divider;
  @override
  final Color shadow;
  @override
  final Color disabled;
  @override
  final Color hint;

  const BaseColorPalette({
    required this.name,
    required this.primary,
    required this.primaryVariant,
    required this.secondary,
    required this.accent,
    required this.surface,
    required this.background,
    required this.error,
    required this.success,
    required this.onPrimary,
    required this.onSecondary,
    required this.onSurface,
    required this.onError,
    required this.divider,
    required this.shadow,
    required this.disabled,
    required this.hint,
  });

  /// Factory constructor from map (for serialization)
  factory BaseColorPalette.fromMap(Map<String, dynamic> map) {
    return BaseColorPalette(
      name: map['name'] as String,
      primary: Color(map['primary'] as int),
      primaryVariant: Color(map['primaryVariant'] as int),
      secondary: Color(map['secondary'] as int),
      accent: Color(map['accent'] as int),
      surface: Color(map['surface'] as int),
      background: Color(map['background'] as int),
      error: Color(map['error'] as int),
      success: Color(map['success'] as int),
      onPrimary: Color(map['onPrimary'] as int),
      onSecondary: Color(map['onSecondary'] as int),
      onSurface: Color(map['onSurface'] as int),
      onError: Color(map['onError'] as int),
      divider: Color(map['divider'] as int),
      shadow: Color(map['shadow'] as int),
      disabled: Color(map['disabled'] as int),
      hint: Color(map['hint'] as int),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'primary': primary.value,
      'primaryVariant': primaryVariant.value,
      'secondary': secondary.value,
      'accent': accent.value,
      'surface': surface.value,
      'background': background.value,
      'error': error.value,
      'success': success.value,
      'onPrimary': onPrimary.value,
      'onSecondary': onSecondary.value,
      'onSurface': onSurface.value,
      'onError': onError.value,
      'divider': divider.value,
      'shadow': shadow.value,
      'disabled': disabled.value,
      'hint': hint.value,
    };
  }

  /// Create a copy with modified colors
  BaseColorPalette copyWith({
    String? name,
    Color? primary,
    Color? primaryVariant,
    Color? secondary,
    Color? accent,
    Color? surface,
    Color? background,
    Color? error,
    Color? success,
    Color? onPrimary,
    Color? onSecondary,
    Color? onSurface,
    Color? onError,
    Color? divider,
    Color? shadow,
    Color? disabled,
    Color? hint,
  }) {
    return BaseColorPalette(
      name: name ?? this.name,
      primary: primary ?? this.primary,
      primaryVariant: primaryVariant ?? this.primaryVariant,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      surface: surface ?? this.surface,
      background: background ?? this.background,
      error: error ?? this.error,
      success: success ?? this.success,
      onPrimary: onPrimary ?? this.onPrimary,
      onSecondary: onSecondary ?? this.onSecondary,
      onSurface: onSurface ?? this.onSurface,
      onError: onError ?? this.onError,
      divider: divider ?? this.divider,
      shadow: shadow ?? this.shadow,
      disabled: disabled ?? this.disabled,
      hint: hint ?? this.hint,
    );
  }

  /// Calculate brightness based on background color
  Brightness get brightness {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Brightness.light : Brightness.dark;
  }

  /// Check if palette is dark themed
  bool get isDark => brightness == Brightness.dark;

  /// Check if palette is light themed
  bool get isLight => brightness == Brightness.light;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseColorPalette &&
        other.name == name &&
        other.primary == primary &&
        other.primaryVariant == primaryVariant &&
        other.secondary == secondary &&
        other.accent == accent &&
        other.surface == surface &&
        other.background == background &&
        other.error == error &&
        other.success == success &&
        other.onPrimary == onPrimary &&
        other.onSecondary == onSecondary &&
        other.onSurface == onSurface &&
        other.onError == onError &&
        other.divider == divider &&
        other.shadow == shadow &&
        other.disabled == disabled &&
        other.hint == hint;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      primary,
      primaryVariant,
      secondary,
      accent,
      surface,
      background,
      error,
      success,
      onPrimary,
      onSecondary,
      onSurface,
      onError,
      divider,
      shadow,
      disabled,
      hint,
    );
  }

  @override
  String toString() => 'BaseColorPalette(name: $name, brightness: $brightness)';
}