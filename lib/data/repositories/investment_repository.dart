import 'package:uangku/data/database.dart';

/// Repository interface (contract) for Investment Snapshot data access.
///
/// All investment snapshot I/O operations must go through this abstraction.
abstract class InvestmentRepository {
  /// Returns a reactive stream of all snapshots for a given [walletId],
  /// ordered by snapshot date descending.
  Stream<List<InvestmentSnapshot>> watchSnapshotsByWallet(int walletId);

  /// Atomically records a new snapshot and updates the wallet balance.
  ///
  /// 1. Inserts a record in [InvestmentSnapshots] with [newValue].
  /// 2. Sets [Wallets.balance] to [newValue] for [walletId].
  ///
  /// Uses a database transaction to ensure data integrity.
  Future<int> recordSnapshotAndUpdateBalance({
    required int walletId,
    required double newValue,
  });
}
