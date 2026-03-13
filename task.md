# Task: Refactor Wallet Filter to SearchablePickerSheet

## Phase 1: Impact Analysis [x]
- [x] Identify affected files: `TransactionsArchiveScreen`.
- [x] Review current implementation: Horizontal `ListView` of `ChoiceChip`s.
- [x] Verify `SearchablePickerSheet` capability: Generic enough for wallets.

## Phase 2: Incremental Change [x]
- [x] Update `TransactionsArchiveScreen` imports.
- [x] Implement `_showWalletFilterPicker` helper method.
- [x] Replace `ListView` of chips with a picker trigger (e.g., an `ActionChip`).
- [x] Verify functionality: filter should update correctly.

## Phase 3: Parity Verification [x]
- [x] Run full test suite (253 tests passed).
- [x] Verify UI behavior manually.

## Phase 4: Ship [x]
- [x] Commit with `refactor(transaction): use SearchablePickerSheet for wallet filter in archive`
