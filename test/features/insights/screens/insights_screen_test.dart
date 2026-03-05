import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/models/category_spending.dart';
import 'package:uangku/data/models/daily_spending.dart';
import 'package:uangku/data/models/transaction_with_category.dart';
import 'package:uangku/data/repositories/transaction_repository.dart';
import 'package:uangku/data/models/monthly_summary.dart';
import 'package:uangku/features/insights/screens/insights_screen.dart';

class FakeTransactionRepository implements TransactionRepository {
  final List<CategorySpending> mockSpending;

  FakeTransactionRepository({required this.mockSpending});

  @override
  Stream<List<CategorySpending>> watchCategorySpending(DateTime month) =>
      Stream.value(mockSpending);

  @override
  Stream<List<DailySpending>> watchDailySpending(DateTime month) =>
      Stream.value([]);

  @override
  Stream<MonthlySummary> watchMonthlySummary(DateTime month) =>
      Stream.value(MonthlySummary.empty());

  @override
  Stream<List<TransactionWithCategory>> watchAllTransactions({int? walletId}) {
    return Stream.value([]);
  }

  @override
  Stream<List<TransactionWithCategory>> watchRecentTransactions(int limit) =>
      Stream.value([]);

  @override
  Stream<List<TransactionWithCategory>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) => Stream.value([]);

  @override
  Stream<List<TransactionWithCategory>> watchTransactionsByWallet(
    int walletId,
  ) => Stream.value([]);

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
  }) async => 1;
}

void main() {
  Widget buildTestApp(List<CategorySpending> spending) {
    return ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(
          FakeTransactionRepository(mockSpending: spending),
        ),
      ],
      child: const MaterialApp(home: InsightsScreen()),
    );
  }

  group('InsightsScreen Widget Tests', () {
    testWidgets('renders Insights title and current month', (tester) async {
      await tester.pumpWidget(buildTestApp([]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Insights'), findsOneWidget);

      final now = DateTime.now();
      final monthName = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ][now.month - 1];

      expect(find.text('$monthName ${now.year}'), findsOneWidget);
    });

    testWidgets('displays charts and legends when data is available', (
      tester,
    ) async {
      final mockSpending = [
        CategorySpending(
          categoryName: 'Food',
          totalAmount: 100000,
          colorCode: '#FF0000',
        ),
      ];

      await tester.pumpWidget(buildTestApp(mockSpending));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Pengeluaran Berdasarkan Kategori'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Rp 100.000'), findsOneWidget);
    });

    testWidgets('shows empty state when no data returned', (tester) async {
      await tester.pumpWidget(buildTestApp([]));
      await tester.pump();
      // Wait for multiple stream emissions and provider updates
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Belum ada data untuk periode ini.'), findsOneWidget);
    });
  });
}
