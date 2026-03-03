import 'package:drift/drift.dart';

import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/transaction_repository.dart';
import 'package:uangku/data/tables/transactions_table.dart';

/// Drift (SQLite) implementation of [TransactionRepository].
///
/// This is the production adapter — it performs real database I/O.
class DriftTransactionRepository implements TransactionRepository {
  final AppDatabase _db;

  DriftTransactionRepository(this._db);

  @override
  Stream<List<Transaction>> watchTransactionsByWallet(int walletId) {
    final query = _db.select(_db.transactions)
      ..where((t) => t.walletId.equals(walletId))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch();
  }

  @override
  Stream<List<Transaction>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    final query = _db.select(_db.transactions)
      ..where(
        (t) =>
            t.date.isBiggerOrEqualValue(start) &
            t.date.isSmallerOrEqualValue(end),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch();
  }

  @override
  Future<int> createTransaction(TransactionsCompanion transaction) {
    return _db.into(_db.transactions).insert(transaction);
  }

  @override
  Future<bool> deleteTransaction(int id) async {
    final rowsAffected = await (_db.delete(
      _db.transactions,
    )..where((t) => t.id.equals(id))).go();
    return rowsAffected > 0;
  }

  @override
  Future<int> insertTransactionAndUpdateBalance({
    required TransactionsCompanion transaction,
    required int walletId,
    required double balanceDelta,
  }) {
    return _db.transaction(() async {
      // 1. Insert the transaction record.
      final txId = await _db.into(_db.transactions).insert(transaction);

      // 2. Update the wallet balance atomically.
      final wallet = await (_db.select(
        _db.wallets,
      )..where((w) => w.id.equals(walletId))).getSingle();

      await (_db.update(
        _db.wallets,
      )..where((w) => w.id.equals(walletId))).write(
        WalletsCompanion(
          balance: Value(wallet.balance + balanceDelta),
          updatedAt: Value(DateTime.now()),
        ),
      );

      return txId;
    });
  }

  @override
  Stream<List<Transaction>> watchRecentTransactions(int limit) {
    final query = _db.select(_db.transactions)
      ..orderBy([(t) => OrderingTerm.desc(t.date)])
      ..limit(limit);
    return query.watch();
  }

  @override
  Stream<List<Transaction>> watchAllTransactions() {
    final query = _db.select(_db.transactions)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch();
  }

  @override
  Future<void> deleteTransactionAtomic(Transaction transaction) {
    return _db.transaction(() async {
      // 1. Delete the transaction record.
      await (_db.delete(
        _db.transactions,
      )..where((t) => t.id.equals(transaction.id))).go();

      // 2. Reverse the balance effect on the wallet.
      final wallet = await (_db.select(
        _db.wallets,
      )..where((w) => w.id.equals(transaction.walletId))).getSingle();

      final reversalDelta = switch (transaction.type) {
        TransactionType.expense => transaction.amount,
        TransactionType.income => -transaction.amount,
        TransactionType.transfer => transaction.amount,
      };

      await (_db.update(
        _db.wallets,
      )..where((w) => w.id.equals(transaction.walletId))).write(
        WalletsCompanion(
          balance: Value(wallet.balance + reversalDelta),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<void> updateTransactionAtomic({
    required int transactionId,
    required TransactionsCompanion updated,
    required int walletId,
    required double balanceDelta,
  }) {
    return _db.transaction(() async {
      // 1. Update the transaction record.
      await (_db.update(
        _db.transactions,
      )..where((t) => t.id.equals(transactionId))).write(updated);

      // 2. Adjust the wallet balance by the computed delta.
      final wallet = await (_db.select(
        _db.wallets,
      )..where((w) => w.id.equals(walletId))).getSingle();

      await (_db.update(
        _db.wallets,
      )..where((w) => w.id.equals(walletId))).write(
        WalletsCompanion(
          balance: Value(wallet.balance + balanceDelta),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }
}
