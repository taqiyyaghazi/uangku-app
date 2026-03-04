# Story 1.1: Project Setup & Database Schema

**Status:** Ready for Implementation
**Epic:** 1 - Foundation & Wallet Core
**Story Point:** 3 (Estimated 4-6 hours)

---

## User Story

**As a** developer,
**I want** to initialize the Flutter project and define the local database schema,
**so that** I have a solid, type-safe foundation for managing wallets and transactions offline.

---

## Acceptance Criteria

**AC #1: Project Initialization**

* **Given** a clean development environment,
* **When** the Flutter project is created with a unique bundle ID,
* **Then** it must include `riverpod`, `drift`, and `sqlite_3` dependencies in `pubspec.yaml`.

**AC #2: Database Schema Definition**

* **Given** the requirement for multiple wallets and transactions,
* **When** the Drift database is defined,
* **Then** it must include a `Wallets` table (id, name, balance, icon, color) and a `Transactions` table (id, wallet_id, type [income/expense], amount, category, date).

**AC #3: Type-Safe Generation**

* **Given** the Drift table definitions,
* **When** `build_runner` is executed,
* **Then** the `database.g.dart` file must be generated without errors.

---

## Implementation Details

### Tasks / Subtasks

* [ ] Create Flutter project: `flutter create --org com.uangku uangku_app`
* [ ] Add dependencies to `pubspec.yaml`:
* `flutter_riverpod`, `drift`, `sqlite3_flutter_libs`, `path_provider`, `path`
* Dev: `drift_dev`, `build_runner`


* [ ] Initialize Folder Structure:
* `/lib/core/` (Theme, Constants)
* `/lib/data/` (Database, Repositories)
* `/lib/features/` (UI Modules)


* [ ] Create `/lib/data/local_db.dart`:
* Define `Wallets` table.
* Define `Transactions` table.
* Setup `@DriftDatabase` class.


* [ ] Run code generation: `dart run build_runner build --delete-conflicting-outputs`
* [ ] Setup Riverpod Provider for the database instance in `main.dart`.

### Technical Summary

We are using **Drift** for a "Schema-first" reactive database approach. This ensures that when you update a wallet balance, the UI (via Riverpod) updates instantly without a refresh.

### Project Structure Notes

* **Files to modify:** `pubspec.yaml`, `lib/main.dart`
* **Files to create:** `lib/data/local_db.dart`, `lib/core/theme.dart`
* **Prerequisites:** None (Foundation story)

---

## Context References

**Tech-Spec:** [tech-spec.md](https://www.google.com/search?q=../tech-spec.md)

* Stack: Flutter + Drift + Riverpod
* Vibe: Ocean Flow (Teal Palette)

**UX-Spec:** [ux-design-specification.md](https://www.google.com/search?q=../ux-design-specification.md)

* Reference the "Unified Grid" (Layout B) for future wallet fields.
