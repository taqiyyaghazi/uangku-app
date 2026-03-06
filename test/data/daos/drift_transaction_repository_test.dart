import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/daos/drift_transaction_repository.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/data/tables/wallets_table.dart';

import 'drift_transaction_repository_test.mocks.dart';

@GenerateMocks([MonitoringService])
void main() {
  late AppDatabase db;
  late DriftTransactionRepository repository;
  late MockMonitoringService mockMonitoring;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mockMonitoring = MockMonitoringService();
    repository = DriftTransactionRepository(db, mockMonitoring);
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

  group('DriftTransactionRepository.watchAllTransactions', () {
    test('filters transactions by walletId or toWalletId', () async {
      // 1. Setup Data: Wallets & Category
      final wallet1 = await db
          .into(db.wallets)
          .insert(
            WalletsCompanion.insert(
              name: 'Wallet 1',
              balance: const Value(1000.0),
              type: WalletType.cash,
            ),
          );

      final wallet2 = await db
          .into(db.wallets)
          .insert(
            WalletsCompanion.insert(
              name: 'Wallet 2',
              balance: const Value(1000.0),
              type: WalletType.bank,
            ),
          );

      final wallet3 = await db
          .into(db.wallets)
          .insert(
            WalletsCompanion.insert(
              name: 'Wallet 3',
              balance: const Value(1000.0),
              type: WalletType.bank,
            ),
          );

      final catId = await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              name: 'Food',
              iconCode: '🍔',
              type: TransactionType.expense,
            ),
          );

      // 2. Insert Transactions
      // tx1: Expense on Wallet 1
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              walletId: wallet1,
              amount: 50.0,
              type: TransactionType.expense,
              categoryId: Value(catId),
              date: DateTime(2025, 3, 5),
            ),
          );

      // tx2: Transfer from Wallet 1 to Wallet 2
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              walletId: wallet1,
              toWalletId: Value(wallet2),
              amount: 100.0,
              type: TransactionType.transfer,
              date: DateTime(2025, 3, 6),
            ),
          );

      // tx3: Income on Wallet 3
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              walletId: wallet3,
              amount: 500.0,
              type: TransactionType.income,
              categoryId: Value(catId),
              date: DateTime(2025, 3, 7),
            ),
          );

      // 3. Verify No Filter (All Transactions)
      final allTx = await repository.watchAllTransactions().first;
      expect(allTx.length, 3);

      // 4. Verify Wallet 1 Filter
      // Should include tx1 (wallet1) and tx2 (wallet1 -> wallet2)
      final wallet1Tx = await repository
          .watchAllTransactions(walletId: wallet1)
          .first;
      expect(wallet1Tx.length, 2);
      expect(wallet1Tx.any((t) => t.transaction.amount == 50.0), isTrue);
      expect(wallet1Tx.any((t) => t.transaction.amount == 100.0), isTrue);

      // 5. Verify Wallet 2 Filter
      // Should include tx2 (wallet1 -> wallet2)
      final wallet2Tx = await repository
          .watchAllTransactions(walletId: wallet2)
          .first;
      expect(wallet2Tx.length, 1);
      expect(wallet2Tx.first.transaction.amount, 100.0);
      expect(wallet2Tx.first.transaction.type, TransactionType.transfer);

      // 6. Verify Wallet 3 Filter
      // Should include tx3 (wallet3)
      final wallet3Tx = await repository
          .watchAllTransactions(walletId: wallet3)
          .first;
      expect(wallet3Tx.length, 1);
      expect(wallet3Tx.first.transaction.amount, 500.0);
    });
  });

  group('DriftTransactionRepository.getAllTransactionsWithDetails', () {
    test(
      'returns transactions with resolved category and wallet names',
      () async {
        // 1. Setup wallets.
        final walletId = await db
            .into(db.wallets)
            .insert(
              WalletsCompanion.insert(
                name: 'Bank BCA',
                balance: const Value(1000000.0),
                type: WalletType.bank,
              ),
            );

        // 2. Setup category.
        final foodCatId = await db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                name: 'Food',
                iconCode: '🍔',
                type: TransactionType.expense,
              ),
            );

        // 3. Insert an expense transaction.
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                walletId: walletId,
                amount: 50000,
                type: TransactionType.expense,
                categoryId: Value(foodCatId),
                note: const Value('Lunch'),
                date: DateTime(2026, 3, 5),
              ),
            );

        // 4. Verify.
        final results = await repository.getAllTransactionsWithDetails();

        expect(results.length, 1);
        expect(results.first.categoryName, 'Food');
        expect(results.first.walletName, 'Bank BCA');
        expect(results.first.toWalletName, isNull);
        expect(results.first.transaction.amount, 50000.0);
      },
    );

    test('returns transfer with source and destination wallet names', () async {
      // 1. Setup wallets.
      final wallet1 = await db
          .into(db.wallets)
          .insert(
            WalletsCompanion.insert(
              name: 'Bank BCA',
              balance: const Value(1000000.0),
              type: WalletType.bank,
            ),
          );

      final wallet2 = await db
          .into(db.wallets)
          .insert(
            WalletsCompanion.insert(
              name: 'Cash',
              balance: const Value(500000.0),
              type: WalletType.cash,
            ),
          );

      // 2. Insert a transfer transaction.
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              walletId: wallet1,
              toWalletId: Value(wallet2),
              amount: 100000,
              type: TransactionType.transfer,
              note: const Value('Withdraw'),
              date: DateTime(2026, 3, 10),
            ),
          );

      // 3. Verify.
      final results = await repository.getAllTransactionsWithDetails();

      expect(results.length, 1);
      expect(results.first.categoryName, isNull);
      expect(results.first.walletName, 'Bank BCA');
      expect(results.first.toWalletName, 'Cash');
      expect(results.first.transaction.type, TransactionType.transfer);
    });

    test('returns empty list when no transactions exist', () async {
      final results = await repository.getAllTransactionsWithDetails();
      expect(results, isEmpty);
    });
  });
}
