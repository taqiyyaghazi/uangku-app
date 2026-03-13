# Task: Refactor Category Icon Usage

## Phase 1: Impact Analysis [x]
- [x] Identify affected files: `TransactionItem`, `QuickEntrySheet`, `TransactionDetailSheet`.
- [x] Check `Categories` table definition: `iconCode` stores emoji.
- [x] Check `SearchablePickerSheet` and `PickerItem`: Needs update to support emojis.
- [x] Map the blast radius: `CategoryIconMapper` might become obsolete.

## Phase 2: Incremental Change [x]
- [x] Update `PickerItem` and `SearchablePickerSheet` to support `iconCode` (emoji).
- [x] Refactor `TransactionItem` to use `category.iconCode`.
- [x] Refactor `QuickEntrySheet` to use `category.iconCode`.
- [x] Refactor `TransactionDetailSheet` to use `category.iconCode`.
- [x] Verify each step with existing tests.

## Phase 3: Parity Verification [x]
- [x] Run full test suite.
- [x] Verify UI looks correct with emojis.

## Phase 4: Ship [x]
- [x] Remove `CategoryIconMapper` if unused.
- [x] Commit with `refactor(category): use emoji iconCode from database instead of mapper`
