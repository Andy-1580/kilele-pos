import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';

class InventoryProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Product> get products {
    if (_searchQuery.isEmpty) return _products;
    return _products
        .where((product) =>
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.barcode?.contains(_searchQuery) ?? false))
        .toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<Product> get lowStockProducts =>
      _products.where((p) => p.isLowStock).toList();
  List<Product> get outOfStockProducts =>
      _products.where((p) => p.isOutOfStock).toList();

  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // For now, we'll use dummy data until Supabase is set up
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay

      _products = [
        Product(
          id: '1',
          name: 'Coca Cola 500ml',
          price: 50.0,
          quantity: 100,
          barcode: '123456789',
          category: 'Beverages',
          costPrice: 35.0,
          minStock: 10,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: '2',
          name: 'Bread White',
          price: 60.0,
          quantity: 5,
          barcode: '987654321',
          category: 'Bakery',
          costPrice: 45.0,
          minStock: 10,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Product? findProductByBarcode(String barcode) {
    try {
      return _products.firstWhere((product) => product.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
