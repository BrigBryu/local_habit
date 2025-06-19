import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../core/repositories/habits_repository.dart';
import '../core/repositories/simple_memory_repository.dart';
// import '../core/repositories/remote_habits_repository.dart';
import '../core/auth/username_auth_service.dart';
import '../screens/partner_settings_screen.dart';

final _logger = Logger();

/// Provider that creates and manages the repository with user context
final repositoryProvider = FutureProvider<HabitsRepository>((ref) async {
  _logger.i('Using SimpleMemoryRepository for testing Stack fixes');
  final repository = SimpleMemoryRepository();

  // Initialize with async dependencies
  await repository.initialize();

  // Set the current user ID from username auth service
  try {
    final currentUserId = UsernameAuthService.instance.getCurrentUserId();
    if (currentUserId != null) {
      await repository.setCurrentUserId(currentUserId);
      _logger.i('Repository initialized for user: $currentUserId');
    } else {
      _logger
          .w('No authenticated user - repository initialized without user ID');
    }
  } catch (e) {
    _logger.w('Could not set user ID in repository: $e');
  }

  _logger.i('SimpleMemoryRepository initialized successfully');
  return repository;
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

/// Provider that watches for username changes and updates repository
final userAwareRepositoryProvider =
    Provider<AsyncValue<HabitsRepository>>((ref) {
  // Watch for username changes
  ref.watch(currentUsernameProvider);

  // Return the repository which will reinitialize when username changes
  return ref.watch(repositoryProvider);
});

/// Provider for checking if we're using remote or local repository
final isUsingRemoteRepositoryProvider = Provider<bool>((ref) {
  // Using pure SimpleMemoryRepository for testing Stack fixes
  return false;
});
