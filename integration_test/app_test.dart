import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kilele_pos/main.dart' as app;
import '../test/helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('App launches and shows login screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });

    testWidgets('User can login successfully', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.loginUser(tester);
      await tester.pumpAndSettle();

      expect(find.byType(MainDashboard), findsOneWidget);
    });

    testWidgets('User can navigate to POS screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.loginUser(tester);
      await tester.pumpAndSettle();

      final posButton = find.byIcon(Icons.point_of_sale);
      await tester.tap(posButton);
      await tester.pumpAndSettle();

      expect(find.byType(POSScreen), findsOneWidget);
    });

    testWidgets('User can search and add products to cart', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.loginUser(tester);
      await tester.pumpAndSettle();

      // Navigate to POS screen
      final posButton = find.byIcon(Icons.point_of_sale);
      await tester.tap(posButton);
      await tester.pumpAndSettle();

      // Search for a product
      await TestHelpers.searchProduct(tester, query: 'Test Product');
      await tester.pumpAndSettle();

      // Add product to cart
      await TestHelpers.addProductToCart(tester, productName: 'Test Product');
      await tester.pumpAndSettle();

      expect(find.byType(CartWidget), findsOneWidget);
      expect(find.text('Test Product'), findsOneWidget);
    });

    testWidgets('User can navigate to inventory screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.loginUser(tester);
      await tester.pumpAndSettle();

      final inventoryButton = find.byIcon(Icons.inventory);
      await tester.tap(inventoryButton);
      await tester.pumpAndSettle();

      expect(find.byType(InventoryScreen), findsOneWidget);
    });

    testWidgets('User can search products in inventory', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.loginUser(tester);
      await tester.pumpAndSettle();

      // Navigate to inventory screen
      final inventoryButton = find.byIcon(Icons.inventory);
      await tester.tap(inventoryButton);
      await tester.pumpAndSettle();

      // Search for a product
      await TestHelpers.searchProduct(tester, query: 'Test Product');
      await tester.pumpAndSettle();

      expect(find.byType(SearchableList), findsOneWidget);
    });

    testWidgets('User can logout', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.loginUser(tester);
      await tester.pumpAndSettle();

      // Open profile menu
      final profileMenu = find.byType(PopupMenuButton);
      await tester.tap(profileMenu);
      await tester.pumpAndSettle();

      // Tap logout
      final logoutButton = find.text('Logout');
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
