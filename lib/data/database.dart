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
import 'package:uangku/data/tables/categories_table.dart';
import 'package:uangku/data/tables/budgets_table.dart';
import 'package:uangku/core/constants/transaction_categories.dart';

part 'database.g.dart';

/// The main Drift database for Uangku.
///
/// Includes all tables and manages schema versioning.
/// Use code generation: `dart run build_runner build --delete-conflicting-outputs`
@DriftDatabase(
  tables: [
    Wallets,
    Transactions,
    InvestmentSnapshots,
    AppSettings,
    Categories,
    Budgets,
  ],
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

  /// Wipes all local data from the database.
  /// Used during secure logout to ensure no data leaks between accounts.
  Future<void> deleteAllLocalData() {
    return transaction(() async {
      await delete(transactions).go();
      await delete(budgets).go();
      await delete(investmentSnapshots).go();
      await delete(wallets).go();
      await delete(categories).go();
      await delete(appSettings).go();
    });
  }

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaultCategories(this);
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(appSettings);
        }
        if (from < 3) {
          await m.createTable(categories);
          await m.addColumn(transactions, transactions.categoryId);
          await _seedDefaultCategories(this);
        }
        if (from < 4) {
          await m.addColumn(transactions, transactions.toWalletId);
        }
        if (from < 5) {
          // ignore: experimental_member_use
          await m.alterTable(TableMigration(transactions));
        }
        if (from < 6) {
          await m.alterTable(
            // ignore: experimental_member_use
            TableMigration(transactions, newColumns: [transactions.updatedAt]),
          );

          await m.alterTable(
            // ignore: experimental_member_use
            TableMigration(categories, newColumns: [categories.updatedAt]),
          );
        }
        if (from < 7) {
          await m.createTable(budgets);
        }
        if (from < 8) {
          await m.alterTable(
            // ignore: experimental_member_use
            TableMigration(appSettings, newColumns: [appSettings.updatedAt]),
          );
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

Future<void> _seedDefaultCategories(AppDatabase db) async {
  // Check if categories exist first
  final count = await db.categories.count().getSingle();
  if (count > 0) return;

  final defaultCategories = [
    ...TransactionCategories.income.map(
      (c) => CategoriesCompanion.insert(
        name: c,
        iconCode: '💰',
        type: TransactionType.income,
      ),
    ),
    ...TransactionCategories.expense.map(
      (c) => CategoriesCompanion.insert(
        name: c,
        iconCode: '💸',
        type: TransactionType.expense,
      ),
    ),
    ...TransactionCategories.transfer.map(
      (c) => CategoriesCompanion.insert(
        name: c,
        iconCode: '🔄',
        type: TransactionType.transfer,
      ),
    ),
  ];

  await db.batch((batch) {
    batch.insertAll(db.categories, defaultCategories);
  });
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  });
}
