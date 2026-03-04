# Task: Insights Audit Fixes

## Scope

Address the findings from the code audit performed on the Insights feature (docs/audits/review-findings-insights-2026-03-04-1546.md).

## Tasks

- [x] Fix Major Issue (Observability): Add structured logging to `watchMonthlyComparisonProvider` in `lib/features/insights/providers/insights_provider.dart` to capture stream errors rather than blindly forwarding them to the UI. Since there isn't an existing logger, use `dart:developer` `log` or create a simple structured logger wrapper to fulfill the mandate.
- [x] Fix Minor Issue (Security/Data): In `lib/features/insights/screens/insights_screen.dart`, replace raw `$err` output in the `when/error` handlers with generic, user-friendly text to prevent exposing internal stack traces or implementation details.

## App Configuration

- [x] Update Bundle ID and App Name using `rename` package.
- [x] Configure and generate launcher icons using `flutter_launcher_icons`.
