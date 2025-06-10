import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Stack habit form providers
final stackHabitFormKeyProvider = Provider.autoDispose<GlobalKey<FormState>>(
  (_) => GlobalKey<FormState>(),
);

final stackHabitNameProvider = StateProvider.autoDispose<String>((ref) => '');
final stackHabitDescriptionProvider = StateProvider.autoDispose<String>((ref) => '');

// Stack expansion state
final stackExpandedProvider = StateProvider.family<bool, String>((ref, stackId) => false);

// Selected steps for stack creation
final selectedStackStepsProvider = StateProvider.autoDispose<List<String>>((ref) => []);

// Stack reordering state
final stackReorderingProvider = StateProvider.autoDispose<bool>((ref) => false);

// Focus mode for single step display
final stackFocusModeProvider = StateProvider.autoDispose<bool>((ref) => true);

// Current focused stack (for single-step display)
final focusedStackProvider = StateProvider.autoDispose<String?>((ref) => null);

// Animation states for stack completion
final stackCompletionAnimationProvider = StateProvider.family<bool, String>((ref, stackId) => false);