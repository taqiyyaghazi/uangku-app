import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/features/sync/repository/sync_repository.dart';

/// Repository for managing application settings stored in the database.
class SettingsRepository {
  const SettingsRepository(this._db, this._monitoring, [this._syncRepo]);

  final AppDatabase _db;
  final MonitoringService _monitoring;
  final SyncRepository? _syncRepo;

  /// Retrieves a double value by [key], watching for changes.
  Stream<double?> watchDouble(String key) {
    return (_db.select(_db.appSettings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value)
        .handleError((error, stackTrace) {
          _monitoring.logError(
            'Failed to watch setting for key $key',
            error,
            stackTrace,
          );
        });
  }

  /// Sets a double value for [key]. Uses upsert (insert or replace).
  Future<void> setDouble(String key, double value) async {
    try {
      await _db
          .into(_db.appSettings)
          .insertOnConflictUpdate(
            AppSetting(key: key, value: value, updatedAt: DateTime.now()),
          );

      // Trigger cloud sync
      _syncRepo?.syncSetting(key);
    } catch (e, st) {
      _monitoring.logError('Failed to set setting for key $key', e, st);
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
      _monitoring.logError('Failed to get setting for key $key', e, st);
      return null;
    }
  }
}
