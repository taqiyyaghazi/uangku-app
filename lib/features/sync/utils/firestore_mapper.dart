import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/data/tables/wallets_table.dart';

/// Utility class to map Drift models to and from Firestore JSON maps.
class FirestoreMapper {
  /// Converts a [Wallet] to a Firestore-compatible Map.
  static Map<String, dynamic> walletToFirestore(Wallet wallet) {
    return {
      'id': wallet.id, // Primary key stored as int
      'name': wallet.name,
      'balance': wallet.balance,
      'type': wallet.type.name,
      'colorHex': wallet.colorHex,
      'icon': wallet.icon,
      'createdAt': firestore.Timestamp.fromDate(wallet.createdAt),
      'updatedAt': firestore.Timestamp.fromDate(wallet.updatedAt),
    };
  }

  /// Converts a Firestore Map to a [Wallet].
  static Wallet walletFromFirestore(Map<String, dynamic> data) {
    return Wallet(
      id: data['id'] as int,
      name: data['name'] as String,
      balance: (data['balance'] as num).toDouble(),
      type: WalletType.values.byName(data['type'] as String),
      colorHex: data['colorHex'] as String,
      icon: data['icon'] as String,
      createdAt: (data['createdAt'] as firestore.Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as firestore.Timestamp).toDate(),
    );
  }

  /// Converts a [Category] to a Firestore-compatible Map.
  static Map<String, dynamic> categoryToFirestore(Category category) {
    return {
      'id': category.id,
      'name': category.name,
      'iconCode': category.iconCode,
      'type': category.type.name,
      'createdAt': firestore.Timestamp.fromDate(category.createdAt),
      'updatedAt': firestore.Timestamp.fromDate(category.updatedAt),
    };
  }

  /// Converts a Firestore Map to a [Category].
  static Category categoryFromFirestore(Map<String, dynamic> data) {
    return Category(
      id: data['id'] as int,
      name: data['name'] as String,
      iconCode: data['iconCode'] as String,
      type: TransactionType.values.byName(data['type'] as String),
      createdAt: (data['createdAt'] as firestore.Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as firestore.Timestamp).toDate(),
    );
  }

  /// Converts a [Transaction] to a Firestore-compatible Map.
  static Map<String, dynamic> transactionToFirestore(Transaction transaction) {
    return {
      'id': transaction.id,
      'walletId': transaction.walletId,
      'amount': transaction.amount,
      'type': transaction.type.name,
      'categoryId': transaction.categoryId,
      'toWalletId': transaction.toWalletId,
      'note': transaction.note,
      'date': firestore.Timestamp.fromDate(transaction.date),
      'createdAt': firestore.Timestamp.fromDate(transaction.createdAt),
      'updatedAt': firestore.Timestamp.fromDate(transaction.updatedAt),
    };
  }

  /// Converts a Firestore Map to a [Transaction].
  static Transaction transactionFromFirestore(Map<String, dynamic> data) {
    return Transaction(
      id: data['id'] as int,
      walletId: data['walletId'] as int,
      amount: (data['amount'] as num).toDouble(),
      type: TransactionType.values.byName(data['type'] as String),
      categoryId: data['categoryId'] as int?,
      toWalletId: data['toWalletId'] as int?,
      note: data['note'] as String,
      date: (data['date'] as firestore.Timestamp).toDate(),
      createdAt: (data['createdAt'] as firestore.Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as firestore.Timestamp).toDate(),
    );
  }

  /// Converts a [Budget] to a Firestore-compatible Map.
  static Map<String, dynamic> budgetToFirestore(Budget budget) {
    return {
      'categoryId': budget.categoryId,
      'limitAmount': budget.limitAmount,
      'periodMonth': budget.periodMonth,
      'updatedAt': firestore.Timestamp.fromDate(budget.updatedAt),
    };
  }

  /// Converts a Firestore Map to a [Budget].
  static Budget budgetFromValue(Map<String, dynamic> data) {
    return Budget(
      categoryId: data['categoryId'] as int,
      limitAmount: (data['limitAmount'] as num).toDouble(),
      periodMonth: data['periodMonth'] as String,
      updatedAt: (data['updatedAt'] as firestore.Timestamp).toDate(),
    );
  }

  /// Converts an [InvestmentSnapshot] to a Firestore-compatible Map.
  static Map<String, dynamic> investmentToFirestore(
    InvestmentSnapshot snapshot,
  ) {
    return {
      'id': snapshot.id,
      'walletId': snapshot.walletId,
      'totalValue': snapshot.totalValue,
      'snapshotDate': firestore.Timestamp.fromDate(snapshot.snapshotDate),
    };
  }

  /// Converts a Firestore Map to an [InvestmentSnapshot].
  static InvestmentSnapshot investmentFromFirestore(Map<String, dynamic> data) {
    return InvestmentSnapshot(
      id: data['id'] as int,
      walletId: data['walletId'] as int,
      totalValue: (data['totalValue'] as num).toDouble(),
      snapshotDate: (data['snapshotDate'] as firestore.Timestamp).toDate(),
    );
  }

  static Map<String, dynamic> settingToFirestore(AppSetting setting) {
    return {
      'key': setting.key,
      'value': setting.value,
      'updatedAt': setting.updatedAt != null
          ? firestore.Timestamp.fromDate(setting.updatedAt!)
          : firestore.FieldValue.serverTimestamp(),
    };
  }

  static AppSetting settingFromFirestore(Map<String, dynamic> data) {
    return AppSetting(
      key: data['key'] as String,
      value: (data['value'] as num).toDouble(),
      updatedAt: (data['updatedAt'] as firestore.Timestamp?)?.toDate(),
    );
  }
}
