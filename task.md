# Task: Story 4.1 - Budget Configuration & Storage

## Scope

Allow user to set and update total monthly budget for "Daily Breath" widget, and save it persistently.

## Workflow Status

### Phase 1: Research

- [x] Analyze user story and ACs
- [x] Review database schema and `BudgetService`
- [x] Create Implementation Plan

### Phase 2: Implement

- [x] Add `AppSettings` table to Drift database (`lib/data/tables/app_settings_table.dart`)
- [x] Add `AppSettings` to `AppDatabase` and run build_runner
- [x] Create `AppSettingsRepository` and `monthlyBudgetProvider` (`lib/features/dashboard/logic/settings_providers.dart`)
- [x] Implement `BudgetSettingModal` (`lib/features/dashboard/widgets/budget_setting_modal.dart`)
- [x] Add "Set Budget" button to `DailyBreathBar`
- [x] Integrate `monthlyBudgetProvider` into `dailyBreathProvider` and `BudgetService`
- [x] Write Unit/Widget Tests for new logic and UI

### Phase 4: Verify

- [x] `flutter analyze` passes
- [x] All tests pass
- [x] No lint errors

### Phase 5: Ship

- [x] Git commit
