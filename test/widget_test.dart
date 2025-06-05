import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_level_up/main.dart';

void main() {
  testWidgets('Daily Habits page loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HabitLevelUpApp()));

    expect(find.text('Daily Habits'), findsOneWidget);
    expect(find.text('No habits yet!\nTap the + button to add your first habit.'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}