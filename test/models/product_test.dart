import 'package:flutter_test/flutter_test.dart';
import '../lib/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('Product creates with correct values', () {
      final now = DateTime.now();
      final product = Product(
        id: '1',
        name: 'Test Product',
        description: 'Test Description',
        price: 10.0,
        costPrice: 5.0,
        barcode: '123456789',
        sku: 'SKU123',
        stockQuantity: 100,
        category: 'Test Category',
        imageUrl: 'https://example.com/image.jpg',
        isActive: true,
        createdAt: now,
        updatedAt: now,
        minStock: 10,
      );

      expect(product.id, '1');
      expect(product.name, 'Test Product');
      expect(product.description, 'Test Description');
      expect(product.price, 10.0);
      expect(product.costPrice, 5.0);
      expect(product.barcode, '123456789');
      expect(product.sku, 'SKU123');
      expect(product.stockQuantity, 100);
      expect(product.category, 'Test Category');
      expect(product.imageUrl, 'https://example.com/image.jpg');
      expect(product.isActive, true);
      expect(product.createdAt, now);
      expect(product.updatedAt, now);
      expect(product.minStock, 10);
    });

    test('Product creates with default values', () {
      final now = DateTime.now();
      final product = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        stockQuantity: 100,
        createdAt: now,
        updatedAt: now,
      );

      expect(product.description, null);
      expect(product.costPrice, null);
      expect(product.barcode, null);
      expect(product.sku, null);
      expect(product.category, null);
      expect(product.imageUrl, null);
      expect(product.isActive, true);
      expect(product.minStock, 10);
    });

    test('isLowStock returns true when quantity is at or below minStock', () {
      final now = DateTime.now();
      final product = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        stockQuantity: 10,
        createdAt: now,
        updatedAt: now,
        minStock: 10,
      );

      expect(product.isLowStock, true);
    });

    test('isOutOfStock returns true when quantity is 0', () {
      final now = DateTime.now();
      final product = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        stockQuantity: 0,
        createdAt: now,
        updatedAt: now,
      );

      expect(product.isOutOfStock, true);
    });

    test('copyWith creates new instance with updated values', () {
      final now = DateTime.now();
      final product = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        stockQuantity: 100,
        createdAt: now,
        updatedAt: now,
      );

      final updatedProduct = product.copyWith(
        name: 'Updated Product',
        price: 15.0,
        stockQuantity: 50,
      );

      expect(updatedProduct.id, product.id);
      expect(updatedProduct.name, 'Updated Product');
      expect(updatedProduct.price, 15.0);
      expect(updatedProduct.stockQuantity, 50);
      expect(updatedProduct.createdAt, product.createdAt);
      expect(updatedProduct.updatedAt.isAfter(now), true);
    });

    test('Equality operator works correctly', () {
      final now = DateTime.now();
      final product1 = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        stockQuantity: 100,
        createdAt: now,
        updatedAt: now,
      );

      final product2 = Product(
        id: '1',
        name: 'Different Name',
        price: 20.0,
        stockQuantity: 200,
        createdAt: now,
        updatedAt: now,
      );

      final product3 = Product(
        id: '2',
        name: 'Test Product',
        price: 10.0,
        stockQuantity: 100,
        createdAt: now,
        updatedAt: now,
      );

      expect(product1 == product2, true);
      expect(product1 == product3, false);
    });
  });
}
