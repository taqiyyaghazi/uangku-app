import 'package:drift/drift.dart';

/// Represents the type of a wallet.
enum WalletType { cash, bank, investment }

/// Drift table definition for Wallets.
///
/// Stores user wallet information including name, balance, type, and
/// visual properties (color, icon) for display on the dashboard grid.
class Wallets extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  RealColumn get balance => real().withDefault(const Constant(0.0))();

  TextColumn get type => textEnum<WalletType>()();

  TextColumn get colorHex => text()
      .withLength(min: 4, max: 9)
      .withDefault(const Constant('#008080'))();

  TextColumn get icon => text()
      .withLength(min: 1, max: 50)
      .withDefault(const Constant('wallet'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
