import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilele_pos/widgets/searchable_list.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('SearchableList Widget Tests', () {
    final testItems = [
      {'id': '1', 'name': 'Apple'},
      {'id': '2', 'name': 'Banana'},
      {'id': '3', 'name': 'Orange'},
    ];

    testWidgets('Renders with basic properties', (tester) async {
      await TestHelpers.pumpWidget(
        tester,
        SearchableList<Map<String, dynamic>>(
          items: testItems,
          itemLabel: (item) => item['name'] as String,
          itemBuilder: (context, item) => ListTile(
            title: Text(item['name'] as String),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Orange'), findsOneWidget);
    });

    testWidgets('Filters items based on search query', (tester) async {
      await TestHelpers.pumpWidget(
        tester,
        SearchableList<Map<String, dynamic>>(
          items: testItems,
          itemLabel: (item) => item['name'] as String,
          itemBuilder: (context, item) => ListTile(
            title: Text(item['name'] as String),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'App');
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsNothing);
      expect(find.text('Orange'), findsNothing);
    });

    testWidgets('Shows loading indicator when isLoading is true',
        (tester) async {
      await TestHelpers.pumpWidget(
        tester,
        SearchableList<Map<String, dynamic>>(
          items: testItems,
          itemLabel: (item) => item['name'] as String,
          itemBuilder: (context, item) => ListTile(
            title: Text(item['name'] as String),
          ),
          isLoading: true,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Shows custom loading widget when provided', (tester) async {
      await TestHelpers.pumpWidget(
        tester,
        SearchableList<Map<String, dynamic>>(
          items: testItems,
          itemLabel: (item) => item['name'] as String,
          itemBuilder: (context, item) => ListTile(
            title: Text(item['name'] as String),
          ),
          isLoading: true,
          loadingWidget: const Center(
            child: Text('Custom Loading...'),
          ),
        ),
      );

      expect(find.text('Custom Loading...'), findsOneWidget);
    });

    testWidgets('Shows empty state when no items match search', (tester) async {
      await TestHelpers.pumpWidget(
        tester,
        SearchableList<Map<String, dynamic>>(
          items: testItems,
          itemLabel: (item) => item['name'] as String,
          itemBuilder: (context, item) => ListTile(
            title: Text(item['name'] as String),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'XYZ');
      await tester.pumpAndSettle();

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('Shows custom empty widget when provided', (tester) async {
      await TestHelpers.pumpWidget(
        tester,
        SearchableList<Map<String, dynamic>>(
          items: testItems,
          itemLabel: (item) => item['name'] as String,
          itemBuilder: (context, item) => ListTile(
            title: Text(item['name'] as String),
          ),
          emptyWidget: const Center(
            child: Text('Custom Empty State'),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'XYZ');
      await tester.pumpAndSettle();

      expect(find.text('Custom Empty State'), findsOneWidget);
    });

    testWidgets('Calls onSearchChanged when search query changes',
        (tester) async {
      String? lastSearchQuery;
      await TestHelpers.pumpWidget(
        tester,
        SearchableList<Map<String, dynamic>>(
          items: testItems,
          itemLabel: (item) => item['name'] as String,
          itemBuilder: (context, item) => ListTile(
            title: Text(item['name'] as String),
          ),
          onSearchChanged: (query) {
            lastSearchQuery = query;
          },
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test Query');
      await tester.pumpAndSettle();

      expect(lastSearchQuery, 'Test Query');
    });
  });
}
