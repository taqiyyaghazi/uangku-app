import 'package:drift/drift.dart';

import 'package:uangku/data/database.dart';
import 'package:uangku/data/models/transaction_with_category.dart';
import 'package:uangku/data/repositories/transaction_repository.dart';
import 'package:uangku/data/tables/transactions_table.dart';

/// Drift (SQLite) implementation of [TransactionRepository].
///
/// This is the production adapter — it performs real database I/O.
class DriftTransactionRepository implements TransactionRepository {
  final AppDatabase _db;

  DriftTransactionRepository(this._db);

  @override
  Stream<List<TransactionWithCategory>> watchTransactionsByWallet(
    int walletId,
  ) {
    final query =
        _db.select(_db.transactions).join([
            innerJoin(
              _db.categories,
              _db.categories.id.equalsExp(_db.transactions.categoryId),
            ),
          ])
          ..where(_db.transactions.walletId.equals(walletId))
          ..orderBy([OrderingTerm.desc(_db.transactions.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          transaction: row.readTable(_db.transactions),
          category: row.readTable(_db.categories),
        );
      }).toList();
    });
  }

  @override
  Stream<List<TransactionWithCategory>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    final query =
        _db.select(_db.transactions).join([
            innerJoin(
              _db.categories,
              _db.categories.id.equalsExp(_db.transactions.categoryId),
            ),
          ])
          ..where(
            _db.transactions.date.isBiggerOrEqualValue(start) &
                _db.transactions.date.isSmallerOrEqualValue(end),
          )
          ..orderBy([OrderingTerm.desc(_db.transactions.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          transaction: row.readTable(_db.transactions),
          category: row.readTable(_db.categories),
        );
      }).toList();
    });
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
  Stream<List<TransactionWithCategory>> watchRecentTransactions(int limit) {
    final query =
        _db.select(_db.transactions).join([
            innerJoin(
              _db.categories,
              _db.categories.id.equalsExp(_db.transactions.categoryId),
            ),
          ])
          ..orderBy([OrderingTerm.desc(_db.transactions.date)])
          ..limit(limit);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          transaction: row.readTable(_db.transactions),
          category: row.readTable(_db.categories),
        );
      }).toList();
    });
  }

  @override
  Stream<List<TransactionWithCategory>> watchAllTransactions() {
    final query = _db.select(_db.transactions).join([
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ])..orderBy([OrderingTerm.desc(_db.transactions.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          transaction: row.readTable(_db.transactions),
          category: row.readTable(_db.categories),
        );
      }).toList();
    });
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
