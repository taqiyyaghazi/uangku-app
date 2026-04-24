# Research Log: AI Accuracy Tracking

## Context
Implementation of AI accuracy tracking via Firebase Analytics for "Uangku" app.
This follows the "Daily Breath" engine's goal of improving AI efficiency by tracking mismatch data between AI suggestions and user final choices.

## Tech Stack
- **Firebase Analytics**: Event logging.
- **MonitoringService**: Wrapper class for consistency.
- **Flutter (Riverpod)**: State management and DI.

## Findings

### 1. MonitoringService
Located at `lib/core/services/monitoring_service.dart`.
It already wraps `FirebaseAnalytics`. I should add a specific method for AI accuracy tracking to ensure consistency and silent error handling.

### 2. Trigger Points
- **NLP Chat**: `DashboardScreen._onNlpResult` handles the confirmation dialog. If confirmed, it saves. If not, it opens `QuickEntrySheet`.
- **Scan Receipt**: `QuickEntrySheet._scanReceipt` handles the image processing and fills the form. The event should trigger when `_onSave` is called.

### 3. Data Structure
- Event Name: `ai_performance_v1`
- Parameters:
  - `method`: `scan_receipt` | `nlp_chat`
  - `ai_cat`: Name of the category suggested by AI.
  - `final_cat`: Name of the category finally saved by the user.
  - `is_correct`: `1` if they match, `0` otherwise.

### 4. Implementation Strategy
- **Abstract Analytics**: Add `logAiAccuracy` to `MonitoringService`.
- **State Tracking in QuickEntrySheet**: Add `_aiSuggestedCategoryName` and `_aiMethod` to `_QuickEntrySheetState`.
- **Update Dashboard Logic**: Log accuracy in `_onNlpResult` if saved immediately.
- **Update QuickEntrySheet Logic**: Log accuracy in `_onSave` if it was an AI-originated transaction.

## Constraints & Rules
- **Silent Errors**: Use `try-catch` to ensure analytics failures don't block saving.
- **UX Impact**: Ensure calls are non-blocking (already handled by Firebase's async nature, but we should not await them if they might delay the UI). Actually, `FirebaseAnalytics.logEvent` is fire-and-forget in most cases, but we should be careful.
- **FVM**: Must use FVM for all commands.

## Open Questions
- Should we track "is_correct" for other fields like `amount` or `date`? 
  - *Answer*: User story only mentions category comparison (`suggested_category` vs `final_category`).
