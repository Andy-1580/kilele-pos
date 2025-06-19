import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';
import 'base_provider.dart';

class InventoryProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  String _categoryFilter = 'all';
  String _stockFilter = 'all';
  String _sortBy = 'name';
  bool _sortAsc = true;

  // For analytics
  final Map<String, int> _salesCount = {};

  List<Product> get filteredProducts => List.unmodifiable(_filteredProducts);
  List<String> get categories => [
        'all',
        ...{for (final p in _allProducts) p.category ?? ''}..remove('')
      ];

  List<Product> get products {
    if (_searchQuery.isEmpty) return _filteredProducts;
    return _filteredProducts
        .where((product) =>
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.barcode?.contains(_searchQuery) ?? false))
        .toList();
  }

  String get searchQuery => _searchQuery;

  List<Product> get lowStockProducts =>
      _filteredProducts.where((p) => p.isLowStock).toList();
  List<Product> get outOfStockProducts =>
      _filteredProducts.where((p) => p.isOutOfStock).toList();

  void loadProducts([List<Product>? products]) {
    if (products != null) {
      _allProducts = products;
    }
    _applyFilters();
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByCategory(String category) {
    _categoryFilter = category;
    _applyFilters();
  }

  void filterByStock(String stock) {
    _stockFilter = stock;
    _applyFilters();
  }

  void sortBy(String sort, {bool asc = true}) {
    _sortBy = sort;
    _sortAsc = asc;
    _applyFilters();
  }

  void recordSale(String productId) {
    _salesCount[productId] = (_salesCount[productId] ?? 0) + 1;
  }

  int getSalesCount(String productId) => _salesCount[productId] ?? 0;

  void _applyFilters() {
    _filteredProducts = _allProducts.where((p) {
      final matchesQuery = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _categoryFilter == 'all' || (p.category ?? '') == _categoryFilter;
      final matchesStock = _stockFilter == 'all' ||
          (_stockFilter == 'in' && p.stockQuantity > 0) ||
          (_stockFilter == 'out' && p.stockQuantity == 0);
      return matchesQuery && matchesCategory && matchesStock;
    }).toList();
    _filteredProducts.sort((a, b) {
      int cmp = 0;
      switch (_sortBy) {
        case 'name':
          cmp = a.name.compareTo(b.name);
          break;
        case 'price':
          cmp = a.price.compareTo(b.price);
          break;
        case 'stock':
          cmp = a.stockQuantity.compareTo(b.stockQuantity);
          break;
        case 'sales':
          cmp = getSalesCount(a.id).compareTo(getSalesCount(b.id));
          break;
      }
      return _sortAsc ? cmp : -cmp;
    });
    notifyListeners();
  }

  Product? findProductByBarcode(String barcode) {
    try {
      return _filteredProducts
          .firstWhere((product) => product.barcode == barcode);
    } catch (e) {
      return null;
    }
  }
}
