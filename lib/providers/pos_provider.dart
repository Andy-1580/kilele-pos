import 'package:flutter/material.dart';
import '../models/product.dart';

class POSProvider extends ChangeNotifier {
  final List<Product> _cartItems = [];

  List<Product> get cartItems => List.unmodifiable(_cartItems);

  void addToCart(Product product) {
    _cartItems.add(product);
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
