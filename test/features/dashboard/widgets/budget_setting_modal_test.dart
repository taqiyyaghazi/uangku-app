import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:uangku/data/repositories/settings_repository.dart';
import 'package:uangku/features/dashboard/logic/settings_providers.dart';
import 'package:uangku/features/dashboard/widgets/budget_setting_modal.dart';

import 'budget_setting_modal_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SettingsRepository>()])
void main() {
  late MockSettingsRepository mockSettingsRepo;

  setUp(() {
    mockSettingsRepo = MockSettingsRepository();
  });

  Widget createSubject() {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(mockSettingsRepo),
        monthlyBudgetProvider.overrideWith((ref) => Stream.value(0.0)),
      ],
      child: const MaterialApp(home: Scaffold(body: BudgetSettingModal())),
    );
  }

  group('BudgetSettingModal', () {
    testWidgets('renders title and input field', (tester) async {
      await tester.pumpWidget(createSubject());

      expect(find.text('Set Monthly Budget'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Save Budget'), findsOneWidget);
    });

    testWidgets('shows validation error for empty input', (tester) async {
      await tester.pumpWidget(createSubject());

      // Tap save without entering anything
      await tester.tap(find.text('Save Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a budget amount'), findsOneWidget);
    });

    testWidgets('shows validation error for zero or negative budget', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject());

      // Enter 0
      await tester.enterText(find.byType(TextFormField), '0');
      await tester.tap(find.text('Save Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Budget must be greater than zero'), findsOneWidget);
    });

    testWidgets('calls setDouble on repo and closes modal on valid input', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject());

      // Enter valid budget
      await tester.enterText(find.byType(TextFormField), '6000000');
      await tester.tap(find.text('Save Budget'));
      await tester.pumpAndSettle();

      verify(mockSettingsRepo.setDouble('monthly_budget', 6000000.0)).called(1);
    });
  });
}
