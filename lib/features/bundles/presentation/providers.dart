import 'package:flutter/foundation.dart';
import 'package:data_local/repositories/habit_service.dart';
import 'package:domain/entities/habit.dart';
import 'package:domain/use_cases/complete_bundle_use_case.dart';

/// Provider for bundle-related state management
class BundleProvider extends ChangeNotifier {
  final HabitService _habitService;
  
  List<BundleHabitWithChildren> _bundles = [];
  bool _isLoading = false;
  String? _error;

  BundleProvider(this._habitService) {
    _loadBundles();
  }

  // Getters
  List<BundleHabitWithChildren> get bundles => _bundles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all bundles with their children
  Future<void> _loadBundles() async {
    _setLoading(true);
    _setError(null);

    try {
      _bundles = _habitService.getBundlesWithChildrenForToday();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh bundles data
  Future<void> refresh() async {
    await _loadBundles();
  }

  /// Create a new bundle
  Future<bool> createBundle({
    required String name,
    required String description,
    required List<String> childHabitIds,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _habitService.createBundle(
        name: name,
        description: description,
        childHabitIds: childHabitIds,
      );
      
      // Refresh the bundles list
      await _loadBundles();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Complete a bundle and all its incomplete children
  Future<bool> completeBundle(String bundleId) async {
    _setError(null);

    try {
      await _habitService.completeBundle(bundleId);
      
      // Refresh the bundles list
      await _loadBundles();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Get bundle progress for a specific bundle
  BundleProgress getBundleProgress(String bundleId) {
    return _habitService.getBundleProgress(bundleId);
  }

  /// Check if all children in a bundle are completed today
  bool areBundleChildrenCompleted(String bundleId) {
    return _habitService.areBundleChildrenCompleted(bundleId);
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }
}

/// Provider for habits available for bundling
class AvailableHabitsProvider extends ChangeNotifier {
  final HabitService _habitService;
  
  List<Habit> _availableHabits = [];
  bool _isLoading = false;

  AvailableHabitsProvider(this._habitService) {
    _loadAvailableHabits();
  }

  // Getters
  List<Habit> get availableHabits => _availableHabits;
  bool get isLoading => _isLoading;

  /// Load habits available for bundling
  Future<void> _loadAvailableHabits() async {
    _isLoading = true;
    notifyListeners();

    try {
      _availableHabits = _habitService.getAvailableHabitsForBundling();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh available habits
  Future<void> refresh() async {
    await _loadAvailableHabits();
  }
}