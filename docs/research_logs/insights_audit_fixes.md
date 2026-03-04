# Research Log: Insights Audit Fixes

## Context

A code audit identified two issues in the Insights feature:

1. Missing observability for Stream errors in `watchMonthlyComparisonProvider`.
2. Raw `$err` output in `InsightsScreen` UI error handlers, potentially leaking internal details.

## Implementation Plan

### 1. Observability inside `watchMonthlyComparisonProvider`

- **File:** `lib/features/insights/providers/insights_provider.dart`
- **Problem:** The `onError: controller.addError` callback blindly forwards errors without logging them locally.
- **Solution:** We need to intercept the error, log it with context (e.g., operation name, error details), and then optionally forward it or handle it gracefully.
- **Logging approach:** Since the project doesn't have a third-party logging library listed in `pubspec.yaml`, we will use `dart:developer`'s `log` function which supports structured error and stack trace capturing.

```dart
import 'dart:developer' as developer;

// Inside the stream subscription...
onError: (Object error, StackTrace stackTrace) {
  developer.log(
    'Failed to fetch monthly summary for comparison',
    name: 'insights_provider',
    error: error,
    stackTrace: stackTrace,
  );
  controller.addError(error, stackTrace);
}
```

### 2. User-Friendly Error Messages in UI

- **File:** `lib/features/insights/screens/insights_screen.dart`
- **Problem:** The `when(error: (err, stack) => Text('Gagal memuat: $err'))` handlers display raw exception strings.
- **Solution:** Use a generic message like `"Terjadi kesalahan saat memuat data."` or mapping specific errors where applicable.

```dart
error: (err, stack) => const Center(
    child: Text('Terjadi kesalahan saat memuat data. Silakan coba lagi nanti.'),
),
```

By completing these simple modifications, the codebase will adhere to the Observability and Security mandates defined in the project's rules.
