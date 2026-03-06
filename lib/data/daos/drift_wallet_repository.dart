import 'dart:async';
import 'package:drift/drift.dart';

import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/features/sync/repository/sync_repository.dart';

/// Drift (SQLite) implementation of [WalletRepository].
///
/// This is the production adapter — it performs real database I/O.
/// For tests, use a mock implementation instead.
class DriftWalletRepository implements WalletRepository {
  final AppDatabase _db;
  final SyncRepository? _syncRepo;
  final MonitoringService _monitoring;

  DriftWalletRepository(this._db, this._monitoring, [this._syncRepo]);

  @override
  Stream<List<Wallet>> watchAllWallets() {
    const operation = 'watchAllWallets';
    final startTime = DateTime.now();
    _monitoring.logInfo('START: $operation');

    final query = _db.select(_db.wallets)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);

    return query
        .watch()
        .map((rows) {
          final successTime = DateTime.now();
          final durationMs = successTime.difference(startTime).inMilliseconds;
          _monitoring.logInfo('SUCCESS: $operation', {
            'rows': rows.length,
            'durationMs': durationMs,
          });
          return rows;
        })
        .handleError((err, stack) {
          _monitoring.logError('FAILURE: $operation', err, stack);
          throw err;
        });
  }

  @override
  Future<int> createWallet(WalletsCompanion wallet) async {
    final startTime = DateTime.now();
    try {
      _monitoring.logInfo('Creating wallet...');
      final id = await _db.into(_db.wallets).insert(wallet);
      final durationMs = DateTime.now().difference(startTime).inMilliseconds;
      _monitoring.logInfo('Successfully created wallet', {
        'id': id,
        'durationMs': durationMs,
      });

      // Sync to cloud
      unawaited(_syncRepo?.syncWallet(id));

      return id;
    } catch (e, st) {
      _monitoring.logError('Failed to create wallet', e, st);
      rethrow;
    }
  }

  @override
  Future<bool> updateWallet(WalletsCompanion wallet) async {
    if (!wallet.id.present) {
      throw ArgumentError('Cannot update a wallet without an id.');
    }
    final startTime = DateTime.now();
    try {
      _monitoring.logInfo('Updating wallet', {'id': wallet.id.value});
      final rowsAffected = await (_db.update(
        _db.wallets,
      )..where((t) => t.id.equals(wallet.id.value))).write(wallet);
      final durationMs = DateTime.now().difference(startTime).inMilliseconds;
      _monitoring.logInfo('Successfully updated wallet', {
        'id': wallet.id.value,
        'durationMs': durationMs,
      });

      // Sync to cloud
      unawaited(_syncRepo?.syncWallet(wallet.id.value));

      return rowsAffected > 0;
    } catch (e, st) {
      _monitoring.logError('Failed to update wallet', e, st, {
        'id': wallet.id.value,
      });
      rethrow;
    }
  }

  @override
  Future<bool> deleteWallet(int id) async {
    final startTime = DateTime.now();
    try {
      _monitoring.logInfo('Deleting wallet', {'id': id});
      final rowsAffected = await (_db.delete(
        _db.wallets,
      )..where((t) => t.id.equals(id))).go();
      final durationMs = DateTime.now().difference(startTime).inMilliseconds;
      _monitoring.logInfo('Successfully deleted wallet', {
        'id': id,
        'rowsAffected': rowsAffected,
        'durationMs': durationMs,
      });

      // Sync to cloud
      unawaited(_syncRepo?.deleteWallet(id));

      return rowsAffected > 0;
    } catch (e, st) {
      _monitoring.logError('Failed to delete wallet', e, st, {'id': id});
      rethrow;
    }
  }

  @override
  Future<Wallet?> getWalletById(int id) async {
    const operation = 'getWalletById';
    final startTime = DateTime.now();
    _monitoring.logInfo('START: $operation', {'id': id});

    try {
      final result = await (_db.select(
        _db.wallets,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

      final durationMs = DateTime.now().difference(startTime).inMilliseconds;
      _monitoring.logInfo('SUCCESS: $operation', {
        'id': id,
        'found': result != null,
        'durationMs': durationMs,
      });

      return result;
    } catch (e, st) {
      _monitoring.logError('FAILURE: $operation', e, st, {'id': id});
      rethrow;
    }
  }
}
