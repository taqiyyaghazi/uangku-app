import 'package:drift/drift.dart';

import 'transactions_table.dart';

/// Drift table definition for local Categories.
///
/// Categories are used to classify transactions. The iconCode stores an emoji.
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 50)();

  TextColumn get iconCode => text()();

  /// The type of transactions this category applies to (e.g., income, expense).
  TextColumn get type => textEnum<TransactionType>()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
