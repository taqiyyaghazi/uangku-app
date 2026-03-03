# Task: Quick Fix - AppSettings Table Missing

## Scope

Fix "no such table: app_settings" error when saving budget on an existing database by adding migration logic.

## Workflow Status

### Phase 1: Diagnose

- [x] Identify bug: `databaseVersion` is 1, `onUpgrade` doesn't create `appSettings` table.
- [x] Define fix: Bump `databaseVersion` to 2, add `m.createTable(appSettings)` inside `onUpgrade`.

### Phase 2: Fix + Test

- [x] Update `AppConstants.databaseVersion` to 2.
- [x] Update `AppDatabase.migration.onUpgrade` to create `appSettings`.
- [x] Run `flutter test` to ensure existing tests pass.

### Phase 3: Verify + Ship

- [x] `flutter analyze` passes
- [x] Git commit with `fix(database): add migration for app_settings table`
