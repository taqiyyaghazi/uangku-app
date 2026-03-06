# Research Log: Story 8.1 — Secure Login with Google

## Date: 2026-03-05

---

## Existing Implementation

### Auth Feature Structure (already exists)

```
lib/features/auth/
├── models/
│   └── user_profile.dart          # Domain model (id, name, email, photoUrl)
├── repository/
│   ├── auth_repository.dart       # Abstract interface (authStateChanges, signInWithGoogle, signOut)
│   ├── auth_repository_impl.dart  # FirebaseAuth + GoogleSignIn implementation
│   └── auth_repository_mock.dart  # Mock for tests
└── state/
    └── auth_provider.dart         # Riverpod providers (authRepositoryProvider, authStateProvider)
```

### Dependencies (already in pubspec.yaml)

- `firebase_auth: ^6.2.0`
- `google_sign_in: ^7.2.0`

### Architecture Patterns Used

- **Abstract repository → impl + mock** (consistent across wallet, transaction, category, investment, auth)
- **Riverpod providers** for state management
- **ConsumerWidget** pattern for UI
- **MonitoringService** for observability (analytics + crashlytics)
- **Mockito** for test doubles

---

## Findings

### Bug: MonitoringService Missing Methods

`auth_repository_impl.dart` calls `_monitoring.logInfo(...)` and `_monitoring.logError(...)`,
but `MonitoringService` only has:

- `logEvent({required String name, Map<String, Object>? parameters})`
- `recordError(dynamic exception, StackTrace? stack, {dynamic reason, bool fatal})`
- `log(String message)`

**Fix:** Add `logInfo` and `logError` convenience methods to `MonitoringService`.

### Missing UI Components

1. **AuthWrapper** — gates the app between login screen and main shell based on `authStateChanges`
2. **LoginScreen** — displays Google Sign-In button following Google Branding Guidelines
3. **Profile display** — show user avatar + email in dashboard header area with sign-out option

### Navigation Pattern

Currently: `main.dart → home: MainShell()`
Target: `main.dart → home: AuthWrapper()` → routes to LoginScreen or MainShell

### Test Pattern (from existing tests)

- Co-located in `test/` mirroring `lib/` structure
- Use `@GenerateMocks` + `mockito`
- `ProviderScope.overrides` for widget tests
- AAA pattern (Arrange-Act-Assert)

---

## Implementation Plan

1. Fix `MonitoringService` — add `logInfo`/`logError` methods
2. Create `LoginScreen` widget
3. Create `AuthWrapper` widget
4. Add user profile avatar + sign-out to `DashboardHeader`
5. Wire `AuthWrapper` as root in `main.dart`
6. Write unit tests for all new code
