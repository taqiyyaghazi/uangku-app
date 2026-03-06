import 'package:drift/drift.dart';

import 'categories_table.dart';
import 'wallets_table.dart';

/// Represents the type of a financial transaction.
enum TransactionType { income, expense, transfer }

/// Drift table definition for Transactions.
///
/// Records all financial movements: income, expense, or transfer.
/// Each transaction is linked to a wallet via [walletId].
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get walletId => integer().references(Wallets, #id)();

  RealColumn get amount => real()();

  TextColumn get type => textEnum<TransactionType>()();

  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();

  IntColumn get toWalletId => integer().nullable().references(Wallets, #id)();

  TextColumn get note => text().withDefault(const Constant(''))();

  DateTimeColumn get date => dateTime()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
