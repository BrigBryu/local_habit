import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Basic habit form providers
final basicHabitFormKeyProvider =
    Provider.autoDispose<GlobalKey<FormState>>((_) => GlobalKey<FormState>());

final basicHabitNameControllerProvider =
    Provider.autoDispose<TextEditingController>((_) => TextEditingController());

final basicHabitDescriptionControllerProvider =
    Provider.autoDispose<TextEditingController>((_) => TextEditingController());

// TODO: Add more basic habit specific providers as needed
