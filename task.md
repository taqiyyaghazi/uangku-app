# Task: Story 4.3 — Transaction Management (Edit & Delete)

## Data Layer

- [x] Add `deleteTransactionAtomic` and `updateTransactionAtomic` to `TransactionRepository`
- [x] Implement in `DriftTransactionRepository`
- [x] Update fake in `quick_entry_sheet_test.dart`

## Business Logic

- [x] Create `TransactionBalanceLogic` (pure functions for balance deltas)

## UI Components

- [x] Create `TransactionDetailSheet` (view/edit/delete)
- [x] Wire `onTap` in `RecentActivitySection`

## Tests

- [x] `transaction_balance_logic_test.dart`
- [x] `transaction_detail_sheet_test.dart`

## Verification

- [x] `fvm flutter analyze` passes
- [x] `fvm flutter test` — all tests pass
- [x] Commit with `feat(transaction)` format
