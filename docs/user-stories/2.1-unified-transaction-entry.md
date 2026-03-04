# Story 2.1: Unified Transaction Entry (Quick-Log)

**Status:** Ready for Implementation
**Epic:** 2 - The "Daily Breath" Budgeting System
**Story Point:** 2 (Estimated 3-4 hours)

---

## User Story

**As a** user,
**I want** a single, prominent entry button that opens a fast input form,
**so that** I can record a transaction in under 3 seconds without navigating through multiple menus.

---

## Acceptance Criteria

**AC #1: The Teal FAB**

* **Given** the Dashboard screen,
* **When** the app is active,
* **Then** a prominent Floating Action Button (FAB) in **Ocean Flow Teal** must be visible in the bottom right.

**AC #2: Unified Entry Modal**

* **Given** I tap the FAB,
* **When** the entry sheet opens,
* **Then** it must provide a clear toggle between **Income**, **Expense**, and **Transfer**.

**AC #3: Custom Fast-Numpad**

* **Given** the entry modal is open,
* **When** I start typing the amount,
* **Then** a custom-styled numerical pad (not the default system keyboard) must appear for maximum speed.

**AC #4: Atomic Transaction Write**

* **Given** valid input (Amount, Wallet, Category),
* **When** I tap "Save",
* **Then** the app must perform an atomic database transaction:
1. Create a record in the `Transactions` table.
2. Update the `balance` in the corresponding `Wallets` table.



---

## Implementation Details

### Tasks / Subtasks

* [ ] Create `QuickEntrySheet` (Stateful Widget):
* Implement a `SegmentedButton` or `ToggleButtons` for Expense/Income/Transfer.


* [ ] Design the Custom `Numpad` Widget:
* 3x4 grid for numbers 0-9, a decimal point, and a backspace.


* [ ] Implement Wallet Selector:
* A horizontal list or dropdown showing the current wallets from Story 1.2.


* [ ] Database Logic (Drift):
* Create a DAO method `insertTransactionAndUpdateWallet(TransactionCompanion t)`.
* Wrap the logic in a `transaction(() async { ... })` block for data integrity.


* [ ] Add "Haptic Feedback":
* Trigger a light vibration on each numpad tap to enhance the "speed" feeling.



### Technical Summary

The key here is **Latency**. By building a custom Numpad, we avoid the delay of the system keyboard sliding up. Using Drift's `transaction` block is crucial; if the phone crashes while saving, we don't want a transaction recorded without the wallet balance updating.

### Project Structure Notes

* **Files to create:**
* `lib/features/transaction/widgets/numpad.dart`
* `lib/features/transaction/screens/entry_sheet.dart`


* **Prerequisites:** **Story 1.1** (DB Tables) and **Story 1.2** (Wallet fetching).

---

## Context References

**Tech-Spec:** [tech-spec.md](https://www.google.com/search?q=../tech-spec.md)

* Interaction: Unified entry logic.
* Stack: Drift + Riverpod.

**UX-Spec:** [ux-design-specification.md](https://www.google.com/search?q=../ux-design-specification.md)

* Color: Teal FAB (#008080).
* Speed Principle: Entry in < 3 seconds.
