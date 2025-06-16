import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

import 'sync_queue.dart';

/// Separate database service for sync operations to avoid circular dependencies
class SyncDatabase {
  static SyncDatabase? _instance;
  static SyncDatabase get instance => _instance ??= SyncDatabase._();

  SyncDatabase._();

  Isar? _isar;
  final _logger = Logger();

  Isar get isar {
    if (_isar == null || !_isar!.isOpen) {
      throw Exception(
          'Sync database not initialized. Call initialize() first.');
    }
    return _isar!;
  }

  Future<void> initialize() async {
    if (_isar != null && _isar!.isOpen) {
      _logger.d('Sync database already initialized');
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();

      _isar = await Isar.open(
        [SyncOpSchema],
        directory: dir.path,
        name: 'habit_sync',
      );

      _logger.i('Sync database initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize sync database',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
      _logger.i('Sync database closed');
    }
  }
}
