# Task: Story 1.1 - Project Setup & Database Schema

## Scope

Initialize the Flutter project foundation: dependencies, folder structure, Drift database schema, Ocean Flow theme, and Riverpod wiring.

## Workflow Status

### Phase 1: Research

- [x] Analyze request, understand context
- [x] Define scope in `task.md`
- [x] Research Drift, Riverpod, Flutter patterns
- [x] Document findings in `docs/research_logs/epic1_foundation.md`

### Phase 2: Implement

- [/] Add dependencies to `pubspec.yaml`
- [ ] Create folder structure
- [ ] Define Drift tables (Wallets, Transactions, InvestmentSnapshots)
- [ ] Define Repository interface (abstract class)
- [ ] Implement Drift database class with DAOs
- [ ] Run code generation (`build_runner`)
- [ ] Create Ocean Flow theme (`core/theme/`)
- [ ] Wire Riverpod providers in `main.dart`
- [ ] Write unit tests for table definitions and model enums
- [ ] Write unit tests for business logic (pure functions)

### Phase 3: Integrate

- [ ] Integration test with real Drift database

### Phase 4: Verify

- [ ] `flutter analyze` passes
- [ ] All tests pass
- [ ] No lint errors

### Phase 5: Ship

- [ ] Git commit
