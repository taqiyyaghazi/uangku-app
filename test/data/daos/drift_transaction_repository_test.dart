import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/daos/drift_transaction_repository.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/data/tables/wallets_table.dart';

void main() {
  late AppDatabase db;
  late DriftTransactionRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftTransactionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DriftTransactionRepository.watchCategorySpending', () {
    test(
      'correctly aggregates expenses by category for a specific month',
      () async {
        // 1. Setup Data: Wallet & Categories
        final walletId = await db
            .into(db.wallets)
            .insert(
              WalletsCompanion.insert(
                name: 'Cash',
                balance: const Value(1000.0),
                type: WalletType.cash,
              ),
            );

        final foodCatId = await db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                name: 'Food',
                iconCode: '🍔',
                type: TransactionType.expense,
              ),
            );

        final transportCatId = await db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                name: 'Transport',
                iconCode: '🚗',
                type: TransactionType.expense,
              ),
            );

        final now = DateTime(2025, 3, 15);
        final lastMonth = DateTime(2025, 2, 15);

        // 2. Insert Transactions for Selected Month (March 2025)
        // Food Expense: 50 + 30 = 80
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                walletId: walletId,
                amount: 50.0,
                type: TransactionType.expense,
                categoryId: Value(foodCatId),
                date: DateTime(2025, 3, 5),
              ),
            );
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                walletId: walletId,
                amount: 30.0,
                type: TransactionType.expense,
                categoryId: Value(foodCatId),
                date: DateTime(2025, 3, 10),
              ),
            );

        // Transport Expense: 100
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                walletId: walletId,
                amount: 100.0,
                type: TransactionType.expense,
                categoryId: Value(transportCatId),
                date: DateTime(2025, 3, 15),
              ),
            );

        // 3. Insert Out-of-Scope Transactions
        // Different Month (February)
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                walletId: walletId,
                amount: 200.0,
                type: TransactionType.expense,
                categoryId: Value(foodCatId),
                date: lastMonth,
              ),
            );

        // Different Type (Income)
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                walletId: walletId,
                amount: 500.0,
                type: TransactionType.income,
                categoryId: Value(foodCatId),
                date: now,
              ),
            );

        // 4. Verify
        final results = await repository
            .watchCategorySpending(DateTime(2025, 3, 1))
            .first;

        expect(results.length, 2);

        final foodSpending = results.firstWhere(
          (r) => r.categoryName == 'Food',
        );
        expect(foodSpending.totalAmount, 80.0);

        final transportSpending = results.firstWhere(
          (r) => r.categoryName == 'Transport',
        );
        expect(transportSpending.totalAmount, 100.0);
      },
    );

    test('returns empty list if no expenses for the month', () async {
      final now = DateTime(2025, 3, 1);
      final results = await repository.watchCategorySpending(now).first;
      expect(results, isEmpty);
    });
  });
}
