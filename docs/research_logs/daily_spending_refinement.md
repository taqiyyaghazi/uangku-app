# Research Log: Daily Spending Trend Refinement

## Context

The code review (audit) of the "Daily Spending Trend" feature identified three major issues:

1. Missing mandatory logging in `watchDailySpending`.
2. Embedded gap-filling logic in the repository (should be in a pure function).
3. Duplicated or localized amount formatting logic in the widget.

## Implementation Planning

### 1. Observability (Logging)

Repository: `DriftTransactionRepository.watchDailySpending(DateTime month)`
We need to log:

- Start (Operation: `watch_daily_spending`, Context: `month`)
- Stream updates (Operation: `watch_daily_spending_stream`, Context: `data_count`, `duration`) OR simply log the initial fetch/stream setup.
  Wait, since it's a `Stream`, logging every event might be too much if it changes often, but the mandate says "Every operation entry point MUST include logging".
  I'll log the initial call and wrap the stream events to log (at DEBUG level) when a new event is emitted.

### 2. Logic Extraction

Logic: `lib/features/insights/logic/daily_spending_helper.dart`
Function: `List<DailySpending> fillDailySpendingGaps(List<DailySpending> records, DateTime month)`
This function will handle the business rule of ensuring all days of the month are present.

### 3. Shared Utility

Utility: `lib/shared/utils/currency_formatter.dart`
Method: `CurrencyFormatter.formatCompact(double amount)`
Use: Standardize formatting like '1.2k', '1M' across all charts.

### 4. Pattern Consistency

Moving `_formatAmount` from `DailySpendingLineChart` to `CurrencyFormatter` ensures it is reusable across more charts.
Updating the chart to use the new formatter.

## Verification Strategy

- **Unit Tests**:
  - Test `fillDailySpendingGaps` with various inputs (empty, sparse, full).
  - Test `CurrencyFormatter.formatCompact` with different values (0, <1k, >1M).
  - Ensure `DriftTransactionRepository` still passes tests after changes.
- **Manual Verification**:
  - Check terminal output for logs.
- **Static Analysis**:
  - Run `fvm flutter analyze`.
