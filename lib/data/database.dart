import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:uangku/core/constants/app_constants.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/data/tables/investment_snapshots_table.dart';
import 'package:uangku/data/tables/app_settings_table.dart';

part 'database.g.dart';

/// The main Drift database for Uangku.
///
/// Includes all tables and manages schema versioning.
/// Use code generation: `dart run build_runner build --delete-conflicting-outputs`
@DriftDatabase(
  tables: [Wallets, Transactions, InvestmentSnapshots, AppSettings],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._(super.e);

  /// Production constructor using a native SQLite file.
  factory AppDatabase() {
    return AppDatabase._(_openConnection());
  }

  /// Test constructor that accepts any [QueryExecutor].
  ///
  /// This enables injecting an in-memory database for integration tests.
  factory AppDatabase.forTesting(QueryExecutor executor) {
    return AppDatabase._(executor);
  }

  @override
  int get schemaVersion => AppConstants.databaseVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(appSettings);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  });
}
