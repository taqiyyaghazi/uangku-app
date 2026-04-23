import 'dart:math';

import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/dashboard/models/budget_state.dart';
import 'package:uangku/shared/utils/currency_formatter.dart';

/// Pure business logic for the "Daily Breath" budgeting algorithm.
///
/// All methods are pure functions (input → output, no side effects).
/// I/O (fetching transactions) is handled by the provider layer.
class BudgetService {
  BudgetService._();

  /// Computes the [BudgetState] from a monthly limit and a list of
  /// transactions for the current month.
  ///
  /// [monthlyLimit] — the user's monthly spending cap.
  /// [transactions] — all transactions in the current calendar month.
  /// [now] — injectable for testability (defaults to DateTime.now).
  /// [isHidden] — whether to mask currency values.
  static BudgetState calculate({
    required double monthlyLimit,
    required List<Transaction> transactions,
    DateTime? now,
    bool isHidden = false,
  }) {
    final today = now ?? DateTime.now();

    // ── Compute totals ─────────────────────────────────────────────
    final totalSpentThisMonth = _totalExpenses(transactions);
    final spentToday = _totalExpensesOnDate(transactions, today);

    // ── Remaining days (including today) ────────────────────────────
    final daysInMonth = DateUtils.getDaysInMonth(today.year, today.month);
    final remainingDays = max(1, daysInMonth - today.day + 1);

    // ── Daily allowance ────────────────────────────────────────────
    final remainingBudget = monthlyLimit - totalSpentThisMonth;
    final dailyAllowance = remainingBudget > 0
        ? remainingBudget / remainingDays
        : 0.0;

    // ── Progress ratio (how much of today's allowance is consumed) ──
    final progressRatio = dailyAllowance > 0
        ? min(2.0, spentToday / dailyAllowance)
        : (spentToday > 0 ? 2.0 : 0.0);

    final isOverspent = dailyAllowance > 0 && spentToday > dailyAllowance;

    // ── Overspend correction message ───────────────────────────────
    String? correctionMessage;
    if (isOverspent) {
      final overspend = spentToday - dailyAllowance;
      final tomorrowRemainingDays = max(1, remainingDays - 1);
      final tomorrowAllowance =
          (remainingBudget - spentToday) / tomorrowRemainingDays;
      final adjustedTomorrow = max(0.0, tomorrowAllowance);

      correctionMessage =
          'Overspent ${CurrencyFormatter.format(overspend, isHidden: isHidden)} today. '
          "Tomorrow's budget: ${CurrencyFormatter.format(adjustedTomorrow, isHidden: isHidden)}.";
    }

    return BudgetState(
      monthlyLimit: monthlyLimit,
      totalSpentThisMonth: totalSpentThisMonth,
      spentToday: spentToday,
      dailyAllowance: dailyAllowance,
      remainingDays: remainingDays,
      remainingBudget: remainingBudget,
      progressRatio: progressRatio,
      isOverspent: isOverspent,
      correctionMessage: correctionMessage,
    );
  }

  /// Sums all expense amounts from [transactions].
  static double _totalExpenses(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Sums expenses that occurred on [date] (same year/month/day).
  static double _totalExpensesOnDate(
    List<Transaction> transactions,
    DateTime date,
  ) {
    return transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.year == date.year &&
              t.date.month == date.month &&
              t.date.day == date.day,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}

/// Extension on DateTime utilities needed by [BudgetService].
///
/// Uses the standard formula for days in month (handles leap years).
class DateUtils {
  DateUtils._();

  /// Returns the number of days in the given [month] of [year].
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
