import 'dart:developer' as developer;

import 'package:uangku/data/database.dart';

/// Repository for managing application settings stored in the database.
class SettingsRepository {
  const SettingsRepository(this._db);

  final AppDatabase _db;

  /// Retrieves a double value by [key], watching for changes.
  Stream<double?> watchDouble(String key) {
    return (_db.select(_db.appSettings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value)
        .handleError((error, stackTrace) {
          developer.log(
            'Failed to watch setting for key $key',
            name: 'SettingsRepository',
            error: error,
            stackTrace: stackTrace,
          );
          // Return null on error, stream continues
        });
  }

  /// Sets a double value for [key]. Uses upsert (insert or replace).
  Future<void> setDouble(String key, double value) async {
    try {
      await _db
          .into(_db.appSettings)
          .insertOnConflictUpdate(AppSetting(key: key, value: value));
    } catch (e, st) {
      developer.log(
        'Failed to set setting for key $key',
        name: 'SettingsRepository',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Retrieves a double value by [key] once.
  Future<double?> getDouble(String key) async {
    try {
      final row = await (_db.select(
        _db.appSettings,
      )..where((t) => t.key.equals(key))).getSingleOrNull();
      return row?.value;
    } catch (e, st) {
      developer.log(
        'Failed to get setting for key $key',
        name: 'SettingsRepository',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
