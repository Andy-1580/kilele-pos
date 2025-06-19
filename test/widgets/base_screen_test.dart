import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilele_pos/widgets/base_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('BaseScreen Widget Tests', () {
    testWidgets('Renders with basic properties', (tester) async {
      await TestHelpers.pumpWidget(
        tester,
        const BaseScreen(
          title: 'Test Screen',
          body: Text('Test Content'),
        ),
      );

      expect(find.text('Test Screen'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('Shows loading overlay when isLoading is true', (tester) async {
      await TestHelpers.pumpWidget(
        tester,
        const BaseScreen(
          title: 'Test Screen',
          body: Text('Test Content'),
          isLoading: true,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Renders with actions', (tester) async {
      await TestHelpers.pumpWidget(
        tester,
        BaseScreen(
          title: 'Test Screen',
          body: const Text('Test Content'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
            ),
          ],
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Renders with floating action button', (tester) async {
      await TestHelpers.pumpWidget(
        tester,
        BaseScreen(
          title: 'Test Screen',
          body: const Text('Test Content'),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Renders with bottom navigation bar', (tester) async {
      await TestHelpers.pumpWidget(
        tester,
        BaseScreen(
          title: 'Test Screen',
          body: const Text('Test Content'),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
            ],
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Renders with drawer', (tester) async {
      await TestHelpers.pumpWidget(
        tester,
        BaseScreen(
          title: 'Test Screen',
          body: const Text('Test Content'),
          drawer: Drawer(
            child: ListView(
              children: const [
                DrawerHeader(
                  child: Text('Drawer Header'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('Shows back button when showBackButton is true',
        (tester) async {
      await TestHelpers.pumpWidget(
        tester,
        const BaseScreen(
          title: 'Test Screen',
          body: Text('Test Content'),
          showBackButton: true,
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('Hides back button when showBackButton is false',
        (tester) async {
      await TestHelpers.pumpWidget(
        tester,
        const BaseScreen(
          title: 'Test Screen',
          body: Text('Test Content'),
          showBackButton: false,
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });
  });
}
