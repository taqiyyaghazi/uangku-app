import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/features/auth/screens/login_screen.dart';
import 'package:uangku/features/auth/state/auth_provider.dart';
import 'package:uangku/features/auth/repository/auth_repository.dart';
import 'package:uangku/features/auth/models/user_profile.dart';

import 'dart:async';

class MockAuthRepository implements AuthRepository {
  Completer<UserProfile?> signInCompleter = Completer<UserProfile?>();

  @override
  Stream<UserProfile?> get authStateChanges => const Stream.empty();

  @override
  Future<UserProfile?> signInWithGoogle() => signInCompleter.future;

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('LoginScreen shows Google Sign-In button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('Sign in with Google'), findsOneWidget);
  });

  testWidgets('LoginScreen shows app branding', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('Uangku'), findsOneWidget);
  });

  testWidgets('LoginScreen shows loading state when button pressed', (
    tester,
  ) async {
    final mockRepo = MockAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        child: MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: const LoginScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Sign in with Google'));
    await tester.pump(); // Triggers the setState and rebuilds with loading UI

    expect(find.text('Signing in…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Resolve the future so the test can finish without pending timers
    mockRepo.signInCompleter.complete(null);
    await tester.pumpAndSettle();
  });
}
