import 'package:domain/entities/habit.dart';
import 'package:domain/use_cases/complete_bundle_use_case.dart';
import '../repositories/local_habits_repository.dart';
import 'bundle_service.dart';

/// Service for habit operations, especially bundle-related functionality
class HabitService {
  static final HabitService _instance = HabitService._internal();
  factory HabitService() => _instance;
  HabitService._internal();

  final BundleService bundleService = BundleService();
  LocalHabitsRepository? _repository;

  void setRepository(LocalHabitsRepository repository) {
    _repository = repository;
  }

  /// Get all habits from the repository
  List<Habit> getAllHabits() {
    return _repository?.getAllHabits() ?? [];
  }

  /// Get a habit by ID
  Habit? getHabitById(String habitId) {
    final habits = getAllHabits();
    try {
      return habits.firstWhere((h) => h.id == habitId);
    } catch (e) {
      return null;
    }
  }

  /// Create a new bundle habit
  Future<void> createBundle({
    required String name,
    required String description,
    required List<String> childHabitIds,
  }) async {
    if (_repository == null) {
      throw StateError('Repository not initialized');
    }

    final allHabits = getAllHabits();
    
    // Create bundle using bundle service
    final bundle = bundleService.createBundle(
      name: name,
      description: description,
      childIds: childHabitIds,
      allHabits: allHabits,
    );

    // Add bundle to repository
    await _repository!.addHabit(bundle);

    // Update child habits to reference the bundle
    final updatedChildren = bundleService.assignChildrenToBundle(
      bundle.id,
      childHabitIds,
      allHabits,
    );

    // Update each child habit in the repository
    for (final updatedChild in updatedChildren) {
      await _repository!.updateHabit(updatedChild);
    }
  }

  /// Complete a bundle and all its incomplete children
  Future<void> completeBundle(String bundleId) async {
    if (_repository == null) {
      throw StateError('Repository not initialized');
    }

    final allHabits = getAllHabits();
    final bundle = getHabitById(bundleId);
    
    if (bundle == null || bundle.type != HabitType.bundle) {
      throw ArgumentError('Bundle not found or not a bundle type');
    }

    // Get incomplete children and complete them
    final result = bundleService.completeBundle(bundle, allHabits);

    // Update each completed habit in the repository
    for (final completedHabit in result.completedHabits) {
      await _repository!.updateHabit(completedHabit);
    }

    // Mark the bundle as completed
    final completedBundle = bundle.complete();
    await _repository!.updateHabit(completedBundle);
  }

  /// Get habits available for bundling
  List<Habit> getAvailableHabitsForBundling() {
    final allHabits = getAllHabits();
    return bundleService.getAvailableHabitsForBundle(allHabits);
  }

  /// Get bundle progress
  BundleProgress getBundleProgress(String bundleId) {
    final allHabits = getAllHabits();
    final bundle = getHabitById(bundleId);
    
    if (bundle == null) {
      return BundleProgress(completed: 0, total: 0);
    }

    return bundleService.getBundleProgress(bundle, allHabits);
  }

  /// Get bundles with their children for display
  List<BundleHabitWithChildren> getBundlesWithChildrenForToday() {
    final allHabits = getAllHabits();
    final bundles = allHabits.where((h) => h.type == HabitType.bundle).toList();
    
    return bundles.map((bundle) {
      final children = bundleService.getChildHabits(bundle, allHabits);
      final progress = bundleService.getBundleProgress(bundle, allHabits);
      
      return BundleHabitWithChildren(
        bundleHabit: bundle,
        childHabits: children,
        progress: progress,
      );
    }).toList();
  }

  /// Check if all children in a bundle are completed today
  bool areBundleChildrenCompleted(String bundleId) {
    final allHabits = getAllHabits();
    final bundle = getHabitById(bundleId);
    
    if (bundle == null) return false;
    
    return bundleService.isBundleCompleted(bundle, allHabits);
  }
}

