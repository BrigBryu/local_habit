import 'package:flutter/material.dart';
import '../services/level_service.dart';

class LevelPage extends StatelessWidget {
  const LevelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final levelService = LevelService();
    final stats = levelService.getDetailedStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Level & Progress'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Level Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Level ${stats['currentLevel']}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${stats['currentXP']} Total XP',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress to Level ${stats['currentLevel'] + 1}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${stats['xpUntilNextLevel']} XP to go',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: stats['progressToNextLevel'].toDouble(),
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${stats['currentXP'] - stats['xpForCurrentLevel']}/${stats['xpForNextLevel'] - stats['xpForCurrentLevel']} XP',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // XP Sources
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎯 XP Sources',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildXPSource('Complete a habit', '+1 XP'),
                    _buildXPSource('3-day streak', '+2 bonus XP'),
                    _buildXPSource('7-day streak', '+5 bonus XP'),
                    _buildXPSource('30-day streak', '+15 bonus XP'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Coming Soon
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.construction, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Coming Soon',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('• Achievements & badges'),
                    const Text('• Level rewards & unlocks'),
                    const Text('• Habit themes'),
                    const Text('• Weekly challenges'),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Debug section (temporary)
            if (stats['currentLevel'] < 5) // Only show for low levels
              OutlinedButton(
                onPressed: () {
                  levelService.addXP(10, source: 'debug');
                  // Refresh the page
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LevelPage()),
                  );
                },
                child: const Text('🧪 Add 10 XP (Debug)'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildXPSource(String action, String reward) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(action),
          Text(
            reward,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}