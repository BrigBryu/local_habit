import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../core/repositories/habits_repository.dart';
import '../core/repositories/simple_memory_repository.dart';

final _logger = Logger();

/// Provider for Supabase testing - uses simple memory repository with Supabase sync
final repositoryProvider = FutureProvider<HabitsRepository>((ref) async {
  _logger.i('Using SimpleMemoryRepository with Supabase integration');
  final repository = SimpleMemoryRepository();
  
  // Initialize immediately - no async dependencies
  await repository.initialize();
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
    error: (error, stackTrace) => throw RepositoryException('Repository failed to load: $error'),
  );
});

/// Provider for checking if we're using remote or local repository
final isUsingRemoteRepositoryProvider = Provider<bool>((ref) {
  // Using local Isar database but with Supabase sync capability
  return true;
});