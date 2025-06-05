import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habits_provider.dart';

class DailyHabitsPage extends ConsumerWidget {
  const DailyHabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Habits'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: habits.isEmpty
          ? const Center(
              child: Text(
                'No habits yet!\nTap the + button to add your first habit.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return ListTile(
                  title: Text(habit),
                  trailing: const Icon(Icons.check_box_outline_blank),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add habit functionality to be implemented in Iteration 1
        },
        tooltip: 'Add Habit',
        child: const Icon(Icons.add),
      ),
    );
  }
}