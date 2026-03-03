import 'package:uangku/data/database.dart';

/// Repository interface (contract) for Transaction data access.
///
/// All transaction I/O operations must go through this abstraction.
abstract class TransactionRepository {
  /// Returns a reactive stream of all transactions for a given [walletId],
  /// ordered by date descending.
  Stream<List<Transaction>> watchTransactionsByWallet(int walletId);

  /// Returns a reactive stream of all transactions across all wallets
  /// within a date range.
  Stream<List<Transaction>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  );

  /// Inserts a new transaction and returns the generated ID.
  Future<int> createTransaction(TransactionsCompanion transaction);

  /// Deletes a transaction by its [id]. Returns true if any row was affected.
  Future<bool> deleteTransaction(int id);

  /// Atomically inserts a transaction and updates the wallet balance.
  ///
  /// For **income**, the [balanceDelta] should be positive.
  /// For **expense**, the [balanceDelta] should be negative.
  /// For **transfer**, this must be called twice (debit source, credit target).
  ///
  /// Uses a database transaction to ensure both operations succeed or
  /// both are rolled back.
  Future<int> insertTransactionAndUpdateBalance({
    required TransactionsCompanion transaction,
    required int walletId,
    required double balanceDelta,
  });

  /// Returns a reactive stream of the most recent [limit] transactions
  /// across all wallets, ordered by date descending.
  Stream<List<Transaction>> watchRecentTransactions(int limit);
}
