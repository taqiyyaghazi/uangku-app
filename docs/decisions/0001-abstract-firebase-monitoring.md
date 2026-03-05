# 0001. Abstracting Firebase Monitoring Services

**Date:** 2025-03-05
**Status:** Accepted

## Context

The application needs both crash reporting (Firebase Crashlytics) and usage analytics (Firebase Analytics). Initially, a simple `AnalyticsService` was proposed, but it only covered analytics and was tightly coupled to the Firebase SDK in its public interface in some places (though using providers).

We need a central service that:

1. Handles both Analytics and Crashlytics.
2. Provides a clean abstraction for testability without requiring a running Firebase instance in unit tests.
3. Decouples the rest of the application from specific third-party SDK signatures.

## Options Considered

### Option A: Use Firebase SDKs directly

- **Pros:** No extra code, immediate access to all features.
- **Cons:** Impossible to unit test logic that triggers events/errors, hard to replace SDKs later, logic duplication for error handling.
- **Effort:** Low

### Option B: Separate services for Analytics and Crashlytics

- **Pros:** Clear separation of concerns.
- **Cons:** More boilerplate, often both are needed in the same place (e.g., error in analytics reporting), twice the provider overhead.
- **Effort:** Medium

### Option C: Combined `MonitoringService` abstraction (Recommended)

- **Pros:** Unified API for observability, easy to mock both concerns at once, follows DIP (Dependency Inversion Principle).
- **Cons:** Slightly more initial boilerplate for the abstraction layer.
- **Effort:** Medium

## Decision

We chose **Option C** because it strikes the best balance between testability and developer ergonomics. By renaming `AnalyticsService` to `MonitoringService`, we correctly signal that it covers more than just usage tracking.

## Consequences

### Positive

- Unit tests can verify that events and errors are handled correctly using `MockMonitoringService`.
- Centralized logic for adding custom logs to both analytics and crash reports.
- Easier to swap monitoring providers in the future.

### Negative

- Developers must use the `MonitoringService` API instead of calling `FirebaseAnalytics` directly.

### Risks

- Over-abstraction could hide specific useful features of the underlying SDKs.
- Mitigation: Expose specific parameters and configurations through the service as needed.

## Related

- Architectural Patterns @architectural-pattern.md
- Core Design Principles @core-design-principles.md
- Logging and Observability Mandate @logging-and-observability-mandate.md
