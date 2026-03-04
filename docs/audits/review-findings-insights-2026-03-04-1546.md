# Code Audit: Insights

Date: 2026-03-04
Reviewer: AI Agent (fresh context)

## Summary

- **Files reviewed:** 14 (7 source files, 7 test files)
- **Issues found:** 2 (0 critical, 1 major, 1 minor, 0 nit)

## Critical Issues

None.

## Major Issues

- [ ] **[OBS]** Stream errors in `watchMonthlyComparisonProvider` are forwarded directly to the UI without local logging or structured context metadata. A logger should capture the error before forwarding downstream. — [providers/insights_provider.dart:76](file:///Users/taqiyyaghazi/Documents/uangku/lib/features/insights/providers/insights_provider.dart)

## Minor Issues

- [ ] **[SEC]/[DATA]** Error messages in the `when/error` handlers show raw `$err` output to the user, potentially exposing internal implementation details or stack traces to end users. Consider generic user-friendly text. — [screens/insights_screen.dart:98](file:///Users/taqiyyaghazi/Documents/uangku/lib/features/insights/screens/insights_screen.dart)

## Verification Results

- Lint: PASS
- Tests: PASS (All tests passed)
- Build: PASS
- Coverage: 86.55% (354/409 lines)

## Rules Applied

- Security Mandate @security-mandate.md
- Logging and Observability Mandate @logging-and-observability-mandate.md
