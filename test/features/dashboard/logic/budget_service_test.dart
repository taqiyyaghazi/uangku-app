import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/dashboard/logic/budget_service.dart';

/// Helper to create a Transaction with minimal boilerplate.
Transaction _tx({
  required double amount,
  required TransactionType type,
  required DateTime date,
}) {
  return Transaction(
    id: 0,
    walletId: 1,
    amount: amount,
    type: type,
    category: 'Test',
    note: '',
    date: date,
    createdAt: date,
  );
}

void main() {
  group('BudgetService.calculate', () {
    test('returns correct daily allowance with no spending', () {
      // March 15, 2026 — 17 remaining days (15th through 31st).
      final state = BudgetService.calculate(
        monthlyLimit: 3000000,
        transactions: [],
        now: DateTime(2026, 3, 15),
      );

      expect(state.monthlyLimit, 3000000);
      expect(state.totalSpentThisMonth, 0);
      expect(state.spentToday, 0);
      expect(state.remainingDays, 17);
      expect(state.dailyAllowance, closeTo(3000000 / 17, 0.01));
      expect(state.remainingBudget, 3000000);
      expect(state.progressRatio, 0.0);
      expect(state.isOverspent, false);
      expect(state.correctionMessage, isNull);
    });

    test('calculates daily allowance after some spending', () {
      final now = DateTime(2026, 3, 20);
      final transactions = [
        _tx(amount: 100000, type: TransactionType.expense, date: now),
        _tx(
          amount: 200000,
          type: TransactionType.expense,
          date: DateTime(2026, 3, 18),
        ),
      ];

      final state = BudgetService.calculate(
        monthlyLimit: 3000000,
        transactions: transactions,
        now: now,
      );

      // Total spent = 300000.
      expect(state.totalSpentThisMonth, 300000);
      expect(state.spentToday, 100000);
      // Remaining budget = 3000000 - 300000 = 2700000.
      // Remaining days = 31 - 20 + 1 = 12.
      expect(state.remainingDays, 12);
      expect(state.dailyAllowance, closeTo(2700000 / 12, 0.01));
      expect(state.remainingBudget, closeTo(2700000, 0.01));
    });

    test('detects overspending and generates correction message', () {
      final now = DateTime(2026, 3, 10);
      // Daily allowance with 0 spent = 3000000 / 22 ≈ 136363.
      // Spend 200000 today — exceeds 136363.
      final transactions = [
        _tx(amount: 200000, type: TransactionType.expense, date: now),
      ];

      final state = BudgetService.calculate(
        monthlyLimit: 3000000,
        transactions: transactions,
        now: now,
      );

      expect(state.isOverspent, true);
      expect(state.correctionMessage, isNotNull);
      expect(state.correctionMessage, contains('Overspent'));
      expect(state.correctionMessage, contains("Tomorrow's budget"));
    });

    test('ignores income transactions when calculating spent', () {
      final now = DateTime(2026, 3, 15);
      final transactions = [
        _tx(amount: 50000, type: TransactionType.expense, date: now),
        _tx(amount: 5000000, type: TransactionType.income, date: now),
      ];

      final state = BudgetService.calculate(
        monthlyLimit: 3000000,
        transactions: transactions,
        now: now,
      );

      expect(state.totalSpentThisMonth, 50000);
      expect(state.spentToday, 50000);
    });

    test('handles last day of month', () {
      final now = DateTime(2026, 3, 31);
      final state = BudgetService.calculate(
        monthlyLimit: 3000000,
        transactions: [],
        now: now,
      );

      expect(state.remainingDays, 1);
      expect(state.dailyAllowance, 3000000);
    });

    test('handles first day of month', () {
      final now = DateTime(2026, 4, 1);
      final state = BudgetService.calculate(
        monthlyLimit: 3000000,
        transactions: [],
        now: now,
      );

      // April has 30 days.
      expect(state.remainingDays, 30);
      expect(state.dailyAllowance, closeTo(3000000 / 30, 0.01));
    });

    test('handles February in leap year', () {
      // 2028 is a leap year.
      final now = DateTime(2028, 2, 1);
      final state = BudgetService.calculate(
        monthlyLimit: 3000000,
        transactions: [],
        now: now,
      );

      expect(state.remainingDays, 29);
    });

    test('progress ratio is clamped at 2.0', () {
      final now = DateTime(2026, 3, 31);
      // Last day, all budget gone, spending huge amount.
      final transactions = [
        _tx(
          amount: 2900000,
          type: TransactionType.expense,
          date: now.subtract(const Duration(days: 1)),
        ),
        _tx(amount: 500000, type: TransactionType.expense, date: now),
      ];

      final state = BudgetService.calculate(
        monthlyLimit: 3000000,
        transactions: transactions,
        now: now,
      );

      expect(state.progressRatio, lessThanOrEqualTo(2.0));
    });

    test('daily allowance is zero when budget is fully consumed', () {
      final now = DateTime(2026, 3, 15);
      final transactions = [
        _tx(amount: 3000000, type: TransactionType.expense, date: now),
      ];

      final state = BudgetService.calculate(
        monthlyLimit: 3000000,
        transactions: transactions,
        now: now,
      );

      expect(state.dailyAllowance, 0.0);
      expect(state.remainingBudget, 0);
    });

    test('handles over-budget month (spent more than limit)', () {
      final now = DateTime(2026, 3, 15);
      final transactions = [
        _tx(amount: 4000000, type: TransactionType.expense, date: now),
      ];

      final state = BudgetService.calculate(
        monthlyLimit: 3000000,
        transactions: transactions,
        now: now,
      );

      expect(state.remainingBudget, -1000000);
      expect(state.dailyAllowance, 0.0);
    });
  });

  group('DateUtils', () {
    test('returns 31 for March', () {
      expect(DateUtils.getDaysInMonth(2026, 3), 31);
    });

    test('returns 28 for Feb non-leap', () {
      expect(DateUtils.getDaysInMonth(2026, 2), 28);
    });

    test('returns 29 for Feb leap year', () {
      expect(DateUtils.getDaysInMonth(2028, 2), 29);
    });

    test('returns 30 for April', () {
      expect(DateUtils.getDaysInMonth(2026, 4), 30);
    });
  });
}
