# Uangku - Technical Specification

**Project Level:** 1 | **Field Type:** Greenfield | **Stack:** Flutter

## 1. Context

* **Project Goal:** A minimal, fast, offline-first personal finance tracker.
* **Key Innovation:** "The Daily Breath" (Dynamic daily budgeting with auto-correction).
* **Target Platform:** Mobile (iOS/Android).

## 2. Implementation Stack

* **Framework:** Flutter (Latest Stable).
* **Language:** Dart.
* **Database (Offline):** **Drift** (SQLite wrapper). Provides reactive streams and type-safe queries.
* **State Management:** **Riverpod** (Functional providers).
* **Charts:** **fl_chart** (For portfolio trends and asset allocation).

## 3. Technical Details

### 3.1 The "Daily Breath" Logic

* **Equation:** `Daily Allowance = (Monthly Budget - Total Spent) / Sisa Hari`.
* **Auto-Correction:** If overspent today, the `Sisa Hari` divisor ensures the burden is spread across the rest of the month, reducing the future daily allowance gently.
* **Persistence:** All transactions and wallet balances are stored locally in SQLite via Drift.

### 3.2 Data Models

* **Wallets:** `id`, `name`, `balance`, `type` (Cash, Bank, Investment), `color_hex`.
* **Transactions:** `id`, `wallet_id`, `amount`, `type` (Income/Expense/Transfer), `category`, `timestamp`.
* **Investment_Snapshots:** `id`, `wallet_id`, `total_value`, `snapshot_date`.

## 4. Source Tree (Feature-First)

```text
lib/
├── core/                # Theme (Ocean Flow), App Constants
├── data/                # Drift DB Definitions, DAOs
├── features/
│   ├── dashboard/       # Daily Breath logic & Wallet Grid
│   ├── transaction/     # Quick Entry FAB & Form
│   └── portfolio/       # fl_chart implementations
└── main.dart            # ProviderScope & App Entry

```
