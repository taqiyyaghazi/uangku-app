# Task: Story 4.4 — Full History & Archive Access

## Data Layer

- [ ] Add `watchAllTransactions()` to `TransactionRepository`
- [ ] Implement in `DriftTransactionRepository`
- [ ] Update fake in `quick_entry_sheet_test.dart` and `transaction_detail_sheet_test.dart`
- [ ] Add `allTransactionsProvider` to `providers.dart`

## Business Logic

- [ ] Create `TransactionGroupingLogic` (pure function for grouping descending transactions by month/year string)
- [ ] Create `transaction_grouping_logic_test.dart`

## UI Components

- [ ] Create `TransactionsArchiveScreen` (search bar, sliver sticky headers, empty state)
- [ ] Create `transactions_archive_screen_test.dart`
- [ ] Wire "See All" button in `RecentActivitySection` to navigate to archive screen

### Verification

- [x] Run unit tests for grouping logic (`fvm flutter test`).
- [x] Create widget tests for `TransactionsArchiveScreen` (`transactions_archive_screen_test.dart`).
- [x] Run widget tests.
- [x] Run full project analysis and tests (`fvm flutter analyze` & `fvm flutter test`).
- [x] Update documentation (Walkthrough).
- [x] Commit changes.
