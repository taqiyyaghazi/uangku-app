import 'package:drift/drift.dart';

import 'package:uangku/data/database.dart';
import 'package:uangku/data/models/category_spending.dart';
import 'package:uangku/data/models/daily_spending.dart';
import 'package:uangku/data/models/monthly_summary.dart';
import 'package:uangku/data/models/transaction_with_category.dart';
import 'package:uangku/data/models/transaction_with_details.dart';
import 'package:uangku/data/repositories/transaction_repository.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/insights/logic/daily_spending_helper.dart';
import 'dart:developer' as developer;

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
  Stream<List<CategorySpending>> watchCategorySpending(DateTime month) {
    // 1. Calculate the start and end of the month
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    // 2. Define aggregating expression
    final amountSum = _db.transactions.amount.sum();

    // 3. Build the grouped query
    final query = _db.selectOnly(_db.transactions)
      ..addColumns([_db.categories.name, amountSum])
      ..join([
        innerJoin(
          _db.categories,
          _db.categories.id.equalsExp(_db.transactions.categoryId),
        ),
      ])
      ..where(
        _db.transactions.date.isBiggerOrEqualValue(startOfMonth) &
            _db.transactions.date.isSmallerOrEqualValue(endOfMonth) &
            _db.transactions.type.equals(TransactionType.expense.name),
      )
      ..groupBy([_db.categories.id]);

    // 4. Map rows to CategorySpending objects
    return query.watch().map((rows) {
      return rows.map((row) {
        final categoryName = row.read(_db.categories.name)!;
        final hash = categoryName.hashCode;
        final colorHex = (hash & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
        return CategorySpending(
          categoryName: categoryName,
          colorCode: '#$colorHex',
          totalAmount: row.read(amountSum) ?? 0.0,
        );
      }).toList();
    });
  }

  @override
  Stream<List<DailySpending>> watchDailySpending(DateTime month) {
    const operation = 'watchDailySpending';
    final startTime = DateTime.now();
    developer.log(
      'START: $operation',
      name: 'DriftTransactionRepository',
      error: {'month': month.toIso8601String()},
    );

    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final dayExpr = CustomExpression<String>(
      "strftime('%Y-%m-%d', datetime(date, 'unixepoch', 'localtime'))",
    );
    final amountSum = _db.transactions.amount.sum();

    final query = _db.selectOnly(_db.transactions)
      ..addColumns([dayExpr, amountSum])
      ..where(
        _db.transactions.date.isBiggerOrEqualValue(startOfMonth) &
            _db.transactions.date.isSmallerOrEqualValue(endOfMonth) &
            _db.transactions.type.equals(TransactionType.expense.name),
      )
      ..groupBy([dayExpr]);

    return query
        .watch()
        .map((rows) {
          final successTime = DateTime.now();
          final durationMs = successTime.difference(startTime).inMilliseconds;
          developer.log(
            'SUCCESS: $operation',
            name: 'DriftTransactionRepository',
            error: {'rows': rows.length, 'durationMs': durationMs},
          );

          final records = rows.map((row) {
            final dayStr = row.read(dayExpr)!;
            final date = DateTime.parse(dayStr);
            return DailySpending(
              date: date,
              totalAmount: row.read(amountSum) ?? 0.0,
            );
          }).toList();

          return DailySpendingHelper.fillDailySpendingGaps(records, month);
        })
        .handleError((err, stack) {
          developer.log(
            'FAILURE: $operation',
            name: 'DriftTransactionRepository',
            error: err,
            stackTrace: stack,
          );
          throw err;
        });
  }

  @override
  Stream<MonthlySummary> watchMonthlySummary(DateTime month) {
    const operation = 'watchMonthlySummary';
    final startTime = DateTime.now();
    developer.log(
      'START: $operation',
      name: 'DriftTransactionRepository',
      error: {'month': month.toIso8601String()},
    );

    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final amountSum = _db.transactions.amount.sum();
    final typeColumn = _db.transactions.type;

    final query = _db.selectOnly(_db.transactions)
      ..addColumns([typeColumn, amountSum])
      ..where(
        _db.transactions.date.isBiggerOrEqualValue(startOfMonth) &
            _db.transactions.date.isSmallerOrEqualValue(endOfMonth),
      )
      ..groupBy([typeColumn]);

    return query
        .watch()
        .map((rows) {
          final successTime = DateTime.now();
          final durationMs = successTime.difference(startTime).inMilliseconds;
          developer.log(
            'SUCCESS: $operation',
            name: 'DriftTransactionRepository',
            error: {'rows': rows.length, 'durationMs': durationMs},
          );

          double income = 0;
          double expense = 0;

          for (final row in rows) {
            final type = row.read(typeColumn);
            final amount = row.read(amountSum) ?? 0.0;

            if (type == TransactionType.income.name) {
              income = amount;
            } else if (type == TransactionType.expense.name) {
              expense = amount;
            }
          }

          return MonthlySummary(totalIncome: income, totalExpenses: expense);
        })
        .handleError((err, stack) {
          developer.log(
            'FAILURE: $operation',
            name: 'DriftTransactionRepository',
            error: err,
            stackTrace: stack,
          );
          throw err;
        });
  }

  @override
  Future<int> createTransaction(TransactionsCompanion transaction) async {
    final startTime = DateTime.now();
    try {
      developer.log(
        'Creating transaction...',
        name: 'DriftTransactionRepository',
      );
      final id = await _db.into(_db.transactions).insert(transaction);
      developer.log(
        'Successfully created transaction id: $id in ${DateTime.now().difference(startTime).inMilliseconds}ms',
        name: 'DriftTransactionRepository',
      );
      return id;
    } catch (e, st) {
      developer.log(
        'Failed to create transaction',
        name: 'DriftTransactionRepository',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<bool> deleteTransaction(int id) async {
    final startTime = DateTime.now();
    try {
      developer.log(
        'Deleting transaction id: $id...',
        name: 'DriftTransactionRepository',
      );
      final rowsAffected = await (_db.delete(
        _db.transactions,
      )..where((t) => t.id.equals(id))).go();
      developer.log(
        'Successfully deleted transaction id: $id (rows affected: $rowsAffected) in ${DateTime.now().difference(startTime).inMilliseconds}ms',
        name: 'DriftTransactionRepository',
      );
      return rowsAffected > 0;
    } catch (e, st) {
      developer.log(
        'Failed to delete transaction id: $id',
        name: 'DriftTransactionRepository',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<int> insertTransactionAndUpdateBalance({
    required TransactionsCompanion transaction,
    required int walletId,
    required double balanceDelta,
  }) async {
    final startTime = DateTime.now();
    try {
      developer.log(
        'Inserting transaction and updating balance for wallet id: $walletId...',
        name: 'DriftTransactionRepository',
      );
      final id = await _db.transaction(() async {
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
      developer.log(
        'Successfully inserted transaction and updated balance id: $id in ${DateTime.now().difference(startTime).inMilliseconds}ms',
        name: 'DriftTransactionRepository',
      );
      return id;
    } catch (e, st) {
      developer.log(
        'Failed to insert transaction and update balance',
        name: 'DriftTransactionRepository',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<int> performInternalTransfer({
    required int fromWalletId,
    required int toWalletId,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    final startTime = DateTime.now();
    try {
      developer.log(
        'Performing internal transfer $fromWalletId -> $toWalletId...',
        name: 'DriftTransactionRepository',
      );
      final id = await _db.transaction(() async {
        // 1. Insert the transfer transaction record.
        // categoryId is omitted since it is now nullable for transfers
        final txId = await _db
            .into(_db.transactions)
            .insert(
              TransactionsCompanion(
                walletId: Value(fromWalletId),
                toWalletId: Value(toWalletId),
                amount: Value(amount),
                type: const Value(TransactionType.transfer),
                note: Value(note),
                date: Value(date),
              ),
            );

        // 2. Deduct from source wallet.
        final fromWallet = await (_db.select(
          _db.wallets,
        )..where((w) => w.id.equals(fromWalletId))).getSingle();

        await (_db.update(
          _db.wallets,
        )..where((w) => w.id.equals(fromWalletId))).write(
          WalletsCompanion(
            balance: Value(fromWallet.balance - amount),
            updatedAt: Value(DateTime.now()),
          ),
        );

        // 3. Add to destination wallet.
        final toWallet = await (_db.select(
          _db.wallets,
        )..where((w) => w.id.equals(toWalletId))).getSingle();

        await (_db.update(
          _db.wallets,
        )..where((w) => w.id.equals(toWalletId))).write(
          WalletsCompanion(
            balance: Value(toWallet.balance + amount),
            updatedAt: Value(DateTime.now()),
          ),
        );

        return txId;
      });
      developer.log(
        'Successfully performed internal transfer id: $id in ${DateTime.now().difference(startTime).inMilliseconds}ms',
        name: 'DriftTransactionRepository',
      );
      return id;
    } catch (e, st) {
      developer.log(
        'Failed to perform internal transfer',
        name: 'DriftTransactionRepository',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Stream<List<TransactionWithCategory>> watchRecentTransactions(int limit) {
    final query =
        _db.select(_db.transactions).join([
            leftOuterJoin(
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
          category: row.readTableOrNull(_db.categories),
        );
      }).toList();
    });
  }

  @override
  Stream<List<TransactionWithCategory>> watchAllTransactions({int? walletId}) {
    final query = _db.select(_db.transactions).join([
      leftOuterJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ])..orderBy([OrderingTerm.desc(_db.transactions.date)]);

    if (walletId != null) {
      query.where(
        _db.transactions.walletId.equals(walletId) |
            _db.transactions.toWalletId.equals(walletId),
      );
    }

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          transaction: row.readTable(_db.transactions),
          category: row.readTableOrNull(_db.categories),
        );
      }).toList();
    });
  }

  @override
  Future<void> deleteTransactionAtomic(Transaction transaction) async {
    final startTime = DateTime.now();
    try {
      developer.log(
        'Deleting transaction atomic id: ${transaction.id}...',
        name: 'DriftTransactionRepository',
      );
      await _db.transaction(() async {
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
      developer.log(
        'Successfully deleted transaction atomic id: ${transaction.id} in ${DateTime.now().difference(startTime).inMilliseconds}ms',
        name: 'DriftTransactionRepository',
      );
    } catch (e, st) {
      developer.log(
        'Failed to delete transaction atomic id: ${transaction.id}',
        name: 'DriftTransactionRepository',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<void> updateTransactionAtomic({
    required int transactionId,
    required TransactionsCompanion updated,
    required int walletId,
    required double balanceDelta,
  }) async {
    final startTime = DateTime.now();
    try {
      developer.log(
        'Updating transaction atomic id: $transactionId...',
        name: 'DriftTransactionRepository',
      );
      await _db.transaction(() async {
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
      developer.log(
        'Successfully updated transaction atomic id: $transactionId in ${DateTime.now().difference(startTime).inMilliseconds}ms',
        name: 'DriftTransactionRepository',
      );
    } catch (e, st) {
      developer.log(
        'Failed to update transaction atomic id: $transactionId',
        name: 'DriftTransactionRepository',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<List<TransactionWithDetails>> getAllTransactionsWithDetails() async {
    const operation = 'getAllTransactionsWithDetails';
    final startTime = DateTime.now();
    developer.log('START: $operation', name: 'DriftTransactionRepository');

    try {
      // Alias the wallets table for the two different joins.
      final sourceWallet = _db.alias(_db.wallets, 'sw');
      final destWallet = _db.alias(_db.wallets, 'dw');

      final query = _db.select(_db.transactions).join([
        leftOuterJoin(
          _db.categories,
          _db.categories.id.equalsExp(_db.transactions.categoryId),
        ),
        innerJoin(
          sourceWallet,
          sourceWallet.id.equalsExp(_db.transactions.walletId),
        ),
        leftOuterJoin(
          destWallet,
          destWallet.id.equalsExp(_db.transactions.toWalletId),
        ),
      ])..orderBy([OrderingTerm.desc(_db.transactions.date)]);

      final rows = await query.get();

      final results = rows.map((row) {
        final transaction = row.readTable(_db.transactions);
        final category = row.readTableOrNull(_db.categories);
        final srcWallet = row.readTable(sourceWallet);
        final dstWallet = row.readTableOrNull(destWallet);

        return TransactionWithDetails(
          transaction: transaction,
          categoryName: category?.name,
          walletName: srcWallet.name,
          toWalletName: dstWallet?.name,
        );
      }).toList();

      final durationMs = DateTime.now().difference(startTime).inMilliseconds;
      developer.log(
        'SUCCESS: $operation',
        name: 'DriftTransactionRepository',
        error: {'rows': results.length, 'durationMs': durationMs},
      );

      return results;
    } catch (e, st) {
      developer.log(
        'FAILURE: $operation',
        name: 'DriftTransactionRepository',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
