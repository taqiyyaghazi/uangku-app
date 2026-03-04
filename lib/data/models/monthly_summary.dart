/// Model representing total income and expenses for a specific period.
class MonthlySummary {
  final double totalIncome;
  final double totalExpenses;

  /// Amount saved (Income - Expenses).
  double get totalSavings => totalIncome - totalExpenses;

  /// Percentage of income saved. Returns 0.0 if income is zero or negative.
  double get savingsRate {
    if (totalIncome <= 0) return 0.0;
    final rate = totalSavings / totalIncome;
    return rate > 0 ? rate : 0.0;
  }

  const MonthlySummary({
    required this.totalIncome,
    required this.totalExpenses,
  });

  /// Creates an empty summary.
  factory MonthlySummary.empty() =>
      const MonthlySummary(totalIncome: 0, totalExpenses: 0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlySummary &&
          totalIncome == other.totalIncome &&
          totalExpenses == other.totalExpenses;

  @override
  int get hashCode => totalIncome.hashCode ^ totalExpenses.hashCode;
}
