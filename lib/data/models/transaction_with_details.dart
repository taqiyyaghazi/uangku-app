import 'package:uangku/data/database.dart';

/// A composite model that holds a Transaction, its Category, and Wallet names.
///
/// Used for CSV export where human-readable category and wallet names are needed
/// instead of raw foreign-key IDs.
class TransactionWithDetails {
  final Transaction transaction;

  /// The category name. Null for transfers.
  final String? categoryName;

  /// The source wallet name.
  final String walletName;

  /// The destination wallet name (only for transfers).
  final String? toWalletName;

  const TransactionWithDetails({
    required this.transaction,
    this.categoryName,
    required this.walletName,
    this.toWalletName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionWithDetails &&
        other.transaction == transaction &&
        other.categoryName == categoryName &&
        other.walletName == walletName &&
        other.toWalletName == toWalletName;
  }

  @override
  int get hashCode =>
      transaction.hashCode ^
      categoryName.hashCode ^
      walletName.hashCode ^
      toWalletName.hashCode;
}
