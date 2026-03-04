import 'monthly_summary.dart';

/// Model representing a comparison between two [MonthlySummary] periods.
class MonthlyComparison {
  final MonthlySummary current;
  final MonthlySummary previous;

  const MonthlyComparison({required this.current, required this.previous});

  /// Percentage change in income.
  double get incomeDelta =>
      _calculateDelta(current.totalIncome, previous.totalIncome);

  /// Percentage change in expenses.
  double get expenseDelta =>
      _calculateDelta(current.totalExpenses, previous.totalExpenses);

  /// Percentage change in savings.
  double get savingsDelta =>
      _calculateDelta(current.totalSavings, previous.totalSavings);

  double _calculateDelta(double cur, double prev) {
    if (prev <= 0) return 0.0;
    return ((cur - prev) / prev) * 100;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyComparison &&
          current == other.current &&
          previous == other.previous;

  @override
  int get hashCode => current.hashCode ^ previous.hashCode;
}
