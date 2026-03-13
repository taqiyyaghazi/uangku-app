import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/shared/widgets/searchable_picker_sheet.dart';

void main() {
  group('SearchablePickerSheet', () {
    final testItems = [
      const PickerItem<int>(id: 1, name: 'Apple', icon: Icons.face, color: Colors.red),
      const PickerItem<int>(id: 2, name: 'Banana', icon: Icons.face, color: Colors.yellow),
      const PickerItem<int>(id: 3, name: 'Cherry', icon: Icons.face, color: Colors.red),
    ];

    testWidgets('renders title and items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchablePickerSheet<int>(
              title: 'Pick a Fruit',
              items: testItems,
            ),
          ),
        ),
      );

      expect(find.text('Pick a Fruit'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('filters items based on search query', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchablePickerSheet<int>(
              title: 'Pick a Fruit',
              items: testItems,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'ap');
      await tester.pump();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsNothing);
      expect(find.text('Cherry'), findsNothing);
    });

    testWidgets('shows recent items when query is empty', (tester) async {
      final recent = [testItems[1]]; // Banana

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchablePickerSheet<int>(
              title: 'Pick a Fruit',
              items: testItems,
              recentItems: recent,
            ),
          ),
        ),
      );

      expect(find.text('Recent'), findsOneWidget);
      // Banana should appear twice: once in Recent, once in All Items
      expect(find.text('Banana'), findsNWidgets(2));
      
      // Enter search query
      await tester.enterText(find.byType(TextField), 'ap');
      await tester.pump();

      // Recent section should disappear
      expect(find.text('Recent'), findsNothing);
      expect(find.text('Banana'), findsNothing);
    });

    testWidgets('shows Add New state when no results found', (tester) async {
      String? addedName;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchablePickerSheet<int>(
              title: 'Pick a Fruit',
              items: testItems,
              addNewLabel: 'Add Fruit',
              onAddNew: (val) => addedName = val,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Dragonfruit');
      await tester.pump();

      expect(find.text('No results found for "Dragonfruit"'), findsOneWidget);
      expect(find.text('Add Fruit: "Dragonfruit"'), findsOneWidget);

      await tester.tap(find.text('Add Fruit: "Dragonfruit"'));
      expect(addedName, 'Dragonfruit');
    });

    testWidgets('returns selected item id when tapped', (tester) async {
      int? selectedId;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  selectedId = await SearchablePickerSheet.show<int>(
                    context,
                    title: 'Pick a Fruit',
                    items: testItems,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();

      expect(selectedId, 2);
    });
  });
}
