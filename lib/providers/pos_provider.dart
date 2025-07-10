import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/product.dart';
import 'package:uuid/uuid.dart';

class POSProvider extends ChangeNotifier {
  final List<TransactionItem> _cartItems = [];

  List<TransactionItem> get cartItems => List.unmodifiable(_cartItems);

  void addToCart(Product product) {
    final existingIndex =
        _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Update quantity of existing item
      final existingItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = TransactionItem(
        id: existingItem.id,
        product: existingItem.product,
        quantity: existingItem.quantity + 1,
        price: existingItem.price,
        discount: existingItem.discount,
      );
    } else {
      // Add new item to cart
      final newItem = TransactionItem(
        id: const Uuid().v4(),
        product: product,
        quantity: 1,
        price: product.price,
        discount: 0,
      );
      _cartItems.add(newItem);
    }
    notifyListeners();
  }

  void updateCartItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final item = _cartItems[index];
      _cartItems[index] = TransactionItem(
        id: item.id,
        product: item.product,
        quantity: quantity,
        price: item.price,
        discount: item.discount,
      );
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  double get subtotal => _cartItems.fold(0, (sum, item) => sum + item.subtotal);
  double get taxAmount => subtotal * 0.16; // Example 16% VAT
  double get total => subtotal + taxAmount;

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => _cartItems.isEmpty;

  TransactionItem? getCartItem(String productId) {
    try {
      return _cartItems.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Simulate loading today's sales data
  bool _isLoading = false;
  double _todaysSales = 0.0;
  int _todaysTransactionCount = 0;

  bool get isLoading => _isLoading;
  double get todaysSales => _todaysSales;
  int get todaysTransactionCount => _todaysTransactionCount;

  Future<void> loadTodaysSales() async {
    _isLoading = true;
    notifyListeners();
    // Simulate async fetch
    await Future.delayed(const Duration(milliseconds: 500));
    // Example: calculate from cart or fetch from backend
    _todaysSales = total;
    _todaysTransactionCount = _cartItems.length;
    _isLoading = false;
    notifyListeners();
  }
}
