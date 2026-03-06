import 'package:drift/drift.dart';

/// Key-value configuration table for app settings.
class AppSettings extends Table {
  /// The unique string identifier for the setting (e.g., 'monthly_budget').
  TextColumn get key => text()();

  /// The double value associated with this setting.
  RealColumn get value => real()();

  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}
