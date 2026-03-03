import 'package:drift/drift.dart';

import 'wallets_table.dart';

/// Drift table definition for Investment Snapshots.
///
/// Stores periodic snapshots of investment wallet values
/// to generate growth trend charts in the Portfolio feature.
class InvestmentSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get walletId => integer().references(Wallets, #id)();

  RealColumn get totalValue => real()();

  DateTimeColumn get snapshotDate => dateTime()();
}
