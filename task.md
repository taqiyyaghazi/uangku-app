# Task: Story 2.1 - Unified Transaction Entry (Quick-Log)

## Scope

Implement the unified transaction entry flow: teal FAB on dashboard, fast entry bottom sheet with custom numpad, wallet selector, category picker, and atomic transaction write (insert + balance update).

## Workflow Status

### Phase 1: Research

- [x] Analyze user story and ACs
- [x] Review existing repositories/DAOs
- [x] Review UX/tech specs

### Phase 2: Implement

- [ ] Add `insertTransactionAndUpdateBalance` to TransactionRepository
- [ ] Implement atomic write in DriftTransactionRepository
- [ ] Create transaction categories constant
- [ ] Create custom `Numpad` widget
- [ ] Create `QuickEntrySheet` with type toggle, wallet selector, category
- [ ] Wire FAB on DashboardScreen to open QuickEntrySheet
- [ ] Write unit tests for numpad logic
- [ ] Write widget tests for QuickEntrySheet

### Phase 4: Verify

- [ ] `flutter analyze` passes
- [ ] All tests pass
- [ ] No lint errors

### Phase 5: Ship

- [ ] Git commit
