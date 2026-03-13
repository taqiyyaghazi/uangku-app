# Task: Searchable Picker for Categories & Wallets

## Phase 1: Research [x]
- [x] Analyze current implementation of `QuickEntrySheet` and selection chips.
- [x] Define `SearchablePickerSheet` widget structure.
- [x] Document research findings in `docs/research_logs/9.2-searchable-picker.md`.

## Phase 2: Implement [x]
- [x] Create `SearchablePickerSheet` widget.
- [x] Update `QuickEntrySheet` to use the new picker.
- [x] Update `TransactionDetailSheet` to use the new picker.
- [x] Implement highlight matching text logic.
- [x] Add "Add New Category" empty state logic.
- [x] Add "Recent Items" logic for categories based on `recentTransactionsProvider`.
- [x] Add widget tests for the picker and updated sheets.

## Phase 3: Integrate [x]
- [x] Verify integration with `TransactionDetailSheet`.
- [x] Ensure keyboard focus and auto-close behavior.

## Phase 4: Verify [x]
- [x] Run all tests (260 tests passed).
- [x] All linters pass.

## Phase 5: Ship [x]
- [x] Commit changes with conventional format.
