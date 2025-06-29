import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../core/repositories/habits_repository.dart';
import '../core/repositories/local_habits_repository.dart';

final _logger = Logger();

/// Provider that creates and manages the local repository
final repositoryProvider = FutureProvider<HabitsRepository>((ref) async {
  _logger.i('Repository provider initializing - Local SQLite mode');
  
  try {
    _logger.i('Initializing LocalHabitsRepository');
    final repository = LocalHabitsRepository();

    // Initialize with local database
    await repository.initialize();

    // Set the current user ID to default local user
    await repository.setCurrentUserId('local_user');
    _logger.i('Local repository initialized for local user');

    _logger.i('LocalHabitsRepository initialized successfully');
    return repository;
  } catch (e) {
    _logger.e('Failed to initialize LocalHabitsRepository: $e');
    throw RepositoryException('Failed to initialize local repository: $e');
  }
});

/// Provider for the currently active repository (cached)
final activeRepositoryProvider = Provider<AsyncValue<HabitsRepository>>((ref) {
  return ref.watch(repositoryProvider);
});

/// Provider that exposes the repository once it's loaded
final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  final repositoryAsync = ref.watch(repositoryProvider);

  return repositoryAsync.when(
    data: (repository) => repository,
    loading: () => throw const RepositoryException('Repository still loading'),
    error: (error, stackTrace) =>
        throw RepositoryException('Repository failed to load: $error'),
  );
});

/// Provider that returns the same repository (no user changes in offline mode)
final userAwareRepositoryProvider =
    Provider<AsyncValue<HabitsRepository>>((ref) {
  // In offline mode, just return the local repository
  return ref.watch(repositoryProvider);
});

/// Provider for checking if we're using remote or local repository
final isUsingRemoteRepositoryProvider = Provider<bool>((ref) {
  // Always false in offline mode
  return false;
});
