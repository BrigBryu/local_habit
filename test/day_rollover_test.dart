import 'package:flutter_test/flutter_test.dart';
import 'package:habit_level_up/core/services/time_service.dart';
import 'package:habit_level_up/core/services/habit_service.dart';
import 'package:habit_level_up/core/models/habit.dart';
import 'package:habit_level_up/core/database/database_service.dart';

void main() {
  group('Day Rollover Tests', () {
    late TimeService timeService;
    late HabitService habitService;
    late DatabaseService db;

    setUpAll(() async {
      // Initialize services
      db = DatabaseService.instance;
      await db.initialize();
      timeService = TimeService.instance;
      await timeService.initialize();
      habitService = HabitService();
    });

    tearDownAll(() async {
      await db.close();
    });

    testWidgets('Habits completed yesterday should show as uncompleted today', (tester) async {
      // Clear any existing habits
      await db.isar.writeTxn(() async {
        await db.isar.habits.clear();
      });

      // Reset time service to real time
      await timeService.resetToRealDate();

      // Create a test habit
      await habitService.addHabit('Test Habit', HabitType.basic);
      
      // Load habits and get the first one
      final habits = await habitService.loadHabits();
      expect(habits, isNotEmpty);
      final habit = habits.first;

      // Complete the habit today
      await habitService.toggleComplete(habit);
      
      // Verify it's completed today
      final updatedHabit = await habitService.getHabitById(habit.id);
      expect(updatedHabit!.isCompletedToday, isTrue);
      expect(updatedHabit.streak, equals(1));

      // Advance time by 1 day (simulate day rollover)
      await timeService.addDays(1);

      // Refresh habits to trigger streak checking
      await habitService.refreshHabits();

      // Verify the habit is no longer completed today but streak is maintained
      final rolledOverHabit = await habitService.getHabitById(habit.id);
      expect(rolledOverHabit!.isCompletedToday, isFalse, 
        reason: 'Habit should not be completed today after day rollover');
      expect(rolledOverHabit.streak, equals(1), 
        reason: 'Streak should be maintained for 1 day');

      // Advance time by another day without completing
      await timeService.addDays(1);
      await habitService.refreshHabits();

      // Now the streak should be lost
      final lostStreakHabit = await habitService.getHabitById(habit.id);
      expect(lostStreakHabit!.isCompletedToday, isFalse);
      expect(lostStreakHabit.streak, equals(0), 
        reason: 'Streak should be lost after missing a day');
    });

    testWidgets('Multiple habits should rollover correctly', (tester) async {
      // Clear any existing habits
      await db.isar.writeTxn(() async {
        await db.isar.habits.clear();
      });

      // Reset time service
      await timeService.resetToRealDate();

      // Create multiple test habits
      await habitService.addHabit('Habit 1', HabitType.basic);
      await habitService.addHabit('Habit 2', HabitType.basic);
      
      final habits = await habitService.loadHabits();
      expect(habits.length, equals(2));

      // Complete both habits
      await habitService.toggleComplete(habits[0]);
      await habitService.toggleComplete(habits[1]);

      // Verify both are completed
      final completedHabits = await habitService.loadHabits();
      expect(completedHabits[0].isCompletedToday, isTrue);
      expect(completedHabits[1].isCompletedToday, isTrue);
      expect(completedHabits[0].streak, equals(1));
      expect(completedHabits[1].streak, equals(1));

      // Advance time by 1 day
      await timeService.addDays(1);
      await habitService.refreshHabits();

      // Verify both are uncompleted but streaks maintained
      final rolledOverHabits = await habitService.loadHabits();
      for (final habit in rolledOverHabits) {
        expect(habit.isCompletedToday, isFalse, 
          reason: 'All habits should be uncompleted after rollover');
        expect(habit.streak, equals(1), 
          reason: 'All streaks should be maintained for 1 day');
      }
    });
  });
}