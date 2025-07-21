import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../providers/habits_provider.dart';

class StreaksScreen extends ConsumerWidget {
  const StreaksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Temp text
            Text(
              'temp',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: colors.draculaForeground,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Highest Streak display
            _buildHighestStreakDisplay(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHighestStreakDisplay(WidgetRef ref) {
    final colors = ref.watchColors;
    final habitsAsync = ref.watch(habitListProvider);
    
    return habitsAsync.when(
      data: (habits) {
        final maxStreak = habits.isEmpty ? 0 : habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);
        return _buildStreakCard(colors, maxStreak);
      },
      loading: () => _buildStreakCard(colors, 0),
      error: (_, __) => _buildStreakCard(colors, 0),
    );
  }
  
  Widget _buildStreakCard(colors, int streak) {
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            colors.draculaPink.withOpacity(0.2),
            colors.draculaPurple.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.draculaPink.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Highest Streak',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.draculaForeground,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$streak days',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: colors.draculaPink,
            ),
          ),
        ],
      ),
    );
  }
}
