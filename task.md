# Task: Story 8.1 — Secure Login with Google (Firebase Auth)

## Status: In Progress

## Phase: 2 — Implement

---

## Scope

Implement Google Sign-In with Firebase Auth, including:

- Auth wrapper for routing (login vs dashboard)
- Login screen with Google Sign-In button
- Profile display + sign-out in dashboard header
- Fix `MonitoringService` missing `logInfo`/`logError` methods
- Unit tests for all new code

## Tasks

### Phase 1: Research

- [x] Analyze user story and acceptance criteria
- [x] Review existing auth feature (repository, model, provider)
- [x] Identify missing pieces (UI, auth wrapper, monitoring fix)
- [x] Document findings in research log

### Phase 2: Implement

- [x] **Fix MonitoringService:** Add `logInfo` and `logError` convenience methods
- [x] **Auth Wrapper:** Create `AuthWrapper` widget checking `authStateChanges`
- [x] **Login Screen:** Build login screen with Google Sign-In button
- [x] **Profile in Dashboard Header:** Show user avatar + settings icon, sign-out capability
- [x] **Wire AuthWrapper in main.dart:** Replace `MainShell` as home with `AuthWrapper`
- [x] **Unit Tests:** Auth provider, auth wrapper, login screen, profile display

### Phase 3: Integrate

- [x] Verify Google Sign-In works with Firebase emulator / real device

### Phase 4: Verify

- [x] All lints pass
- [x] All tests pass
- [x] Build succeeds

### Phase 5: Ship

- [x] Git commit with conventional format
