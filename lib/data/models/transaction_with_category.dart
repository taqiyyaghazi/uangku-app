import 'package:uangku/data/database.dart';

/// A composite model that holds a Transaction and its associated Category.
///
/// This is used by the UI so it doesn't have to perform table joins.
class TransactionWithCategory {
  final Transaction transaction;
  final Category category;

  const TransactionWithCategory({
    required this.transaction,
    required this.category,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionWithCategory &&
        other.transaction == transaction &&
        other.category == category;
  }

  @override
  int get hashCode => transaction.hashCode ^ category.hashCode;
}
