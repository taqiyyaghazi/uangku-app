import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/features/auth/models/user_profile.dart';
import 'package:uangku/features/auth/screens/login_screen.dart';
import 'package:uangku/features/auth/state/auth_provider.dart';
import 'package:uangku/features/auth/widgets/auth_wrapper.dart';
import 'package:uangku/features/main_shell.dart';
import 'package:uangku/features/sync/state/sync_status_provider.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('AuthWrapper shows loading state initially', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => const Stream.empty()),
          databaseProvider.overrideWithValue(database),
        ],
        child: const MaterialApp(home: AuthWrapper()),
      ),
    );

    expect(find.byKey(const ValueKey('loading')), findsOneWidget);
  });

  testWidgets('AuthWrapper shows LoginScreen when unauthenticated', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          databaseProvider.overrideWithValue(database),
        ],
        child: const MaterialApp(home: AuthWrapper()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('AuthWrapper shows MainShell when authenticated', (tester) async {
    const user = UserProfile(
      id: '123',
      name: 'Test User',
      email: 'test@example.com',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(user)),
          databaseProvider.overrideWithValue(database),
          syncStatusProvider.overrideWith(_MockSyncStatusNotifier.new),
        ],
        child: const MaterialApp(home: AuthWrapper()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MainShell), findsOneWidget);

    // Unmount the widget tree to trigger Riverpod/Drift disposal
    await tester.pumpWidget(const SizedBox());
    // Pump enough time to allow any delayed stream cleanup timers from Drift to complete
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  });

  testWidgets('AuthWrapper shows Error state on stream error', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.error('Auth error')),
          databaseProvider.overrideWithValue(database),
        ],
        child: const MaterialApp(home: AuthWrapper()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('error')), findsOneWidget);
  });
}

/// A no-op [SyncStatusNotifier] for testing to avoid triggering cloud sync.
class _MockSyncStatusNotifier extends SyncStatusNotifier {
  _MockSyncStatusNotifier() : super();

  @override
  SyncStatusState build() => SyncStatusState.idle();

  @override
  Future<void> restoreDataIfNeeded() async {
    // No-op for tests
  }
}
