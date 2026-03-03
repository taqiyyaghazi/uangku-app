# Story 4.5: Transaction Memo & Contextual Notes

## Implementation

- [ ] Add note TextField to `QuickEntrySheet` (between category and numpad)
- [ ] Include `note` in `TransactionsCompanion` inside `_onSave`
- [ ] Show note snippet in `TransactionItem` subtitle (italic, grey, 1 line)
- [ ] Add `_noteController` to `TransactionDetailSheet` edit mode
- [ ] Include `note` in `TransactionsCompanion` inside `_onSaveEdit`

## Testing

- [ ] Update widget tests for QuickEntrySheet
- [ ] Update widget tests for TransactionDetailSheet

## Verification

- [ ] `fvm flutter analyze` — zero issues
- [ ] `fvm flutter test` — all pass
- [ ] Commit
