---
description: Workflow for safely upgrading outdated packages and dependencies
---

# Package Upgrade Workflow

## Purpose

Safely upgrade project dependencies, resolve breaking changes, and ensure the application remains stable after the update.

## When to Use

- When actively requested to update dependencies (e.g., `/upgrade-packages`)
- Regularly to keep the codebase up-to-date with security patches and new features
- When a specific package needs to be updated to resolve a bug or access a new feature

## Pre-Requisites

Ensure the working tree is clean before starting an upgrade. Run `git status` to verify.

## Phases

### Phase 1: Assess

**Set Mode:** Use `task_boundary` to set mode to **PLANNING**

1. Ensure the use of `fvm` for flutter operations since the project uses it.
2. Run the command to list outdated packages:
   ```bash
   fvm flutter pub outdated
   ```
3. Identify packages that need updating (focus on resolving `resolvable` and `upgradable` first).
4. Determine if it's a minor/patch update (low risk) or a major version update (high risk of breaking changes). Document the target versions in `task.md`.

### Phase 2: Upgrade

**Set Mode:** Use `task_boundary` to set mode to **EXECUTION**

1. To upgrade within current major versions (minor/patch):
   ```bash
   fvm flutter pub upgrade
   ```
2. To upgrade to new major versions (breaking changes):
   ```bash
   fvm flutter pub upgrade --major-versions
   ```
   Or upgrade specific packages:
   ```bash
   fvm flutter pub upgrade package_name
   ```
3. Review `pubspec.yaml` and `pubspec.lock` diffs to confirm intended changes.

### Phase 3: Resolve & Verify

**Set Mode:** Use `task_boundary` to set mode to **VERIFICATION**

1. Run code generation if the project relies on it (e.g., `build_runner`):
   ```bash
   fvm flutter pub run build_runner build --delete-conflicting-outputs
   ```
2. Run static analysis to detect breaking changes from updated packages:
   ```bash
   fvm flutter analyze
   ```
3. Fix any code issues/deprecations surfaced by the analyzer. Run web searches or check pub.dev for package changelogs if necessary to understand breaking changes.
4. Run the full test suite to ensure no regressions:
   ```bash
   fvm flutter test
   ```

### Phase 4: Commit

**Set Mode:** Use `task_boundary` to set mode to **VERIFICATION**

1. Once all tests and analyzer checks pass, stage the changes: `pubspec.yaml`, `pubspec.lock`, and any modified source files.
2. Commit the changes following the conventional format.
3. Use commit type `build(deps): bump dependencies` or `build(deps): bump package_name from X to Y`.

## Completion Criteria

- [ ] Outdated packages are identified and documented
- [ ] Packages are upgraded successfully
- [ ] Code generation (if applicable) succeeds
- [ ] Static analysis passes without errors
- [ ] Test suite passes completely
- [ ] Changes are committed with the appropriate `build(deps)` scope
