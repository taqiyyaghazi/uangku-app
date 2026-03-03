## FVM Command Mandate

### Core Principle

This project uses **Flutter Version Management (FVM)** to manage the Flutter SDK. To ensure consistency and avoid version conflicts, **all** `flutter` and `dart` commands must be executed using the SDK managed by FVM.

### Universal Rules

#### Rule 1: Use FVM paths for Flutter

Whenever you need to run a `flutter` command, use the explicit binary path to the FVM-managed SDK instead of the global `flutter` command.

**❌ INcorrect:**

```bash
flutter pub get
flutter run
flutter build apk
```

**✅ Correct:**

```bash
.fvm/flutter_sdk/bin/flutter pub get
.fvm/flutter_sdk/bin/flutter run
.fvm/flutter_sdk/bin/flutter build apk
```

#### Rule 2: Use FVM paths for Dart

Whenever you need to run a `dart` command, use the explicit binary path to the FVM-managed SDK instead of the global `dart` command.

**❌ INcorrect:**

```bash
dart format .
dart run build_runner build
```

**✅ Correct:**

```bash
.fvm/flutter_sdk/bin/dart format .
.fvm/flutter_sdk/bin/dart run build_runner build
```

### Application to Code Generation & Code Completion Mandate

When following the Code Completion Mandate to run tests, format code, and perform static analysis, you MUST use the FVM binaries.

#### Validation Commands (Updated for FVM)

```bash
# Format
.fvm/flutter_sdk/bin/dart format .

# Static Analysis
.fvm/flutter_sdk/bin/flutter analyze

# Tests
.fvm/flutter_sdk/bin/flutter test
```

Failure to use the explicit FVM paths may result in using an incompatible global Dart or Flutter version, causing false positive errors in analysis or builds.
