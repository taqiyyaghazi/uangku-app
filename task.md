# Task: Implement Story 11.1 (Secure Logout & Local Data Cleansing)

## Phase 2: Implement [x]

- [x] Add `deleteAllLocalData()` to `AppDatabase` in `lib/data/database.dart`.
- [x] Create `AuthService` in `lib/features/auth/services/auth_service.dart`.
  - [x] Implement `performSecureLogout()` logic (wipe DB, wipe Prefs, signOut repo).
- [x] Create `AuthService` unit tests in `test/features/auth/services/auth_service_test.dart`.
- [x] Update `auth_provider.dart` to expose `authServiceProvider`.
- [x] Update UI in `UserAvatarButton` (`lib/features/auth/widgets/user_avatar_button.dart`).
  - [x] Implement confirmation dialog.
  - [x] Implement non-dismissible loading overlay during logout.
  - [x] Call `authService.performSecureLogout()`.

## Phase 3: Integrate / Verify [x]
- [x] Run `flutter test` to ensure new tests and existing tests pass.
- [x] Run `flutter analyze` to ensure code quality.

## Phase 4: Ship
- [ ] Create commit with conventional message.
