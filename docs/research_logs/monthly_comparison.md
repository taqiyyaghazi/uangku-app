# Research Log: Monthly Comparison

## Context

Goal: Compare total income, expenses, and savings rate of the current month against the previous month.

## Data Structure

### MonthlySummary

```dart
class MonthlySummary {
  final double totalIncome;
  final double totalExpenses;

  double get savings => totalIncome - totalExpenses;
  double get savingsRate => totalIncome > 0 ? (savings / totalIncome) : 0.0;

  MonthlySummary({required this.totalIncome, required this.totalExpenses});
}
```

### MonthlyComparison

```dart
class MonthlyComparison {
  final MonthlySummary current;
  final MonthlySummary previous;

  double get incomeDelta => _calculateDelta(current.totalIncome, previous.totalIncome);
  double get expenseDelta => _calculateDelta(current.totalExpenses, previous.totalExpenses);
  double get savingsDelta => _calculateDelta(current.savings, previous.savings);

  double _calculateDelta(double cur, double prev) {
    if (prev == 0) return 0.0;
    return ((cur - prev) / prev) * 100;
  }

  MonthlyComparison({required this.current, required this.previous});
}
```

## Implementation Plan

### 1. Repository Layer

Need to fetch Income and Expenses for a specific month.
Query: `SELECT SUM(amount) FROM transactions WHERE strftime('%Y-%m', date) = ? GROUP BY type`
Actually, better to use Drift's expression builder.

### 2. Logic Layer (Pure)

The percentage calculation and color logic should be in a helper or the model itself.

### 3. Provider Layer

`watchMonthlyComparisonProvider` will:

1. Watch `watchMonthlySummary(thisMonth)`.
2. Watch `watchMonthlySummary(lastMonth)`.
3. Combine into `MonthlyComparison`.

### 4. UI Layer

`MonthlyComparisonCard` containing:

- Income comparison (Row)
- Expense comparison (Row)
- Savings Rate (Progress bar or highlighted text)

## Design Decisions

- **Savings Rate**: Defined as `(Income - Expense) / Income`. If Income is 0, Savings Rate is 0.
- **Deltas**: If previous month is 0, return 0% or maybe null/inf? Story says handle division by zero. I'll use 0.0 as a safe fallback for comparison if data is missing.

## Context Q&A

- **Q**: How to handle overlapping periods (e.g., month-to-date Comparison)?
- **A**: The story asks for "total income and expenses against the previous month". Usually, this means full previous month vs current month (which is month-to-date if we are in the middle of it). I'll use the current active month from the `InsightsScreen` state.
