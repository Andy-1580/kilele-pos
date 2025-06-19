import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kilele_pos/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Kilele POS Integration Tests', () {
    testWidgets('Complete POS workflow test', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Test login flow
      await _testLogin(tester);

      // Test dashboard navigation
      await _testDashboardNavigation(tester);

      // Test product management
      await _testProductManagement(tester);

      // Test sales transaction
      await _testSalesTransaction(tester);

      // Test reporting
      await _testReporting(tester);
    });

    testWidgets('Offline functionality test', (WidgetTester tester) async {
      // Test offline data persistence
      // Test sync when connection restored
    });

    testWidgets('Payment integration test', (WidgetTester tester) async {
      // Test M-Pesa integration
      // Test receipt generation
    });
  });
}

Future<void> _testLogin(WidgetTester tester) async {
  // Find login fields
  final emailField = find.byKey(const Key('email_field'));
  final passwordField = find.byKey(const Key('password_field'));
  final loginButton = find.byKey(const Key('login_button'));

  // Enter credentials
  await tester.enterText(emailField, 'test@example.com');
  await tester.enterText(passwordField, 'password123');

  // Tap login
  await tester.tap(loginButton);
  await tester.pumpAndSettle();

  // Verify navigation to dashboard
  expect(find.text('Kilele POS Dashboard'), findsOneWidget);
}

Future<void> _testDashboardNavigation(WidgetTester tester) async {
  // Test navigation to different screens
  await tester.tap(find.byIcon(Icons.inventory));
  await tester.pumpAndSettle();
  expect(find.text('Inventory Management'), findsOneWidget);

  await tester.pageBack();
  await tester.pumpAndSettle();
}

Future<void> _testProductManagement(WidgetTester tester) async {
  // Navigate to inventory
  await tester.tap(find.byIcon(Icons.inventory));
  await tester.pumpAndSettle();

  // Test adding a product
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  // Fill product form
  await tester.enterText(find.byKey(const Key('product_name')), 'Test Product');
  await tester.enterText(find.byKey(const Key('product_price')), '100.00');
  await tester.enterText(find.byKey(const Key('product_stock')), '50');

  // Save product
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();

  // Verify product appears in list
  expect(find.text('Test Product'), findsOneWidget);
}

Future<void> _testSalesTransaction(WidgetTester tester) async {
  // Navigate to POS
  await tester.tap(find.byIcon(Icons.point_of_sale));
  await tester.pumpAndSettle();

  // Add product to cart
  await tester.tap(find.text('Test Product').first);
  await tester.pumpAndSettle();

  // Verify product in cart
  expect(find.text('Test Product'), findsWidgets);

  // Process payment
  await tester.tap(find.text('Process Payment'));
  await tester.pumpAndSettle();

  // Select payment method
  await tester.tap(find.text('Cash'));
  await tester.pumpAndSettle();

  // Complete transaction
  await tester.tap(find.text('Complete'));
  await tester.pumpAndSettle();

  // Verify success message
  expect(find.text('Transaction completed successfully'), findsOneWidget);
}

Future<void> _testReporting(WidgetTester tester) async {
  // Navigate to reports
  await tester.tap(find.byIcon(Icons.analytics));
  await tester.pumpAndSettle();

  // Verify reports screen loads
  expect(find.text('Reports & Analytics'), findsOneWidget);

  // Test date range selection
  await tester.tap(find.text('Start Date').first);
  await tester.pumpAndSettle();

  // Select a date
  await tester.tap(find.text('15'));
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}
