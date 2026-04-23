# 🌊 Uangku (Financial Daily Breath) - Project Context

This document serves as the primary instructional context for Gemini CLI when working on the **Uangku** project.

## 📌 Project Overview

**Uangku** is a high-performance, offline-first personal finance tracker built with Flutter. It prioritizes a "calm" user experience through its **"Ocean Flow"** aesthetic and its core innovation: the **"Daily Breath"** budgeting engine.

### 🌬️ The "Daily Breath" Engine
Unlike rigid monthly budgets, Uangku calculates a dynamic daily allowance:
`Daily Allowance = (Monthly Budget - Total Spent) / Remaining Days`
If a user overspends today, the engine automatically adjusts the allowance for future days to maintain the monthly goal without requiring manual recalculation.

### 🛠️ Technical Stack
- **Frontend:** Flutter (v3.x+) managed via **FVM**.
- **State Management:** **Riverpod** (Functional providers).
- **Local Database:** **Drift** (SQLite) for reactive, type-safe persistence.
- **Backend/Cloud:** **Firebase** (Authentication, Firestore Sync, Analytics, Crashlytics).
- **Observability:** **MonitoringService** for unified logging, analytics, and crash reporting.
- **Architecture:** **Feature-based vertical slices** (located in `lib/features/`).
- **Status:** **Feature Complete** (35/35 User Stories implemented).

---

## 🚀 Building and Running

### ⚠️ FVM Mandate
You **MUST** use the Flutter/Dart binaries managed by FVM. Never use global commands.

- **Flutter Path:** `.fvm/flutter_sdk/bin/flutter`
- **Dart Path:** `.fvm/flutter_sdk/bin/dart`

### Key Commands
- **Install Dependencies:**
  ```bash
  .fvm/flutter_sdk/bin/flutter pub get
  ```
- **Code Generation (Drift/Models):**
  ```bash
  .fvm/flutter_sdk/bin/dart run build_runner build --delete-conflicting-outputs
  ```
- **Run Development Flavor:**
  ```bash
  .fvm/flutter_sdk/bin/flutter run --flavor dev -t lib/main_dev.dart
  ```
- **Run Production Flavor:**
  ```bash
  .fvm/flutter_sdk/bin/flutter run --flavor prod -t lib/main_prod.dart
  ```
- **Static Analysis:**
  ```bash
  .fvm/flutter_sdk/bin/flutter analyze
  ```
  

---

## 🧪 Testing Strategy

Follow the **70/20/10 Test Pyramid** (Unit/Integration/E2E).

- **Location:** Tests are currently located in the `test/` directory, mirroring the structure of `lib/`.
- **Naming:** Files must end with `_test.dart`.
- **Pattern:** Use the **AAA (Arrange-Act-Assert)** pattern for all tests.
- **Mocks:** Use `mockito` for dependency doubling.
- **Execution:**
  ```bash
  .fvm/flutter_sdk/bin/flutter test
  ```

---

## 📂 Directory Structure

```text
lib/
├── core/                # App-wide config, themes (Ocean Flow), constants
├── data/                # Drift DB definitions, table schemas, DAOs
├── features/            # Vertical slices (The core business logic)
│   ├── auth/            # Firebase Google Login
│   ├── dashboard/       # Daily Breath logic, Wallet Carousel (5 items limit)
│   ├── transaction/     # Quick-entry, History, Deep Filters
│   ├── category/        # Custom category management
│   ├── portfolio/       # Asset allocation and trends (Charts)
│   ├── insights/        # Spending analysis (Pie/Line charts)
│   ├── export/          # CSV export logic
│   ├── sync/            # Cloud Firestore synchronization
│   └── auth/            # Google Auth & Data Cleansing on Logout
├── shared/              # Reusable UI widgets and stateless utilities
└── main_dev.dart/prod   # Entry points for different environments
```

---

## 🎨 Development Conventions

- **Feature-First:** When adding functionality, create/update the relevant slice in `lib/features/`. Do not organize by technical layers (e.g., don't put all models in a global `models/` folder).
- **Reactive Persistence:** Use Drift's stream queries to ensure the UI updates automatically when data changes.
- **Theme:** Adhere to the **Ocean Flow** theme (Teal-based colors). Use `Theme.of(context)` to access colors and typography.
- **Immutability:** Prefer immutable data models (using `final` fields) and pure functions for business logic (see `BudgetService`).
- **Cloud Sync:** Ensure all local mutations are compatible with the Firestore sync logic defined in `features/sync/`.
- **Privacy Mode:** Adhere to the **Global Privacy Mode** (managed via `shared_preferences`) when displaying financial figures.
- **Error Tracking:** Always use `MonitoringService` to log significant events or errors to ensure observability.
