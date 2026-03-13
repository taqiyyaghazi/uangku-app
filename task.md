# Task: Fix Firebase Analytics AssertionError in Wallet Filter

## Phase 1: Diagnose [x]
- [x] Identify the bug: `AssertionError` because `bool` is passed to `is_all_wallets` in Firebase Analytics.
- [x] Locate affected code: `lib/features/transaction/screens/transactions_archive_screen.dart`.
- [x] Define fix: Convert `bool` to `int` (1/0) or `String` in `logEvent` parameters.

## Phase 2: Fix + Test (TDD) [x]
- [x] Write a failing test that reproduces the bug (verifies parameter types).
- [x] Apply the minimal fix to make the test pass.
- [x] Verify existing tests still pass.

## Phase 3: Verify + Ship [x]
- [x] Run full validation suite (254 tests passed).
- [x] Commit with `fix(transaction): convert bool to string/int for analytics parameter`
