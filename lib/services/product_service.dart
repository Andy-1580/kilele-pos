import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductService {
  final _client = Supabase.instance.client;

  Future<List<Product>> fetchAll() async {
    try {
      final List data = await _client.from('products').select();
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Product?> fetchById(String id) async {
    try {
      final Map<String, dynamic> data =
          await _client.from('products').select().eq('id', id).single();
      return Product.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<Product> create(Product product) async {
    try {
      final Map<String, dynamic> data = await _client
          .from('products')
          .insert(product.toJson())
          .select()
          .single();
      return Product.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> update(Product product) async {
    try {
      final Map<String, dynamic> data = await _client
          .from('products')
          .update(product.toJson())
          .eq('id', product.id)
          .select()
          .single();
      return Product.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.from('products').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
}
