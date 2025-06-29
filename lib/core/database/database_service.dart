import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

import 'habit_collection.dart';
import 'completion_collection.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  DatabaseService._();

  Isar? _isar;
  final _logger = Logger();

  Isar get isar {
    if (_isar == null || !_isar!.isOpen) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _isar!;
  }

  Future<void> initialize() async {
    if (_isar != null && _isar!.isOpen) {
      _logger.d('Database already initialized');
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();

      _isar = await Isar.open(
        [
          HabitCollectionSchema,
          CompletionCollectionSchema,
        ],
        directory: dir.path,
        name: 'habit_level_up',
      );

      _logger.i('Database initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize database',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
      _logger.i('Database closed');
    }
  }

  // Development helper - clear all data
  Future<void> clearAll() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
    _logger.w('All database data cleared');
  }
}
