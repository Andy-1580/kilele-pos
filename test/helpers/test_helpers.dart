import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kilele_pos/services/supabase_service.dart';
import 'package:kilele_pos/providers/auth_provider.dart';
import 'package:kilele_pos/providers/lib/providers/lib/providers/pos_provider.dart';
import 'package:kilele_pos/providers/inventory_provider.dart';

@GenerateMocks([SupabaseClient, SupabaseService])
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockAuthState extends Mock implements AuthState {}

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

class TestHelpers {
  static Widget createTestableWidget({
    required Widget child,
    List<ChangeNotifierProvider> providers = const [],
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => POSProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ...providers,
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  static Future<void> pumpWidget(
    WidgetTester tester,
    Widget widget, {
    List<ChangeNotifierProvider> providers = const [],
  }) async {
    await tester.pumpWidget(
      createTestableWidget(
        child: widget,
        providers: providers,
      ),
    );
    await tester.pumpAndSettle();
  }

  static Future<void> loginUser(
    WidgetTester tester, {
    String email = 'test@example.com',
    String password = 'password123',
  }) async {
    final emailField = find.byKey(const Key('email_field'));
    final passwordField = find.byKey(const Key('password_field'));
    final loginButton = find.byKey(const Key('login_button'));

    await tester.enterText(emailField, email);
    await tester.enterText(passwordField, password);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
  }

  static Future<void> addProductToCart(
    WidgetTester tester, {
    required String productName,
    int quantity = 1,
  }) async {
    final productCard = find.text(productName);
    await tester.tap(productCard);
    await tester.pumpAndSettle();

    if (quantity > 1) {
      final addButton = find.byIcon(Icons.add);
      for (var i = 1; i < quantity; i++) {
        await tester.tap(addButton);
        await tester.pumpAndSettle();
      }
    }
  }

  static Future<void> searchProduct(
    WidgetTester tester, {
    required String query,
  }) async {
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, query);
    await tester.pumpAndSettle();
  }
}
