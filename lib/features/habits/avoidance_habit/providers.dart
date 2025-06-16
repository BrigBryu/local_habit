import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Avoidance habit form providers
final avoidanceHabitFormKeyProvider =
    Provider.autoDispose<GlobalKey<FormState>>((_) => GlobalKey<FormState>());

final avoidanceHabitNameControllerProvider =
    Provider.autoDispose<TextEditingController>((_) => TextEditingController());

final avoidanceHabitDescriptionControllerProvider =
    Provider.autoDispose<TextEditingController>((_) => TextEditingController());

// Avoidance-specific providers
final dailyFailureCountProvider = StateProvider.autoDispose<int>((_) => 0);

final avoidanceSuccessProvider = StateProvider.autoDispose<bool>((_) => false);

// TODO: Add more avoidance habit specific providers as needed
