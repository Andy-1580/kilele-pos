import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/transaction.dart';

class POSProvider with ChangeNotifier {
  final List<TransactionItem> _cartItems = [];
  double _discount = 0;
  String _paymentMethod = 'cash';
  String? _customerPhone;
  String? _customerName;

  List<TransactionItem> get cartItems => _cartItems;
  double get discount => _discount;
  String get paymentMethod => _paymentMethod;
  String? get customerPhone => _customerPhone;
  String? get customerName => _customerName;

  double get subtotal => _cartItems.fold(0, (sum, item) => sum + item.subtotal);
  double get tax => subtotal * 0.16; // 16% VAT
  double get total => subtotal + tax - _discount;
  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      // Update existing item
      final existingItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = TransactionItem(
        id: existingItem.id,
        product: product,
        quantity: existingItem.quantity + quantity,
        price: product.price,
      );
    } else {
      // Add new item
      _cartItems.add(TransactionItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: quantity,
        price: product.price,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(String itemId) {
    _cartItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(itemId);
      return;
    }

    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = _cartItems[index];
      _cartItems[index] = TransactionItem(
        id: item.id,
        product: item.product,
        quantity: quantity,
        price: item.price,
      );
      notifyListeners();
    }
  }

  void setDiscount(double discount) {
    _discount = discount;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setCustomerInfo(String? phone, String? name) {
    _customerPhone = phone;
    _customerName = name;
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _discount = 0;
    _paymentMethod = 'cash';
    _customerPhone = null;
    _customerName = null;
    notifyListeners();
  }
}
