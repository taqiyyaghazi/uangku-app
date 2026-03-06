# Story 8.2: Database Mapping to Firestore (Cloud Sync)

## Completed Tasks

### Phase 2: Implement

- [x] **Schema Updates:** Add `updatedAt` to `Transactions` and `Categories` tables
- [x] **Code Generation:** Run Drift build runner for updated schema (`v6`)
- [x] **Data Mapping:** Create `FirestoreMapper` to convert Drift models to/from Firestore Maps
- [x] **Sync Service:** Create `SyncService` for direct Firestore collection interactions
- [x] **Sync Repository:** Implement `SyncRepository` combining `DriftDatabase` + `SyncService`
- [x] **Feature Integration:** Integrated `SyncRepository` into all Drift repositories
- [x] **Dependency Injection:** Updated `providers.dart` to wire up the sync layer

### Phase 3: Integrate

- [x] Write and verify unit tests for `SyncRepository` and `FirestoreMapper`
- [x] Fix regressions in existing tests due to schema changes

### Phase 4: Verify

- [x] All lints pass
- [x] All tests pass (232 tests)
- [x] Build succeeds

### Phase 5: Ship

- [x] Create walkthrough.md
- [ ] Git commit with conventional format
