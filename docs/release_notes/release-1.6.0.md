# Release Notes - v1.6.0

This release introduces major AI-powered features to simplify your financial tracking, including Natural Language Processing (NLP) for transaction entry and a Smart Receipt Scanner.

## 🚀 New Features

### 🧠 AI Financial Assistant (NLP Transaction Entry)
- **Chat-to-Record**: You can now record expenses, income, or transfers just by typing or speaking.
- **Expandable FAB**: A new, sleek magic button on the dashboard for quick access to AI features.
- **Smart Parsing**: Automatically extracts amount, category, wallet, and notes from your natural language input.
- **Voice Integration**: Added support for voice-to-text recording (powered by `speech_to_text`).

### 📸 Smart Receipt Scanner
- **Gemini-Powered OCR**: Extract transaction details directly from your physical receipts using Gemini 1.5 Flash.
- **Itemized Extraction**: Automatically parses item lists from receipts and includes them in the transaction notes.
- **Rate Limit Feedback**: Added clear user feedback when reaching API quotas.

## 🛠️ Improvements & Fixes

- **Localization**: All AI-related strings and error messages have been translated to English for a more professional experience.
- **Persona Refinement**: Removed "Bob" references for a more neutral and streamlined assistant interface.
- **Technical Stability**:
    - Updated Gemini model to `gemini-1.5-flash-latest` for improved reliability.
    - Fixed type mismatch issues in the NLP input bar.
    - Improved CI/CD workflows for environment variable management.

## 📦 Technical Changes
- Added `speech_to_text` dependency.
- Updated `google_generative_ai` configuration.
- Enhanced `TransactionRepository` to support internal transfers via NLP.

