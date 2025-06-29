import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:domain/domain.dart';
import 'package:habit_level_up/core/repositories/local_habits_repository.dart';
import 'package:habit_level_up/core/local/local_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('LocalHabitsRepository', () {
    late LocalHabitsRepository repository;
    late LocalDatabase database;

    setUpAll(() {
      // Initialize Flutter test binding
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      // Create fresh database for each test
      database = LocalDatabase();
      repository = LocalHabitsRepository(database: database);
      await repository.initialize();
    });

    tearDown(() async {
      await repository.dispose();
      await database.deleteDatabase();
    });

    test('should add a new habit successfully', () async {
      // Arrange
      final habit = Habit.create(
        name: 'Test Habit',
        description: 'A test habit',
        type: HabitType.basic,
      );

      // Act
      final result = await repository.addHabit(habit);

      // Assert
      expect(result, isNull); // null means success
      
      // Verify habit was added
      final habits = await repository.ownHabits().first;
      expect(habits.length, equals(1));
      expect(habits.first.name, equals('Test Habit'));
      expect(habits.first.type, equals(HabitType.basic));
    });

    test('should update an existing habit', () async {
      // Arrange
      final habit = Habit.create(
        name: 'Original Name',
        description: 'Original description',
        type: HabitType.basic,
      );
      await repository.addHabit(habit);

      final updatedHabit = Habit(
        id: habit.id,
        name: 'Updated Name',
        description: 'Updated description',
        type: HabitType.basic,
        createdAt: habit.createdAt,
        displayOrder: habit.displayOrder,
      );

      // Act
      final result = await repository.updateHabit(updatedHabit);

      // Assert
      expect(result, isNull); // null means success
      
      // Verify habit was updated
      final habits = await repository.ownHabits().first;
      expect(habits.length, equals(1));
      expect(habits.first.name, equals('Updated Name'));
      expect(habits.first.description, equals('Updated description'));
    });

    test('should remove a habit', () async {
      // Arrange
      final habit = Habit.create(
        name: 'Test Habit',
        description: 'A test habit',
        type: HabitType.basic,
      );
      await repository.addHabit(habit);

      // Verify habit exists
      final initialHabits = await repository.ownHabits().first;
      expect(initialHabits.length, equals(1));

      // Act
      final result = await repository.removeHabit(habit.id);

      // Assert
      expect(result, isNull); // null means success
      
      // Verify habit was removed
      final finalHabits = await repository.ownHabits().first;
      expect(finalHabits.length, equals(0));
    });

    test('should complete a habit and update streak', () async {
      // Arrange
      final habit = Habit.create(
        name: 'Test Habit',
        description: 'A test habit',
        type: HabitType.basic,
      );
      await repository.addHabit(habit);

      // Act
      final result = await repository.completeHabit(habit.id, xpAwarded: 10);

      // Assert
      expect(result, isNull); // null means success
      
      // Verify habit was completed and streak updated
      final habits = await repository.ownHabits().first;
      expect(habits.length, equals(1));
      expect(habits.first.currentStreak, equals(1));
      expect(habits.first.dailyCompletionCount, equals(1));
    });

    test('should record failure for avoidance habit', () async {
      // Arrange
      final habit = Habit.create(
        name: 'Avoid Junk Food',
        description: 'Don\'t eat junk food',
        type: HabitType.avoidance,
      );
      await repository.addHabit(habit);

      // Act
      final result = await repository.recordFailure(habit.id);

      // Assert
      expect(result, isNull); // null means success
      
      // Verify failure was recorded
      final habits = await repository.ownHabits().first;
      expect(habits.length, equals(1));
      expect(habits.first.dailyFailureCount, equals(1));
      expect(habits.first.currentStreak, equals(0)); // Streak should be broken
    });

    test('should complete stack child habit', () async {
      // Arrange
      final childHabit = Habit.create(
        name: 'Push-ups',
        description: 'Do push-ups',
        type: HabitType.basic,
      );
      await repository.addHabit(childHabit);

      final stackHabit = Habit.create(
        name: 'Workout Stack',
        description: 'Complete workout sequence',
        type: HabitType.stack,
      );
      // Add stack child reference
      final stackWithChild = Habit(
        id: stackHabit.id,
        name: stackHabit.name,
        description: stackHabit.description,
        type: stackHabit.type,
        stackChildIds: [childHabit.id],
        currentChildIndex: 0,
        createdAt: stackHabit.createdAt,
        displayOrder: stackHabit.displayOrder,
      );
      await repository.addHabit(stackWithChild);

      // Act
      final result = await repository.completeStackChild(stackWithChild.id);

      // Assert
      expect(result, isNull); // null means success
      
      // Verify child habit was completed and stack progressed
      final habits = await repository.ownHabits().first;
      final childHabits = habits.where((h) => h.id == childHabit.id).toList();
      final stackHabits = habits.where((h) => h.id == stackWithChild.id).toList();
      
      expect(childHabits.length, equals(1));
      expect(childHabits.first.currentStreak, equals(1)); // Child completed
      
      expect(stackHabits.length, equals(1));
      expect(stackHabits.first.currentChildIndex, equals(0)); // Reset to 0 after completing all children
    });

    test('should export and import data successfully', () async {
      // Arrange
      final habit1 = Habit.create(
        name: 'Habit 1',
        description: 'First habit',
        type: HabitType.basic,
      );
      final habit2 = Habit.create(
        name: 'Habit 2',
        description: 'Second habit',
        type: HabitType.avoidance,
      );
      
      await repository.addHabit(habit1);
      await repository.addHabit(habit2);
      await repository.completeHabit(habit1.id);

      // Act - Export data
      final exportedData = await repository.exportData();

      // Clear database
      await repository.clearAllData();
      
      // Verify database is empty
      final emptyHabits = await repository.ownHabits().first;
      expect(emptyHabits.length, equals(0));

      // Act - Import data
      final importResult = await repository.importData(exportedData);

      // Assert
      expect(importResult, isNull); // null means success
      
      // Verify data was imported
      final importedHabits = await repository.ownHabits().first;
      expect(importedHabits.length, equals(2));
      
      final importedBasicHabit = importedHabits.firstWhere((h) => h.type == HabitType.basic);
      expect(importedBasicHabit.name, equals('Habit 1'));
      expect(importedBasicHabit.currentStreak, equals(1)); // Should have preserved completion
      
      final importedAvoidanceHabit = importedHabits.firstWhere((h) => h.type == HabitType.avoidance);
      expect(importedAvoidanceHabit.name, equals('Habit 2'));
    });

    test('should handle multiple habit types correctly', () async {
      // Arrange
      final basicHabit = Habit.create(
        name: 'Basic Habit',
        description: 'A basic habit',
        type: HabitType.basic,
      );
      final avoidanceHabit = Habit.create(
        name: 'Avoidance Habit',
        description: 'An avoidance habit',
        type: HabitType.avoidance,
      );
      final intervalHabit = Habit.create(
        name: 'Interval Habit',
        description: 'An interval habit',
        type: HabitType.interval,
        intervalDays: 3,
      );
      final weeklyHabit = Habit.create(
        name: 'Weekly Habit',
        description: 'A weekly habit',
        type: HabitType.weekly,
        weekdayMask: 65, // Binary 1000001 = Sunday and Saturday
      );

      // Act
      await repository.addHabit(basicHabit);
      await repository.addHabit(avoidanceHabit);
      await repository.addHabit(intervalHabit);
      await repository.addHabit(weeklyHabit);

      // Assert
      final habits = await repository.ownHabits().first;
      expect(habits.length, equals(4));
      
      expect(habits.any((h) => h.type == HabitType.basic), isTrue);
      expect(habits.any((h) => h.type == HabitType.avoidance), isTrue);
      expect(habits.any((h) => h.type == HabitType.interval), isTrue);
      expect(habits.any((h) => h.type == HabitType.weekly), isTrue);
      
      final intervalHabitFromDB = habits.firstWhere((h) => h.type == HabitType.interval);
      expect(intervalHabitFromDB.intervalDays, equals(3));
      
      final weeklyHabitFromDB = habits.firstWhere((h) => h.type == HabitType.weekly);
      expect(weeklyHabitFromDB.weekdayMask, equals(65));
    });
  });
}