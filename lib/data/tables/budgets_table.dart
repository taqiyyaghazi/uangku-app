import 'package:drift/drift.dart';
import 'categories_table.dart';

/// Drift table definition for local Budgets.
///
/// Stores monthly budget limits for specific categories.
class Budgets extends Table {
  /// The category this budget applies to.
  IntColumn get categoryId => integer().references(Categories, #id)();

  /// The monthly spending limit.
  RealColumn get limitAmount => real()();

  /// The month this budget applies to (e.g., "2026-03").
  /// For recurring budgets, this could be a special value or the current month.
  /// Based on Story 8.2.1, we'll store it by month.
  TextColumn get periodMonth => text().withLength(min: 7, max: 7)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {categoryId, periodMonth};
}
