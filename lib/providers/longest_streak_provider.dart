import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/repository_init_provider.dart';

/// Provider that calculates the longest streak - simplified for offline mode
final longestStreakProvider = StreamProvider.autoDispose<int>((ref) async* {
  // Mock longest streak calculation
  // In a real app, this would analyze habit completion data
  yield 12; // Mock streak length
});

/// Calculates current streak for a habit
int _calculateCurrentStreak(dynamic habit) {
  // This is a placeholder implementation
  // In a real app, this would analyze the habit's completion history
  // and calculate the current consecutive completion streak
  
  // For now, return a mock value
  if (habit.toString().contains('Exercise')) return 7;
  if (habit.toString().contains('Reading')) return 12;
  if (habit.toString().contains('Water')) return 5;
  
  return 3; // Default mock streak
}

/// Provider for checking if longest streak unlocks new themes
final streakUnlocksProvider = Provider.autoDispose<List<String>>((ref) {
  final longestStreakAsync = ref.watch(longestStreakProvider);
  
  return longestStreakAsync.when(
    data: (streak) => _getUnlockedThemes(streak),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Gets list of theme IDs unlocked by streak length
List<String> _getUnlockedThemes(int streak) {
  final unlocked = <String>[];
  
  if (streak >= 3) unlocked.add('theme_bronze');
  if (streak >= 7) unlocked.add('theme_silver');
  if (streak >= 14) unlocked.add('theme_gold');
  if (streak >= 30) unlocked.add('theme_platinum');
  if (streak >= 60) unlocked.add('theme_diamond');
  
  return unlocked;
}