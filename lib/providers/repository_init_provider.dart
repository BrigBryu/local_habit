import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../core/repositories/habits_repository.dart';
import '../core/repositories/local_habits_repository.dart';
import '../core/repositories/remote_habits_repository.dart';
import '../core/network/supabase_client.dart';
import '../core/auth/auth_service.dart';
import '../core/realtime/realtime_service.dart';

final _logger = Logger();

/// Provider that determines which repository to use based on online status and authentication
final repositoryProvider = FutureProvider<HabitsRepository>((ref) async {
  try {
    // Initialize Supabase first
    await SupabaseClientService.instance.initialize();
    
    // Initialize Auth Service
    await AuthService.init();
    
    // Determine which repository to use
    final isOnline = SupabaseClientService.instance.isOnline;
    final isAuthenticated = AuthService.instance.isAuthenticated;
    
    HabitsRepository repository;
    
    if (isOnline && isAuthenticated) {
      _logger.i('Using RemoteHabitsRepository (online & authenticated)');
      repository = RemoteHabitsRepository();
    } else {
      _logger.i('Using LocalHabitsRepository (offline or not authenticated)');
      repository = LocalHabitsRepository();
    }
    
    // Initialize the selected repository
    await repository.initialize();
    
    // Initialize realtime service for remote repositories
    if (repository is RemoteHabitsRepository) {
      await RealtimeService.instance.initialize();
    }
    
    return repository;
    
  } catch (e, stackTrace) {
    _logger.e('Failed to initialize repository, falling back to local', 
             error: e, stackTrace: stackTrace);
    
    // Fallback to local repository on any error
    final localRepository = LocalHabitsRepository();
    await localRepository.initialize();
    return localRepository;
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
    error: (error, stackTrace) => throw RepositoryException('Repository failed to load: $error'),
  );
});

/// Provider for checking if we're using remote or local repository
final isUsingRemoteRepositoryProvider = Provider<bool>((ref) {
  final repositoryAsync = ref.watch(repositoryProvider);
  
  return repositoryAsync.maybeWhen(
    data: (repository) => repository is RemoteHabitsRepository,
    orElse: () => false,
  );
});