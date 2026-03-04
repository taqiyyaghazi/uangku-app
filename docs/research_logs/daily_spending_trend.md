# Research Log - Daily Spending Trend (Story 5.2)

## Context

Goal: Implement a line chart showing daily spending trends across a selected month.
Feature: Insights & Analytics.

## Technical Analysis

### Data Modeling

A new model `DailySpending` is required to hold the date and the aggregated amount.

```dart
class DailySpending {
  final DateTime date;
  final double totalAmount;

  DailySpending({required this.date, required this.totalAmount});
}
```

### Database Aggregation (Drift/SQLite)

We need to aggregate transactions by day, filtered by month and `TransactionType.expense`.
Drift provides the `.date` property on `DateTimeColumn` which translates to `DATE(date)` in SQL (YYYY-MM-DD).

```dart
final dayExpr = transactions.date.date;
final amountSum = transactions.amount.sum();

final query = selectOnly(transactions)
  ..addColumns([dayExpr, amountSum])
  ..where(transactions.date.isBiggerOrEqualValue(startOfMonth) &
          transactions.date.isSmallerOrEqualValue(endOfMonth) &
          transactions.type.equals(TransactionType.expense.name))
  ..groupBy([dayExpr]);
```

### Gap Filling Logic

Database queries only return days with transactions. To prevent the line chart from "skipping" days (Acceptance Criteria AC #2), we must fill missing days with 0.0.
Implementation plan:

1. Fetch aggregated data for the month.
2. Calculate number of days in the month.
3. Iterate from 1st to last day, matching with database results or setting 0.0.

### UI Implementation (fl_chart)

`LineChart` will be used.

- **X-Axis**: Day numbers (1 to 31).
- **Y-Axis**: Amounts, formatted with abbreviations (K, M).
- **Styling**: `isCurved: true`, area gradient, Ocean Flow color palette.
- **Average Line**: Use `ExtraLinesData` in `LineChartData` for the horizontal dashed line.

## Existing Patterns

- Follows the pattern of `watchCategorySpending` in `DriftTransactionRepository`.
- Follows the pattern of `SpendingPieChart` in the same feature folder.

## References

- acceptance criteria from `docs/user-stories/5.2-daily-spending-trend.md`.
- `fl_chart` documentation for `LineChart` tooltips and styling.
