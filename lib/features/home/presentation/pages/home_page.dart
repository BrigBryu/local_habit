import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/level_bar.dart';
import '../widgets/habit_tile.dart';
import '../providers.dart';
import '../../../../screens/add_habit_screen.dart';
import '../../../../screens/level_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(homeHabitsProvider);
    final routeAvailability = ref.watch(routeAvailabilityProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              
              // Level bar at top
              LevelBar(
                onTap: () => _navigateToLevels(context, routeAvailability),
              ),
              
              const SizedBox(height: 24),
              
              // Habits section header
              Row(
                children: [
                  Text(
                    'Today\'s Habits',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${habits.length} total',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Habits list
              Expanded(
                child: habits.isEmpty 
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        return HabitTile(
                          habit: habit,
                          onTap: () => _navigateToViewHabit(context, habit.id),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddHabit(context, routeAvailability),
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to create your first habit',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 120), // Space for FAB
        ],
      ),
    );
  }

  void _navigateToAddHabit(BuildContext context, Map<String, bool> routeAvailability) {
    if (routeAvailability['addHabit'] == true) {
      try {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AddHabitScreen(),
          ),
        );
      } catch (e) {
        _showPlaceholder(context, 'Add Habit (TODO)', 'Feature coming soon');
      }
    } else {
      _showPlaceholder(context, 'Add Habit (TODO)', 'Feature coming soon');
    }
  }

  void _navigateToLevels(BuildContext context, Map<String, bool> routeAvailability) {
    if (routeAvailability['levels'] == true) {
      try {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LevelPage(),
          ),
        );
      } catch (e) {
        _showPlaceholder(context, 'XP Detail (TODO)', 'Feature coming soon');
      }
    } else {
      _showPlaceholder(context, 'XP Detail (TODO)', 'Feature coming soon');
    }
  }

  void _navigateToViewHabit(BuildContext context, String habitId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Habit: $habitId'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: const Center(
            child: Text('Habit details coming soon'),
          ),
        ),
      ),
    );
  }

  void _showPlaceholder(BuildContext context, String title, String message) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Center(
            child: Text(message),
          ),
        ),
      ),
    );
  }
}