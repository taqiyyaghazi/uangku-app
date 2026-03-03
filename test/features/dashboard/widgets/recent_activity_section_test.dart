import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/dashboard/widgets/recent_activity_section.dart';

void main() {
  final now = DateTime(2026, 3, 3, 14, 30);

  final fakeWallets = [
    Wallet(
      id: 1,
      name: 'Bank BCA',
      balance: 1000000,
      type: WalletType.bank,
      colorHex: '#008080',
      icon: 'bank',
      createdAt: now,
      updatedAt: now,
    ),
  ];

  final fakeTransactions = [
    Transaction(
      id: 1,
      walletId: 1,
      amount: 50000,
      type: TransactionType.expense,
      category: 'Food',
      note: 'Lunch',
      date: now,
      createdAt: now,
    ),
    Transaction(
      id: 2,
      walletId: 1,
      amount: 5000000,
      type: TransactionType.income,
      category: 'Salary',
      note: 'Monthly',
      date: DateTime(2026, 3, 2, 9, 0),
      createdAt: now,
    ),
  ];

  Widget buildTestWidget({
    List<Transaction> transactions = const [],
    List<Wallet> wallets = const [],
  }) {
    return ProviderScope(
      overrides: [
        recentTransactionsProvider.overrideWith(
          (_) => Stream.value(transactions),
        ),
        walletsProvider.overrideWith((_) => Stream.value(wallets)),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: CustomScrollView(slivers: [RecentActivitySection()]),
        ),
      ),
    );
  }

  group('RecentActivitySection', () {
    testWidgets('shows section header', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Recent Activity'), findsOneWidget);
    });

    testWidgets('shows empty state when no transactions', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Belum ada transaksi. Tap + untuk memulai.'),
        findsOneWidget,
      );
    });

    testWidgets('shows transaction items when data exists', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(transactions: fakeTransactions, wallets: fakeWallets),
      );
      await tester.pumpAndSettle();

      // Both transactions should be visible.
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
    });

    testWidgets('shows wallet name in transaction subtitle', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(transactions: fakeTransactions, wallets: fakeWallets),
      );
      await tester.pumpAndSettle();

      // "Bank BCA" should appear in the subtitles.
      expect(find.textContaining('Bank BCA'), findsWidgets);
    });

    testWidgets('hides empty state when transactions exist', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(transactions: fakeTransactions, wallets: fakeWallets),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Belum ada transaksi. Tap + untuk memulai.'),
        findsNothing,
      );
    });
  });
}
