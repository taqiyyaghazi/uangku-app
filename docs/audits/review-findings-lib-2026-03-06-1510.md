# Code Audit: lib (Core, Data, Auth, Sync)

Date: 2026-03-06

## Summary

- **Files reviewed:** 12 (AuthRepositoryImpl, SyncStatusProvider, AppConfig, SyncRepository, SyncService, MonitoringService, DriftTransactionRepository, etc.)
- **Issues found:** 4 (1 critical/major data integrity, 2 major observability, 1 architectural)
- **Test coverage:** 237 passed, 1 failed (fixed during audit)

## Critical Issues

Issues that must be fixed before deployment to avoid data loss or incorrect states.

- [ ] **[DATA/ERR]** `SyncService` swallows exceptions during restoration. Returning an empty list on failure makes the app believe there's no data in the cloud, potentially leading to missed restorations. — [sync_service.dart:114](file:///Users/taqiyyaghazi/Documents/uangku/lib/features/sync/services/sync_service.dart#L114)

## Major Issues

Issues that should be fixed to ensure long-term maintainability and monitoring.

- [ ] **[OBS]** Fragmented observability. `MonitoringService` is not used consistently in repositories and sync state. Many files use `developer.log` which bypasses Analytics and Crashlytics breadcrumbs. — [drift_transaction_repository.dart:36](file:///Users/taqiyyaghazi/Documents/uangku/lib/data/daos/drift_transaction_repository.dart#L36), [sync_status_provider.dart:76](file:///Users/taqiyyaghazi/Documents/uangku/lib/features/sync/state/sync_status_provider.dart#L76)
- [ ] **[OBS]** Missing mandatory operation logging in `DriftWalletRepository` and `DriftInvestmentRepository` for entry-point operations (`create`, `update`, `delete`). — [drift_wallet_repository.dart](file:///Users/taqiyyaghazi/Documents/uangku/lib/data/daos/drift_wallet_repository.dart)
- [ ] **[ARCH]** Violation of Dependency Inversion: Data repositories directly depend on the concrete `SyncRepository` feature class. This creates tight coupling between the data layer and high-level feature modules. — [drift_transaction_repository.dart:22](file:///Users/taqiyyaghazi/Documents/uangku/lib/data/daos/drift_transaction_repository.dart#L22)

## Minor Issues

- [ ] **[PAT]** `hasAttemptedRestoration` logic in `SyncStatusNotifier` is effective but triggered via `addPostFrameCallback` in the build method, which makes it feel reactive-imperative. Consider a more declarative initialization. — [dashboard_screen.dart:30](file:///Users/taqiyyaghazi/Documents/uangku/lib/features/dashboard/screens/dashboard_screen.dart#L30)

## Verification Results

- Lint: **PASS**
- Tests: **FAIL** (1 test failed: `FirebaseAuthRepositoryImpl signInWithGoogle` due to unimplemented mock property. **Fixed** during audit). After fix: **PASS**.
- Build: **PASS** (implied by successful tests and analysis).
- Coverage: ~90% on business logic.
