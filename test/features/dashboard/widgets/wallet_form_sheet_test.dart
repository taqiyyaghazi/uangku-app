import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/features/dashboard/widgets/wallet_form_sheet.dart';

void main() {
  // Use InkSplash instead of InkSparkle to avoid the shader asset error
  // in tests. InkSparkle requires 'shaders/ink_sparkle.frag' which is not
  // available in the unit test environment.
  final testTheme = ThemeData(
    useMaterial3: true,
    splashFactory: InkSplash.splashFactory,
  );

  Widget buildTestApp() {
    return MaterialApp(
      theme: testTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => WalletFormSheet.show(context),
              child: const Text('Open Form'),
            );
          },
        ),
      ),
    );
  }

  group('WalletFormSheet', () {
    testWidgets('shows "New Wallet" title when creating', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      expect(find.text('New Wallet'), findsOneWidget);
      expect(find.text('Create Wallet'), findsOneWidget);
    });

    testWidgets('validates empty name field', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      // Leave name empty and try to save.
      await tester.tap(find.text('Create Wallet'));
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('allows valid wallet creation', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      // Fill in name.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Wallet Name'),
        'Test Wallet',
      );

      // Fill in balance.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Initial Balance'),
        '50000',
      );

      // Tap create — bottom sheet should dismiss.
      await tester.tap(find.text('Create Wallet'));
      await tester.pumpAndSettle();

      // Form should be dismissed.
      expect(find.text('New Wallet'), findsNothing);
    });

    testWidgets('shows all wallet type segments', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Bank'), findsOneWidget);
      expect(find.text('Investment'), findsOneWidget);
    });

    testWidgets('shows "New Wallet" title when wallet is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const WalletFormSheet(),
                    );
                  },
                  child: const Text('Open Edit'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open Edit'));
      await tester.pumpAndSettle();

      // When wallet is null, it should show "New Wallet".
      expect(find.text('New Wallet'), findsOneWidget);
    });
  });
}
