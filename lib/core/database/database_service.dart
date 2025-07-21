import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

import '../models/habit.dart';

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

  /// Initialize database - safe to call multiple times
  static Future<Isar> initialize() async {
    final service = DatabaseService.instance;
    if (service._isar != null && service._isar!.isOpen) {
      service._logger.d('Database already initialized');
      return service._isar!;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();

      service._isar = await Isar.open(
        [
          HabitSchema,
        ],
        directory: dir.path,
        name: 'local_habit',
      );

      service._logger.i('Database initialized successfully');
      return service._isar!;
    } catch (e, stackTrace) {
      service._logger.e('Failed to initialize database',
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

  /// Test helper - set a test database instance
  void setTestIsar(Isar testIsar) {
    _isar = testIsar;
  }
}
