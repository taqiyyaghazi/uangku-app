# Release Notes - v1.7.0

**Version:** 1.7.0+9  
**Date:** April 24, 2026  
**Previous Version:** v1.6.0

## 🌬️ Overview
Release 1.7.0 brings significant enhancements to user privacy, data security, and AI observability. This version marks the transition of **Uangku** to a "Feature Complete" status, with the inclusion of advanced analytics to monitor AI accuracy and a more robust secure logout mechanism.

## 🚀 Key Features

### 📊 AI Accuracy Tracking (Story 13.1)
- **Firebase Analytics Integration**: Implemented a tracking system to measure the performance of Gemini AI suggestions.
- **Accuracy Comparison**: Automatically logs whether the AI-suggested category matches the user's final choice for both NLP transactions and Receipt Scanning.
- **Silent Observability**: Uses a non-intrusive logging pattern to ensure performance is measured without affecting the user experience.

### 🛡️ Privacy & Security
- **Global Privacy Mode**: Introduced a new setting to mask financial balances across the app, perfect for usage in public spaces.
- **Secure Logout & Data Cleansing**: Enhanced the logout flow to include local data wiping, ensuring that sensitive financial data is removed from the device when a user logs out.

### 📈 Dashboard & UI Optimizations
- **Wallet Carousel Limit**: To maintain a "calm" UI, the dashboard wallet carousel is now limited to 5 items.
- **Improved Indicators**: Refined carousel indicators for better navigation between wallets.

## 🛠️ Technical Improvements & Bug Fixes

### Data Synchronization
- **Reactive Sync Status**: Refactored the sync status provider to be fully reactive to authentication changes, ensuring reliable data restoration upon re-login.
- **State Invalidation**: Fixed a bug where sync state was retained after logout.

### Reliability
- **Auth Flow**: Resolved a navigation issue where the user could remain "stuck" on the dashboard after confirming a logout.
- **Test Coverage**: Added comprehensive widget tests for the new privacy features and AI tracking logic.

## 📖 Documentation
- Updated `README.md` and `GEMINI.md` to reflect the current feature-complete status (35/35 User Stories).
- Finalized Epic 11 documentation.

---
*Uangku - Financial Daily Breath*
