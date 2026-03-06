import 'dart:async';
import 'package:drift/drift.dart';

import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';
import 'package:uangku/features/sync/repository/sync_repository.dart';

/// Drift (SQLite) implementation of [WalletRepository].
///
/// This is the production adapter — it performs real database I/O.
/// For tests, use a mock implementation instead.
class DriftWalletRepository implements WalletRepository {
  final AppDatabase _db;
  final SyncRepository? _syncRepo;

  DriftWalletRepository(this._db, [this._syncRepo]);

  @override
  Stream<List<Wallet>> watchAllWallets() {
    final query = _db.select(_db.wallets)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return query.watch();
  }

  @override
  Future<int> createWallet(WalletsCompanion wallet) async {
    final id = await _db.into(_db.wallets).insert(wallet);
    unawaited(_syncRepo?.syncWallet(id));
    return id;
  }

  @override
  Future<bool> updateWallet(WalletsCompanion wallet) async {
    if (!wallet.id.present) {
      throw ArgumentError('Cannot update a wallet without an id.');
    }
    final rowsAffected = await (_db.update(
      _db.wallets,
    )..where((t) => t.id.equals(wallet.id.value))).write(wallet);

    unawaited(_syncRepo?.syncWallet(wallet.id.value));

    return rowsAffected > 0;
  }

  @override
  Future<bool> deleteWallet(int id) async {
    final rowsAffected = await (_db.delete(
      _db.wallets,
    )..where((t) => t.id.equals(id))).go();

    unawaited(_syncRepo?.deleteWallet(id));

    return rowsAffected > 0;
  }

  @override
  Future<Wallet?> getWalletById(int id) {
    return (_db.select(
      _db.wallets,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}
