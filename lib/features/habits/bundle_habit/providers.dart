import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Bundle habit form providers
final bundleHabitFormKeyProvider = 
    Provider.autoDispose<GlobalKey<FormState>>((_) => GlobalKey<FormState>());

final bundleHabitNameControllerProvider = 
    Provider.autoDispose<TextEditingController>((_) => TextEditingController());

final bundleHabitDescriptionControllerProvider = 
    Provider.autoDispose<TextEditingController>((_) => TextEditingController());

// Bundle-specific providers
final selectedHabitsForBundleProvider = 
    StateProvider.autoDispose<List<String>>((_) => []);

/// Provider to manage expansion state for individual bundles
/// Keyed by bundle ID to maintain state across rebuilds
final bundleExpandedProvider = StateProvider.family<bool, String>((ref, bundleId) {
  return false; // Default to collapsed
});