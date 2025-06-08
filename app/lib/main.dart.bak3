import 'package:flutter/material.dart';
import 'package:domain/domain.dart';
import 'core/extensions/habit_icon_extensions.dart';

void main() {
  runApp(const HabitLevelUpApp());
}

class HabitLevelUpApp extends StatelessWidget {
  const HabitLevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Level Up - Layered Architecture Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final HabitUseCases _habitService = HabitUseCases();
  final TimeService _timeService = TimeService();
  final LevelService _levelService = LevelService();

  @override
  Widget build(BuildContext context) {
    final habits = _habitService.getVisibleHabits();
    final level = _levelService.currentLevel;
    final xp = _levelService.currentXP;
    final nextLevelXP = _levelService.xpForNextLevel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Level Up - Layered Architecture'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Success message
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '🎉 Migration Successful!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your app has been successfully migrated to a layered workspace architecture!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Architecture overview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🏗️ New Architecture',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildArchitectureItem('📦 Domain Package', 'Pure Dart business logic'),
                    _buildArchitectureItem('💾 Data Local Package', 'Isar persistence layer'),
                    _buildArchitectureItem('🎨 App Package', 'Flutter UI components'),
                    _buildArchitectureItem('⚙️ Melos Workspace', 'Monorepo management'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Level progress (working!)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '🎮 Working Level System',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Level $level',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$xp / $nextLevelXP XP',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: xp / nextLevelXP,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Working services
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✅ Working Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Current time: ${_timeService.now()}'),
                    Text('Habits count: ${habits.length}'),
                    Text('Date info: ${_habitService.getCurrentDateInfo()}'),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Add basic habit button
            ElevatedButton.icon(
              onPressed: _addBasicHabit,
              icon: const Icon(Icons.add),
              label: const Text('Test: Add Basic Habit'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildArchitectureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              description,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
  
  void _addBasicHabit() async {
    try {
      final habitId = await _habitService.addBasicHabit(
        name: 'Demo Habit ${DateTime.now().millisecondsSinceEpoch}',
        description: 'Created from layered architecture demo',
      );
      
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Successfully created habit: $habitId'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}