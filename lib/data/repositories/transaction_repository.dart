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
}
