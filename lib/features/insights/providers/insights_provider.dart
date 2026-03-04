import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/models/category_spending.dart';

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
