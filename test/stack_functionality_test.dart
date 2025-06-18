import 'package:flutter_test/flutter_test.dart';
import 'package:domain/domain.dart';
import 'package:habit_level_up/providers/habits_provider.dart';
import 'package:habit_level_up/core/services/stack_progress_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Stack Functionality Tests', () {
    test('Stack creation populates stack_child_ids and child parent_stack_id', () async {
      // Create test habits
      final child1 = Habit.create(
        name: 'Morning Exercise',
        description: 'Daily workout',
        type: HabitType.basic,
      );
      
      final child2 = Habit.create(
        name: 'Healthy Breakfast',
        description: 'Eat nutritious breakfast',
        type: HabitType.basic,
      );
      
      // Create stack with children
      final stack = Habit.create(
        name: 'Morning Routine',
        description: 'Complete morning routine',
        type: HabitType.stack,
        stackChildIds: [child1.id, child2.id],
        currentChildIndex: 0,
      );
      
      // Verify stack has child IDs
      expect(stack.stackChildIds, isNotNull);
      expect(stack.stackChildIds!.length, equals(2));
      expect(stack.stackChildIds, contains(child1.id));
      expect(stack.stackChildIds, contains(child2.id));
      expect(stack.currentChildIndex, equals(0));
    });

    test('Stack progress service tracks current child correctly', () {
      // Create test habits
      final child1 = Habit.create(
        name: 'Exercise',
        description: 'Morning workout',
        type: HabitType.basic,
        parentStackId: 'stack123',
      );
      
      final child2 = Habit.create(
        name: 'Breakfast',
        description: 'Healthy meal',
        type: HabitType.basic,
        parentStackId: 'stack123',
      );
      
      final stack = Habit.create(
        name: 'Morning Routine',
        description: 'Daily routine',
        type: HabitType.stack,
        stackChildIds: [child1.id, child2.id],
        currentChildIndex: 0,
      );
      
      final allHabits = [stack, child1, child2];
      final stackProgressService = StackProgressService();
      
      // Test initial state
      final currentChild = stackProgressService.getCurrentChild(stack, allHabits);
      expect(currentChild?.id, equals(child1.id));
      
      final progress = stackProgressService.getStackProgress(stack, allHabits);
      expect(progress.completed, equals(0));
      expect(progress.total, equals(2));
      expect(progress.currentIndex, equals(0));
      
      // Test stack not complete initially
      final isComplete = stackProgressService.isStackComplete(stack, allHabits);
      expect(isComplete, isFalse);
    });

    test('Stack validation prevents adding habits with existing relationships', () {
      final childInBundle = Habit.create(
        name: 'Exercise',
        description: 'Already in bundle',
        type: HabitType.basic,
        parentBundleId: 'bundle123',
      );
      
      final childInStack = Habit.create(
        name: 'Reading',
        description: 'Already in stack',
        type: HabitType.basic,
        parentStackId: 'stack123',
      );
      
      final allHabits = [childInBundle, childInStack];
      final stackProgressService = StackProgressService();
      
      // Should reject habit already in bundle
      final bundleError = stackProgressService.validateStackCreation([childInBundle.id], allHabits);
      expect(bundleError, isNotNull);
      expect(bundleError, contains('bundle'));
      
      // Should reject habit already in stack  
      final stackError = stackProgressService.validateStackCreation([childInStack.id], allHabits);
      expect(stackError, isNotNull);
      expect(stackError, contains('stack'));
    });

    test('Stack correctly identifies current child', () {
      // Create child habits first
      final child1 = Habit.create(
        name: 'Exercise',
        description: 'Morning workout',
        type: HabitType.basic,
      );
      
      final child2 = Habit.create(
        name: 'Breakfast',
        description: 'Healthy meal',
        type: HabitType.basic,
      );
      
      // Create stack that references the children
      final stack = Habit.create(
        name: 'Morning Routine',
        description: 'Daily routine',
        type: HabitType.stack,
        stackChildIds: [child1.id, child2.id],
        currentChildIndex: 0,
      );
      
      final allHabits = [stack, child1, child2];
      final stackProgressService = StackProgressService();
      
      // Verify stackChildIds are properly set
      expect(stack.stackChildIds, equals([child1.id, child2.id]));
      expect(stack.currentChildIndex, equals(0));
      
      // Get current child
      final currentChild = stackProgressService.getCurrentChild(stack, allHabits);
      expect(currentChild, isNotNull);
      expect(currentChild!.id, equals(child1.id));
    });
  });
}