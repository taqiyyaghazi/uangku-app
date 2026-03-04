import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/models/category_spending.dart';
import 'package:uangku/data/models/daily_spending.dart';
import 'package:uangku/data/models/monthly_comparison.dart';
import 'package:uangku/data/models/monthly_summary.dart';

/// Notifier to manage the currently selected month.
class SelectedMonth extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  void setMonth(DateTime newMonth) {
    state = DateTime(newMonth.year, newMonth.month, 1);
  }
}

/// Provider for the currently selected month in the Insights screen.
final selectedMonthProvider =
    NotifierProvider.autoDispose<SelectedMonth, DateTime>(SelectedMonth.new);

/// Provider that watches the category spending for the currently selected month.
final watchCategorySpendingProvider =
    StreamProvider.autoDispose<List<CategorySpending>>((ref) {
      final selectedMonth = ref.watch(selectedMonthProvider);
      final repo = ref.watch(transactionRepositoryProvider);

      return repo.watchCategorySpending(selectedMonth);
    });

/// Provider that watches the daily spending trend for the currently selected month.
final watchDailySpendingProvider =
    StreamProvider.autoDispose<List<DailySpending>>((ref) {
      final selectedMonth = ref.watch(selectedMonthProvider);
      final repo = ref.watch(transactionRepositoryProvider);

      return repo.watchDailySpending(selectedMonth);
    });

/// Provider for monthly summary for a specific month.
final watchMonthlySummaryProvider = StreamProvider.autoDispose
    .family<MonthlySummary, DateTime>((ref, month) {
      final repo = ref.watch(transactionRepositoryProvider);
      return repo.watchMonthlySummary(month);
    });

/// Combined provider for monthly comparison.
final watchMonthlyComparisonProvider =
    StreamProvider.autoDispose<MonthlyComparison>((ref) {
      final selectedMonth = ref.watch(selectedMonthProvider);
      final previousMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month - 1,
      );
      final repo = ref.watch(transactionRepositoryProvider);

      final controller = StreamController<MonthlyComparison>();
      MonthlySummary? current;
      MonthlySummary? previous;

      void update() {
        if (current != null && previous != null) {
          controller.add(
            MonthlyComparison(current: current!, previous: previous!),
          );
        }
      }

      void handleError(Object error, StackTrace stackTrace) {
        developer.log(
          'Failed to fetch monthly summary for comparison',
          name: 'InsightsProvider',
          error: error,
          stackTrace: stackTrace,
        );
        controller.addError(error, stackTrace);
      }

      final sub1 = repo.watchMonthlySummary(selectedMonth).listen((s) {
        current = s;
        update();
      }, onError: handleError);

      final sub2 = repo.watchMonthlySummary(previousMonth).listen((s) {
        previous = s;
        update();
      }, onError: handleError);

      ref.onDispose(() {
        sub1.cancel();
        sub2.cancel();
        controller.close();
      });

      return controller.stream;
    });
