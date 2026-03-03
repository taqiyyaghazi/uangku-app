# Story 1.2: Wallet Management UI (The Unified Grid)

**Status:** Ready for Implementation
**Epic:** 1 - Foundation & Wallet Core
**Story Point:** 3 (Estimated 4-6 hours)

---

## User Story

**As a** user,
**I want** to see all my wallets in a clean grid at the top of my dashboard,
**so that** I can instantly understand my total asset distribution and current liquidity.

---

## Acceptance Criteria

**AC #1: The Unified Grid Layout**

- **Given** the Dashboard screen,
- **When** the app loads,
- **Then** it must display a 2-column grid showing all created wallets at the top of the page.

**AC #2: Wallet Card Visualization**

- **Given** a wallet in the database,
- **When** rendered in the grid,
- **Then** each card must show:
- Wallet Name (e.g., "Bank BCA", "Cash")
- Current Balance (Formatted: e.g., "Rp 1.250.000")
- A specific icon and the **Ocean Flow** Teal accent.

**AC #3: Reactive Data Streams**

- **Given** the `walletsProvider`,
- **When** a wallet balance changes in the database,
- **Then** the UI card must update automatically without a manual page refresh.

**AC #4: Edit/Add Interaction**

- **Given** an existing wallet card,
- **When** tapped,
- **Then** it must open a Bottom Sheet allowing the user to edit the Wallet Name or the Initial Balance.

---

## Implementation Details

### Tasks / Subtasks

- [ ] Create `WalletCard` stateless widget:
- Stylize with `Container`, `BoxShadow`, and rounded corners (Vibe B).
- Use Teal (#008080) for borders or active states.

- [ ] Implement `DashboardHeader`:
- Display "Total Balance" (Sum of all wallets).
- Use `fl_chart` (optional here, required in Epic 3) or a simple text summary.

- [ ] Build the `SliverGrid` for wallets:
- Use `ref.watch(walletsProvider)` to listen to the Drift stream.

- [ ] Create `WalletForm` Bottom Sheet:
- Fields: `name`, `balance`, `type` (dropdown), `color`.
- Validation: Name cannot be empty; balance must be numeric.

- [ ] Connect Form to Drift DAO:
- Implement `updateWallet` and `insertWallet` methods.

### Technical Summary

This story utilizes **Riverpod's `AsyncValue**`to handle the loading state of your local database. By using a`StreamProvider` linked to your Drift database, the grid becomes "live"—any background change to the SQLite file will trigger a smooth UI transition.

### Project Structure Notes

- **Files to create:** - `lib/features/dashboard/widgets/wallet_card.dart`
- `lib/features/dashboard/widgets/wallet_grid.dart`
- `lib/features/dashboard/screens/dashboard_screen.dart`

- **Prerequisites:** **Story 1.1** (Database schema must exist).

---

## Context References

**Tech-Spec:** [tech-spec.md](https://www.google.com/search?q=../tech-spec.md)

- Primary Stack: Flutter + Drift.
- Database: `Wallets` table must have `id`, `name`, `balance`, `color`.

**UX-Spec:** [ux-design-specification.md](https://www.google.com/search?q=../ux-design-specification.md)

- Layout: **Layout B (Unified Grid)**.
- Theme: **Ocean Flow** (Teal accent colors).
