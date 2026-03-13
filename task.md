# Task: Dashboard Wallet Layout Refactor (Carousel View)

## Phase 1: Research [x]
- [x] Analyze current implementation of `DashboardScreen` and `WalletGrid`.
- [x] Define `WalletCarousel` widget structure and styling.
- [x] Document research findings in `docs/research_logs/9.1-dashboard-wallet-carousel.md`.

## Phase 2: Implement [x]
- [x] Create `WalletCarousel` widget.
- [x] Create shared `AddWalletCard` widget.
- [x] Refactor `WalletGrid` to use shared card.
- [x] Integrate `WalletCarousel` into `DashboardScreen` with conditional logic.
- [x] Implement "Indicator Dots" for > 3 wallets.
- [x] Add widget tests for `WalletCarousel` and `DashboardScreen` layout logic.

## Phase 3: Integrate [x]
- [x] Verify integration with `CustomScrollView`.
- [x] Ensure "Recent Transactions" visibility by reducing wallet section height.

## Phase 4: Verify [x]
- [x] Run all tests (255 tests passed).
- [x] All linters pass.

## Phase 5: Ship [x]
- [x] Git commit with conventional format.
