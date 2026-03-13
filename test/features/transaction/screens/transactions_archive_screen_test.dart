import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:uangku/core/di/providers.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/models/category_spending.dart';
import 'package:uangku/data/models/daily_spending.dart';
import 'package:uangku/data/models/monthly_summary.dart';
import 'package:uangku/data/models/transaction_with_category.dart';
import 'package:uangku/data/models/transaction_with_details.dart';
import 'package:uangku/data/repositories/transaction_repository.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/transaction/screens/transactions_archive_screen.dart';
import 'package:uangku/features/transaction/widgets/quick_entry_sheet.dart';

import 'transactions_archive_screen_test.mocks.dart';

@GenerateMocks([FirebaseAnalytics, FirebaseCrashlytics])
void main() {
  late MockFirebaseAnalytics mockAnalytics;
  late MockFirebaseCrashlytics mockCrashlytics;
  late MonitoringService monitoringService;

  setUp(() {
    mockAnalytics = MockFirebaseAnalytics();
    mockCrashlytics = MockFirebaseCrashlytics();
    monitoringService = MonitoringService(mockAnalytics, mockCrashlytics);
  });

  /// Fake Wallet Repo
  final fakeWalletRepo = FakeWalletRepository();

  Widget buildTestApp(List<TransactionWithCategory> transactions) {
    return ProviderScope(
      overrides: [
        monitoringServiceProvider.overrideWithValue(monitoringService),
        walletRepositoryProvider.overrideWithValue(fakeWalletRepo),
        transactionRepositoryProvider.overrideWithValue(
          FakeTransactionRepository(transactions: transactions),
        ),
      ],
      child: const MaterialApp(home: TransactionsArchiveScreen()),
    );
  }

  group('TransactionsArchiveScreen', () {
    final t1 = TransactionWithCategory(
      transaction: Transaction(
        id: 1,
        walletId: 1,
        categoryId: 1,
        amount: 50000,
        type: TransactionType.expense,
        note: 'Lunch KFC',
        date: DateTime(2026, 3, 10),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      category: Category(
        id: 1,
        name: 'Food',
        iconCode: '🍔',
        type: TransactionType.expense,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
        date: DateTime(2026, 2, 28),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      category: Category(
        id: 2,
        name: 'Transport',
        iconCode: '🚗',
        type: TransactionType.expense,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    testWidgets('renders sticky headers and transaction list', (tester) async {
      await tester.pumpWidget(buildTestApp([t1, t2]));
      await tester.pumpAndSettle();

      expect(find.text('All Transactions'), findsOneWidget);
      expect(find.text('March 2026'), findsOneWidget);
      expect(find.text('February 2026'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('renders empty state when no transactions exist', (tester) async {
      await tester.pumpWidget(buildTestApp([]));
      await tester.pumpAndSettle();

      expect(find.text('Riwayat kosong. Mulai mencatat hari ini!'), findsOneWidget);
    });

    testWidgets('filters transactions using search bar', (tester) async {
      await tester.pumpWidget(buildTestApp([t1, t2]));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(CupertinoSearchTextField), 'gojek');
      await tester.pumpAndSettle();

      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Food'), findsNothing);
    });

    testWidgets('FAB passes current wallet filter to QuickEntrySheet', (tester) async {
      final wallets = [
        Wallet(
          id: 1,
          name: 'Wallet 1',
          type: WalletType.cash,
          balance: 1000,
          colorHex: 'FFFFFF',
          icon: 'wallet',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Wallet(
          id: 2,
          name: 'Wallet 2',
          type: WalletType.cash,
          balance: 2000,
          colorHex: 'FFFFFF',
          icon: 'wallet',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monitoringServiceProvider.overrideWithValue(monitoringService),
            walletRepositoryProvider.overrideWithValue(fakeWalletRepo),
            transactionRepositoryProvider.overrideWithValue(FakeTransactionRepository(transactions: [])),
            walletsProvider.overrideWith((ref) => Stream.value(wallets)),
          ],
          child: const MaterialApp(home: TransactionsArchiveScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Select "Wallet 2" filter
      await tester.tap(find.text('All Wallets'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wallet 2'));
      await tester.pumpAndSettle();

      // 2. Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // 3. Verify QuickEntrySheet is shown and has Wallet 2 selected
      expect(find.byType(QuickEntrySheet), findsOneWidget);
      
      final sheetFinder = find.byType(QuickEntrySheet);
      expect(find.descendant(of: sheetFinder, matching: find.text('Wallet 2')), findsOneWidget);
    });
  });
}

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
  @override Future<int> createWallet(WalletsCompanion wallet) async => 1;
  @override Future<bool> updateWallet(WalletsCompanion wallet) async => true;
  @override Future<bool> deleteWallet(int id) async => true;
  @override Future<Wallet?> getWalletById(int id) async => null;
}

class FakeTransactionRepository implements TransactionRepository {
  final List<TransactionWithCategory> transactions;
  FakeTransactionRepository({required this.transactions});
  @override Stream<List<TransactionWithCategory>> watchAllTransactions({int? walletId}) => Stream.value(transactions);
  @override Stream<List<TransactionWithCategory>> watchRecentTransactions(int limit) => Stream.value(transactions.take(limit).toList());
  @override Stream<List<TransactionWithCategory>> watchTransactionsByDateRange(DateTime start, DateTime end) => Stream.value(transactions);
  @override Stream<List<CategorySpending>> watchCategorySpending(DateTime month) => Stream.value([]);
  @override Stream<List<DailySpending>> watchDailySpending(DateTime month) => Stream.value([]);
  @override Stream<MonthlySummary> watchMonthlySummary(DateTime month) => Stream.value(MonthlySummary.empty());
  @override Stream<List<TransactionWithCategory>> watchTransactionsByWallet(int walletId) => Stream.value([]);
  @override Future<int> createTransaction(TransactionsCompanion transaction) async => 1;
  @override Future<bool> deleteTransaction(int id) async => true;
  @override Future<void> deleteTransactionAtomic(Transaction transaction) async {}
  @override Future<int> insertTransactionAndUpdateBalance({required TransactionsCompanion transaction, required int walletId, required double balanceDelta}) async => 1;
  @override Future<void> updateTransactionAtomic({required int transactionId, required TransactionsCompanion updated, required int walletId, required double balanceDelta}) async {}
  @override Future<int> performInternalTransfer({required int fromWalletId, required int toWalletId, required double amount, required DateTime date, String note = ''}) async => 1;
  @override Future<List<TransactionWithDetails>> getAllTransactionsWithDetails() async => [];
}
