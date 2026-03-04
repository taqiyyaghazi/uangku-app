import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/models/category_spending.dart';
import 'package:uangku/data/models/transaction_with_category.dart';
import 'package:uangku/data/repositories/transaction_repository.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/transaction/screens/transactions_archive_screen.dart';

/// Fake Wallet Repo
class FakeWalletRepository implements WalletRepository {
  @override
  Stream<List<Wallet>> watchAllWallets() => Stream.value([
    Wallet(
      id: 1,
      name: 'My Wallet',
      type: WalletType.cash,
      balance: 1000,
      colorHex: 'FFFFFF',
      icon: 'wallet',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ]);

  @override
  Future<int> createWallet(WalletsCompanion wallet) async => 1;

  @override
  Future<bool> updateWallet(WalletsCompanion wallet) async => true;

  @override
  Future<bool> deleteWallet(int id) async => true;

  @override
  Future<Wallet?> getWalletById(int id) async => null;
}

/// Fake Transaction Repo
class FakeTransactionRepository implements TransactionRepository {
  final List<TransactionWithCategory> transactions;

  FakeTransactionRepository({required this.transactions});

  @override
  Stream<List<TransactionWithCategory>> watchAllTransactions() =>
      Stream.value(transactions);

  @override
  Stream<List<TransactionWithCategory>> watchRecentTransactions(int limit) =>
      Stream.value(transactions.take(limit).toList());

  @override
  Stream<List<TransactionWithCategory>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return Stream.value(
      transactions
          .where(
            (t) =>
                t.transaction.date.isAfter(start) &&
                t.transaction.date.isBefore(end),
          )
          .toList(),
    );
  }

  @override
  Stream<List<CategorySpending>> watchCategorySpending(DateTime month) =>
      Stream.value([]);

  @override
  Stream<List<TransactionWithCategory>> watchTransactionsByWallet(
    int walletId,
  ) {
    return Stream.value(
      transactions.where((t) => t.transaction.walletId == walletId).toList(),
    );
  }

  @override
  Future<int> createTransaction(TransactionsCompanion transaction) async => 1;

  @override
  Future<bool> deleteTransaction(int id) async => true;

  @override
  Future<void> deleteTransactionAtomic(Transaction transaction) async {}

  @override
  Future<int> insertTransactionAndUpdateBalance({
    required TransactionsCompanion transaction,
    required int walletId,
    required double balanceDelta,
  }) async => 1;

  @override
  Future<void> updateTransactionAtomic({
    required int transactionId,
    required TransactionsCompanion updated,
    required int walletId,
    required double balanceDelta,
  }) async {}

  @override
  Future<int> performInternalTransfer({
    required int fromWalletId,
    required int toWalletId,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    return 1;
  }
}

void main() {
  final t1 = TransactionWithCategory(
    transaction: Transaction(
      id: 1,
      walletId: 1,
      categoryId: 1,
      amount: 50000,
      type: TransactionType.expense,
      note: 'Lunch KFC',
      date: DateTime(2026, 3, 10), // March 2026
      createdAt: DateTime.now(),
    ),
    category: Category(
      id: 1,
      name: 'Food',
      iconCode: 'fastfood',
      type: TransactionType.expense,
      createdAt: DateTime.now(),
    ),
  );

  final t2 = TransactionWithCategory(
    transaction: Transaction(
      id: 2,
      walletId: 1,
      categoryId: 2,
      amount: 20000,
      type: TransactionType.expense,
      note: 'Gojek Home',
      date: DateTime(2026, 2, 28), // February 2026
      createdAt: DateTime.now(),
    ),
    category: Category(
      id: 2,
      name: 'Transport',
      iconCode: 'directions_car',
      type: TransactionType.expense,
      createdAt: DateTime.now(),
    ),
  );

  Widget buildTestApp(List<TransactionWithCategory> transactions) {
    return ProviderScope(
      overrides: [
        walletRepositoryProvider.overrideWithValue(FakeWalletRepository()),
        transactionRepositoryProvider.overrideWithValue(
          FakeTransactionRepository(transactions: transactions),
        ),
      ],
      child: const MaterialApp(home: TransactionsArchiveScreen()),
    );
  }

  group('TransactionsArchiveScreen', () {
    testWidgets('renders sticky headers and transaction list', (tester) async {
      await tester.pumpWidget(buildTestApp([t1, t2]));
      await tester.pumpAndSettle();

      // Check title
      expect(find.text('All Transactions'), findsOneWidget);

      // Check grouped headers
      expect(find.text('March 2026'), findsOneWidget);
      expect(find.text('February 2026'), findsOneWidget);

      // Check transaction categories (since TransactionItem displays category, not note)
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('renders empty state when no transactions exist', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp([]));
      await tester.pumpAndSettle();

      expect(
        find.text('Riwayat kosong. Mulai mencatat hari ini!'),
        findsOneWidget,
      );
    });

    testWidgets('filters transactions using search bar', (tester) async {
      await tester.pumpWidget(buildTestApp([t1, t2]));
      await tester.pumpAndSettle();

      // Ensure both are visible before search
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);

      // Enter search text "gojek" (which matches t2's note, even though note isn't displayed)
      await tester.enterText(find.byType(CupertinoSearchTextField), 'gojek');
      await tester.pumpAndSettle();

      // T2 (Transport) should be visible, T1 (Food) should not.
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Food'), findsNothing);

      // The header for March (T1) should also be gone, since T1 is filtered out
      expect(find.text('February 2026'), findsOneWidget);
      expect(find.text('March 2026'), findsNothing);
    });

    testWidgets('shows empty state when search matches nothing', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp([t1, t2]));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(CupertinoSearchTextField),
        'Starbucks',
      );
      await tester.pumpAndSettle();

      expect(find.text('No transactions match your search.'), findsOneWidget);
    });
  });
}
