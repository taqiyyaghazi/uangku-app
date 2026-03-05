# Epic 7.4: Stability & Usage Monitoring (Firebase SDK)

## Phase 1: Research

- [x] Analyze request and project context.
- [x] Search for Firebase (Crashlytics/Analytics) integration patterns in Flutter.
- [x] Document findings in `docs/research_logs/7.4-stability-and-usage-monitoring.md`.
- [x] Define implementation plan in `task.md`.

## Phase 2: Implement

- [x] Add dependencies to `pubspec.yaml` (firebase_core, firebase_analytics, firebase_crashlytics).
- [x] Configure Android platform settings (build.gradle.kts).
- [x] Configure iOS platform settings (Native Plist found).
- [x] Implement Firebase initialization in `main.dart`.
- [x] Implement global error handling for Crashlytics in `main.dart`.
- [x] Create `MonitoringService` (renamed from AnalyticsService) for custom event tracking and crash reporting.
- [x] Integrate screen tracking with NavigatorObserver.
- [x] Instrument Epic 7 features (Export, Filter, Edit) with custom events using `MonitoringService`.

## Phase 3: Integrate

- [x] Verify Firebase connection (using mocks in unit tests).
- [x] Test `MonitoringService` with unit tests (mocking FirebaseAnalytics/FirebaseCrashlytics).
- [x] Test Crashlytics error reporting in `ExportNotifier` and `TransactionDetailSheet` (using mocks).

## Phase 4: Verify

- [x] Run `fvm flutter analyze` (Clean analysis except for false-positive RegExp deprecation).
- [x] Run all unit tests with `fvm flutter test` (210/210 passed).
- [x] Update documentation (ADR 0001 created, User Story 7.4 updated).

## Phase 5: Ship

- [x] Git commit with conventional format.
- [x] Finalize `task.md`.
