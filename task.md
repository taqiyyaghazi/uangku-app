# Task: Story 1.2 - Wallet Management UI (The Unified Grid)

## Scope

Implement the Wallet Management UI: dashboard screen with a 2-column wallet grid, wallet cards with Ocean Flow styling, total balance header, add/edit wallet bottom sheet, and reactive data binding via Riverpod.

## Workflow Status

### Phase 1: Research

- [x] Analyze request and user story
- [x] Review existing foundation (Story 1.1)
- [x] Review UX/tech specs for styling guidance

### Phase 2: Implement

- [ ] Create currency formatting utility (`lib/shared/utils/currency_formatter.dart`)
- [ ] Create icon mapping utility (`lib/shared/utils/wallet_icon_mapper.dart`)
- [ ] Create `WalletCard` widget (`lib/features/dashboard/widgets/wallet_card.dart`)
- [ ] Create `WalletGrid` widget (`lib/features/dashboard/widgets/wallet_grid.dart`)
- [ ] Create `DashboardHeader` widget (`lib/features/dashboard/widgets/dashboard_header.dart`)
- [ ] Create `WalletFormSheet` widget (`lib/features/dashboard/widgets/wallet_form_sheet.dart`)
- [ ] Create `DashboardScreen` (`lib/features/dashboard/screens/dashboard_screen.dart`)
- [ ] Update `main.dart` to use DashboardScreen
- [ ] Write widget tests for WalletCard
- [ ] Write widget tests for WalletFormSheet validation
- [ ] Write unit tests for currency formatter

### Phase 4: Verify

- [ ] `flutter analyze` passes
- [ ] All tests pass
- [ ] No lint errors

### Phase 5: Ship

- [ ] Git commit
