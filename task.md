# Task: Quick Fix - Widget Test Pending Timer After Riverpod 3 Upgrade

## Scope

Fix "A Timer is still pending" error in `test/widget_test.dart` caused by
Drift `StreamQueryStore.markAsClosed` scheduling a timer during Riverpod 3
provider disposal.

## Workflow Status

### Phase 1: Diagnose

- [x] Root cause: Riverpod 3 disposes `dailyBreathProvider` → closes Drift stream → `StreamQueryStore.markAsClosed` schedules zero-duration timer → Flutter test framework asserts `!timersPending`.
- [x] Fix: Override `dailyBreathProvider` (and any other real-Drift stream providers) in the test with fake stream values, so no Drift streams are active.

### Phase 2: Fix + Test

- [ ] Override `dailyBreathProvider` with a fake `Stream.value(...)` in `widget_test.dart`
- [ ] Verify `fvm flutter test test/widget_test.dart` passes

### Phase 3: Verify + Ship

- [ ] `fvm flutter analyze` passes
- [ ] Full `fvm flutter test` passes
- [ ] Commit with `fix(test): ...`
