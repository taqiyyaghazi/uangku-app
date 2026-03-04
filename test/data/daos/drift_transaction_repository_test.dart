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

  group('DriftTransactionRepository.watchDailySpending', () {
    test('correctly aggregates expenses by day and fills gaps', () async {
      final walletId = await db
          .into(db.wallets)
          .insert(
            WalletsCompanion.insert(
              name: 'Cash',
              balance: const Value(1000.0),
              type: WalletType.cash,
            ),
          );

      // March 2025 has 31 days.
      final targetMonth = DateTime(2025, 3, 1);

      // Day 5: 50.0
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              walletId: walletId,
              amount: 50.0,
              type: TransactionType.expense,
              date: DateTime(2025, 3, 5, 10, 30),
            ),
          );

      // Day 5: 30.0 (total 80.0)
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              walletId: walletId,
              amount: 30.0,
              type: TransactionType.expense,
              date: DateTime(2025, 3, 5, 14, 0),
            ),
          );

      // Day 15: 100.0
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              walletId: walletId,
              amount: 100.0,
              type: TransactionType.expense,
              date: DateTime(2025, 3, 15),
            ),
          );

      // Out of scope: Income on day 5
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              walletId: walletId,
              amount: 500.0,
              type: TransactionType.income,
              date: DateTime(2025, 3, 5),
            ),
          );

      // Out of scope: Other month
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              walletId: walletId,
              amount: 200.0,
              type: TransactionType.expense,
              date: DateTime(2025, 2, 28),
            ),
          );

      final results = await repository.watchDailySpending(targetMonth).first;

      expect(results.length, 31); // March has 31 days

      // Verify Day 5
      expect(results[4].date.day, 5);
      expect(results[4].totalAmount, 80.0);

      // Verify Day 15
      expect(results[14].date.day, 15);
      expect(results[14].totalAmount, 100.0);

      // Verify a gap day (Day 1)
      expect(results[0].date.day, 1);
      expect(results[0].totalAmount, 0.0);

      // Verify last day (Day 31)
      expect(results[30].date.day, 31);
      expect(results[30].totalAmount, 0.0);
    });

    test('returns all zero if no expenses', () async {
      final results = await repository
          .watchDailySpending(DateTime(2025, 4, 1))
          .first;
      expect(results.length, 30); // April has 30 days
      expect(results.every((r) => r.totalAmount == 0.0), isTrue);
    });
  });
}
