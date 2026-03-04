import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/data/models/monthly_comparison.dart';
import 'package:uangku/data/models/monthly_summary.dart';
import 'package:uangku/features/insights/logic/comparison_helper.dart';

void main() {
  group('MonthlySummary Tests', () {
    test('savings and savingsRate calculation', () {
      const summary = MonthlySummary(totalIncome: 10000, totalExpenses: 7000);
      expect(summary.totalSavings, 3000);
      expect(summary.savingsRate, 0.3);
    });

    test('savingsRate handles zero income', () {
      const summary = MonthlySummary(totalIncome: 0, totalExpenses: 7000);
      expect(summary.savingsRate, 0.0);
    });

    test('savingsRate handles negative savings', () {
      const summary = MonthlySummary(totalIncome: 100, totalExpenses: 150);
      expect(summary.savingsRate, 0.0);
    });
  });

  group('MonthlyComparison Tests', () {
    test('delta calculations', () {
      const current = MonthlySummary(totalIncome: 12000, totalExpenses: 8000);
      const previous = MonthlySummary(totalIncome: 10000, totalExpenses: 10000);
      final comparison = MonthlyComparison(
        current: current,
        previous: previous,
      );

      expect(comparison.incomeDelta, 20.0); // (12-10)/10 * 100
      expect(comparison.expenseDelta, -20.0); // (8-10)/10 * 100
    });

    test('delta handles zero previous month', () {
      const current = MonthlySummary(totalIncome: 12000, totalExpenses: 8000);
      const previous = MonthlySummary(totalIncome: 0, totalExpenses: 0);
      final comparison = MonthlyComparison(
        current: current,
        previous: previous,
      );

      expect(comparison.incomeDelta, 0.0);
      expect(comparison.expenseDelta, 0.0);
    });
  });

  group('ComparisonHelper Tests', () {
    test('getExpenseMessage based on delta', () {
      expect(ComparisonHelper.getExpenseMessage(-6), contains("Luar biasa"));
      expect(ComparisonHelper.getExpenseMessage(-2), contains("Bagus"));
      expect(ComparisonHelper.getExpenseMessage(6), contains("Waspada"));
      expect(
        ComparisonHelper.getExpenseMessage(2),
        contains("sedikit meningkat"),
      );
      expect(ComparisonHelper.getExpenseMessage(0), contains("stabil"));
    });
  });
}
