import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/features/transaction/widgets/numpad.dart';

void main() {
  Widget buildTestWidget({
    required ValueChanged<String> onDigit,
    required VoidCallback onDecimal,
    required VoidCallback onBackspace,
  }) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        splashFactory: InkSplash.splashFactory,
      ),
      home: Scaffold(
        body: Numpad(
          onDigit: onDigit,
          onDecimal: onDecimal,
          onBackspace: onBackspace,
        ),
      ),
    );
  }

  group('Numpad', () {
    testWidgets('renders all 10 digit buttons', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(onDigit: (_) {}, onDecimal: () {}, onBackspace: () {}),
      );

      for (var i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('renders decimal point button', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(onDigit: (_) {}, onDecimal: () {}, onBackspace: () {}),
      );

      expect(find.text('.'), findsOneWidget);
    });

    testWidgets('renders backspace button', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(onDigit: (_) {}, onDecimal: () {}, onBackspace: () {}),
      );

      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });

    testWidgets('calls onDigit when digit tapped', (tester) async {
      String? tappedDigit;
      await tester.pumpWidget(
        buildTestWidget(
          onDigit: (d) => tappedDigit = d,
          onDecimal: () {},
          onBackspace: () {},
        ),
      );

      await tester.tap(find.text('5'));
      expect(tappedDigit, '5');
    });

    testWidgets('calls onDecimal when decimal tapped', (tester) async {
      var called = false;
      await tester.pumpWidget(
        buildTestWidget(
          onDigit: (_) {},
          onDecimal: () => called = true,
          onBackspace: () {},
        ),
      );

      await tester.tap(find.text('.'));
      expect(called, isTrue);
    });

    testWidgets('calls onBackspace when backspace tapped', (tester) async {
      var called = false;
      await tester.pumpWidget(
        buildTestWidget(
          onDigit: (_) {},
          onDecimal: () {},
          onBackspace: () => called = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      expect(called, isTrue);
    });
  });
}
