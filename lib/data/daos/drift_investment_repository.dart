import 'dart:async';
import 'package:drift/drift.dart';

import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/investment_repository.dart';
import 'package:uangku/features/sync/repository/sync_repository.dart';

/// Drift (SQLite) implementation of [InvestmentRepository].
///
/// This is the production adapter — it performs real database I/O.
class DriftInvestmentRepository implements InvestmentRepository {
  final AppDatabase _db;
  final SyncRepository? _syncRepo;

  DriftInvestmentRepository(this._db, [this._syncRepo]);

  @override
  Stream<List<InvestmentSnapshot>> watchSnapshotsByWallet(int walletId) {
    final query = _db.select(_db.investmentSnapshots)
      ..where((s) => s.walletId.equals(walletId))
      ..orderBy([(s) => OrderingTerm.desc(s.snapshotDate)]);
    return query.watch();
  }

  @override
  Future<int> recordSnapshotAndUpdateBalance({
    required int walletId,
    required double newValue,
  }) {
    return _db
        .transaction(() async {
          // 1. Insert the snapshot record.
          final snapshotId = await _db
              .into(_db.investmentSnapshots)
              .insert(
                InvestmentSnapshotsCompanion(
                  walletId: Value(walletId),
                  totalValue: Value(newValue),
                  snapshotDate: Value(DateTime.now()),
                ),
              );

          // 2. Update the wallet balance to the new asset value.
          await (_db.update(
            _db.wallets,
          )..where((w) => w.id.equals(walletId))).write(
            WalletsCompanion(
              balance: Value(newValue),
              updatedAt: Value(DateTime.now()),
            ),
          );

          return snapshotId;
        })
        .then((id) {
          // Sync wallet balance to cloud
          unawaited(_syncRepo?.syncWallet(walletId));
          return id;
        });
  }
}
