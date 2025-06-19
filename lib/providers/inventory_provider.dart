import '../models/product.dart';
import '../services/supabase_service.dart';
import 'base_provider.dart';

class InventoryProvider extends BaseProvider {
  final SupabaseService _supabaseService = SupabaseService();
  List<Product> _products = [];
  String _searchQuery = '';

  List<Product> get products {
    if (_searchQuery.isEmpty) return _products;
    return _products
        .where((product) =>
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.barcode?.contains(_searchQuery) ?? false))
        .toList();
  }

  String get searchQuery => _searchQuery;

  List<Product> get lowStockProducts =>
      _products.where((p) => p.isLowStock).toList();
  List<Product> get outOfStockProducts =>
      _products.where((p) => p.isOutOfStock).toList();

  Future<void> loadProducts() async {
    await handleAsync(() async {
      // For now, we'll use dummy data until Supabase is set up
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay

      _products = [
        Product(
          id: '1',
          name: 'Coca Cola 500ml',
          price: 50.0,
          stockQuantity: 100,
          barcode: '123456789',
          category: 'Beverages',
          costPrice: 35.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: '2',
          name: 'Bread White',
          price: 60.0,
          stockQuantity: 5,
          barcode: '987654321',
          category: 'Bakery',
          costPrice: 45.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    });
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
}
