import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/data/models/monthly_summary.dart';
import 'package:uangku/data/repositories/transaction_repository.dart';
import 'package:uangku/features/insights/providers/insights_provider.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/models/category_spending.dart';
import 'package:uangku/data/models/daily_spending.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/models/transaction_with_category.dart';
import 'package:uangku/data/models/transaction_with_details.dart';

class MockTransactionRepository implements TransactionRepository {
  final Map<DateTime, MonthlySummary> summaries = {};

  @override
  Stream<MonthlySummary> watchMonthlySummary(DateTime month) {
    return Stream.value(summaries[month] ?? MonthlySummary.empty());
  }

  @override
  Stream<List<CategorySpending>> watchCategorySpending(DateTime month) =>
      Stream.value([]);
  @override
  Stream<List<DailySpending>> watchDailySpending(DateTime month) =>
      Stream.value([]);
  @override
  Stream<List<TransactionWithCategory>> watchAllTransactions({int? walletId, TransactionType? type}) {
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
  Future<int> createTransaction(TransactionsCompanion transaction) async => 0;
  @override
  Future<bool> deleteTransaction(int id) async => true;
  @override
  Future<void> deleteTransactionAtomic(Transaction transaction) async {}
  @override
  Future<int> insertTransactionAndUpdateBalance({
    required TransactionsCompanion transaction,
    required int walletId,
    required double balanceDelta,
  }) async => 0;
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
  }) async => 0;

  @override
  Future<List<TransactionWithDetails>> getAllTransactionsWithDetails() async =>
      [];
}

void main() {
  test('watchMonthlyComparisonProvider combines data correctly', () async {
    final mockRepo = MockTransactionRepository();
    final now = DateTime(2024, 3, 1);
    final previous = DateTime(2024, 2, 1);

    mockRepo.summaries[now] = const MonthlySummary(
      totalIncome: 1000,
      totalExpenses: 500,
    );
    mockRepo.summaries[previous] = const MonthlySummary(
      totalIncome: 800,
      totalExpenses: 400,
    );

    final container = ProviderContainer(
      overrides: [transactionRepositoryProvider.overrideWithValue(mockRepo)],
    );
    addTearDown(container.dispose);

    container.read(selectedMonthProvider.notifier).setMonth(now);

    final sub = container.listen(
      watchMonthlyComparisonProvider,
      (prev, next) {},
    );

    // Initial state: loading
    expect(sub.read().isLoading, true);

    // Wait for stream emissions
    final result = await container.read(watchMonthlyComparisonProvider.future);

    expect(result.current.totalIncome, 1000);
    expect(result.previous.totalIncome, 800);
    expect(result.incomeDelta, 25.0); // (1000-800)/800 = 25%
  });
}
