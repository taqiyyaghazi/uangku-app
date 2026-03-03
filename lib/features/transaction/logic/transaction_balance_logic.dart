import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/transactions_table.dart';

/// Pure business logic for computing wallet balance deltas
/// during transaction edit and delete operations.
///
/// All methods are pure functions (input → output, no side effects).
class TransactionBalanceLogic {
  TransactionBalanceLogic._();

  /// Returns the balance delta to **reverse** a transaction's effect.
  ///
  /// Deleting an expense → wallet gains the amount back (positive delta).
  /// Deleting an income → wallet loses the amount (negative delta).
  static double reversalDelta(Transaction tx) {
    return switch (tx.type) {
      TransactionType.expense => tx.amount, // Add back
      TransactionType.income => -tx.amount, // Subtract
      TransactionType.transfer => tx.amount, // Add back to source
    };
  }

  /// Returns the balance delta when updating a transaction's amount/type.
  ///
  /// Computes: reverse old effect + apply new effect.
  ///
  /// Example: Expense 50k → Expense 70k
  ///   reverse old: +50k, apply new: -70k → delta = -20k
  ///
  /// Example: Expense 50k → Income 50k
  ///   reverse old: +50k, apply new: +50k → delta = +100k
  static double updateDelta({
    required Transaction old,
    required double newAmount,
    required TransactionType newType,
  }) {
    final reverseOld = reversalDelta(old);
    final applyNew = switch (newType) {
      TransactionType.expense => -newAmount,
      TransactionType.income => newAmount,
      TransactionType.transfer => -newAmount,
    };
    return reverseOld + applyNew;
  }
}
