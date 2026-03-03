# Research Log: Epic 1 - Foundation & Wallet Core (Story 1.1)

**Date:** 2026-03-03
**Story:** 1.1 - Project Setup & Database Schema

---

## 1. Technology Decisions

### Stack (from tech-spec.md)

- **Framework:** Flutter (Dart SDK ^3.11.0)
- **Database:** Drift (SQLite wrapper, type-safe, reactive streams)
- **State Management:** Riverpod (functional providers)
- **Charts (later):** fl_chart

### Key Packages (pub.dev verified)

| Package                | Purpose                           | Dev? |
| ---------------------- | --------------------------------- | ---- |
| `flutter_riverpod`     | State management / DI             | No   |
| `drift`                | SQLite ORM with reactive streams  | No   |
| `sqlite3_flutter_libs` | Native SQLite bindings for mobile | No   |
| `path_provider`        | Platform-specific file paths      | No   |
| `path`                 | File path manipulation            | No   |
| `drift_dev`            | Code generation for Drift         | Yes  |
| `build_runner`         | Dart code generation runner       | Yes  |
| `mockito`              | Mock generation for tests         | Yes  |
| `build_runner`         | Triggers code generation          | Yes  |

## 2. Architecture (from project-structure.md - Flutter/Mobile Layout)

```
lib/
├── core/
│   ├── di/                   # Riverpod providers (DI)
│   ├── theme/                # Ocean Flow theme
│   └── constants/            # App constants
├── features/
│   ├── dashboard/            # Story 1.2+
│   ├── transaction/          # Story 2.1+
│   └── portfolio/            # Story 3.x
├── data/                     # Drift DB & DAOs (shared data layer)
│   ├── database.dart         # @DriftDatabase definition
│   ├── tables/               # Table definitions
│   └── daos/                 # Data Access Objects
└── main.dart                 # ProviderScope entry
```

## 3. Data Models (from tech-spec.md §3.2)

### Wallets Table

| Column       | Type      | Notes                           |
| ------------ | --------- | ------------------------------- |
| `id`         | `INTEGER` | Auto-increment PK               |
| `name`       | `TEXT`    | Wallet name                     |
| `balance`    | `REAL`    | Current balance                 |
| `type`       | `TEXT`    | Enum: cash, bank, investment    |
| `color_hex`  | `TEXT`    | Card color (Ocean Flow palette) |
| `icon`       | `TEXT`    | Icon identifier                 |
| `created_at` | `INTEGER` | DateTime as epoch ms            |
| `updated_at` | `INTEGER` | DateTime as epoch ms            |

### Transactions Table

| Column       | Type      | Notes                           |
| ------------ | --------- | ------------------------------- |
| `id`         | `INTEGER` | Auto-increment PK               |
| `wallet_id`  | `INTEGER` | FK → Wallets                    |
| `amount`     | `REAL`    | Transaction amount              |
| `type`       | `TEXT`    | Enum: income, expense, transfer |
| `category`   | `TEXT`    | Spending category               |
| `note`       | `TEXT`    | Optional description            |
| `date`       | `INTEGER` | DateTime as epoch ms            |
| `created_at` | `INTEGER` | DateTime as epoch ms            |

### Investment Snapshots Table

| Column          | Type      | Notes                |
| --------------- | --------- | -------------------- |
| `id`            | `INTEGER` | Auto-increment PK    |
| `wallet_id`     | `INTEGER` | FK → Wallets         |
| `total_value`   | `REAL`    | Snapshot value       |
| `snapshot_date` | `INTEGER` | DateTime as epoch ms |

## 4. Testability Pattern (from architectural-pattern.md)

- **Repository Interface:** Abstract class for each data access pattern
- **Mock Implementation:** For unit tests
- **Drift Implementation:** For production (and integration tests)
- **Riverpod Providers:** Can be overridden in tests

## 5. Ocean Flow Theme (from ux-design-specification.md)

| Token      | Color                 | Usage                        |
| ---------- | --------------------- | ---------------------------- |
| Primary    | `#008080` (Teal)      | Main actions, FAB, headers   |
| Secondary  | `#F5F5F5` (Soft Grey) | Background, containers       |
| Accent     | `#FFBF00` (Amber)     | Warnings, gentle adjustments |
| Typography | Inter / Roboto        | Clean sans-serif             |
