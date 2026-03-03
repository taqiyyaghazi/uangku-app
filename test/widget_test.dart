import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:uangku/core/constants/app_constants.dart';
import 'package:uangku/main.dart';

void main() {
  setUp(() {
    // Disable Google Fonts network fetching in tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App renders welcome screen with correct title', (
    WidgetTester tester,
  ) async {
    // Arrange: Build the app within a ProviderScope.
    await tester.pumpWidget(const ProviderScope(child: UangkuApp()));
    await tester.pumpAndSettle();

    // Assert: Verify the app title and welcome text are displayed.
    expect(find.text(AppConstants.appName), findsWidgets);
    expect(find.text('Welcome to ${AppConstants.appName}'), findsOneWidget);
    expect(find.text('Your personal finance tracker'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
  });
}
