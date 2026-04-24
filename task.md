# Task: Implement Story 12.1 (Smart Receipt Scanner)

## Phase 2: Implement [/]
- [x] Add `image_picker`, `google_generative_ai`, and `flutter_image_compress` dependencies.
- [x] Set up environment variable handling for Gemini API key (e.g. `flutter_dotenv`).
- [x] Create `GeminiScannerService` in `lib/features/transaction/services/`.
  - [x] Implement `analyzeReceipt` method using `google_generative_ai` and `gemini-1.5-flash`.
- [x] Add loading animation overlay widget (laser effect + "Bob is reading your receipt...").
- [x] Update "Add Transaction" UI (`lib/features/transaction/screens/` or `widgets/`).
  - [x] Add "Scan Receipt" camera icon next to "Amount" field.
  - [x] Implement `image_picker` to capture receipt.
  - [x] Connect image capture to `GeminiScannerService`.
- [x] Implement data mapping (JSON parsing) to populate the transaction form automatically.
  - [x] Amount
  - [x] Notes (Store)
  - [x] Date
  - [x] Category (Fuzzy match)
- [x] Handle fallback mechanism (errors/poor connection).

## Phase 3: Integrate / Verify [x]
- [x] Run `flutter test` to ensure new tests and existing tests pass.
- [x] Run `flutter analyze` to ensure code quality.

## Phase 4: Ship
- [x] Create commit with conventional message.
