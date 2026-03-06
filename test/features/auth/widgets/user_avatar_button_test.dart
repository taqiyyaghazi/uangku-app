import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/features/auth/models/user_profile.dart';
import 'package:uangku/features/auth/state/auth_provider.dart';
import 'package:uangku/features/auth/widgets/user_avatar_button.dart';

void main() {
  testWidgets('UserAvatarButton shows nothing when not authenticated', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const MaterialApp(home: Scaffold(body: UserAvatarButton())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CircleAvatar), findsNothing);
    expect(find.byType(SizedBox), findsWidgets); // shrink() returns SizedBox
  });

  testWidgets(
    'UserAvatarButton shows initials when authenticated without photo',
    (tester) async {
      const user = UserProfile(
        id: '123',
        name: 'John Doe',
        email: 'john@example.com',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(user)),
          ],
          child: const MaterialApp(home: Scaffold(body: UserAvatarButton())),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('JD'), findsOneWidget);
    },
  );

  testWidgets('UserAvatarButton shows email initial when name is null', (
    tester,
  ) async {
    const user = UserProfile(id: '123', email: 'alice@example.com');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(user)),
        ],
        child: const MaterialApp(home: Scaffold(body: UserAvatarButton())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('A'), findsOneWidget);
  });
}
