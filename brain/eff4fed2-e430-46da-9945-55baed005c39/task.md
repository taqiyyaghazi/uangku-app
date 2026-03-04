# Task: Story 5.2 - Daily Spending Trend

## Phase 1: Research & Planning

- [x] Analyze Story 5.2 and acceptance criteria.
- [x] Research Drift date grouping and gap filling logic.
- [x] Create Research Log.
- [ ] Define `DailySpending` model.

## Phase 2: Implementation (TDD)

- [ ] Add `watchDailySpending(DateTime month)` to `TransactionRepository`.
- [ ] Implement `watchDailySpending` in `DriftTransactionRepository` with gap filling.
- [ ] Create `DailySpendingLineChart` widget using `fl_chart`.
- [ ] Add `watchDailySpendingProvider` to `insights_provider.dart`.
- [ ] Integrate `DailySpendingLineChart` into `InsightsScreen`.

## Phase 3: Integration & UI Polish

- [ ] Format Y-axis labels with abbreviations (k, M).
- [ ] Add tooltips for daily details.
- [ ] Add average spending horizontal line.
- [ ] Ensure Ocean Flow theme consistency.

## Phase 4: Verification

- [ ] Write unit tests for `watchDailySpending` query and gap filling.
- [ ] Write widget tests for `DailySpendingLineChart`.
- [ ] Run `fvm flutter analyze` and fix any issues.
- [ ] Verify coverage for new logic.

## Phase 5: Shipping

- [ ] Commit all changes with `feat(insights): implement daily spending trend chart`.
- [ ] Update `implementation-progress.md`.
