import 'package:supabase_flutter/supabase_flutter.dart';
import 'base_service.dart';

abstract class ISupabaseService {
  User? get currentUser;
  bool get isAuthenticated;
  Future<AuthResponse> signIn(String email, String password);
  Future<void> signOut();
  Future<bool> testConnection();
  Future<List<Map<String, dynamic>>> getProducts();
  Future<void> updateProduct(String id, Map<String, dynamic> data);
}

class SupabaseService extends BaseService implements ISupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // Authentication
  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  bool get isAuthenticated => currentUser != null;

  @override
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      logInfo('User signed in: ${response.user?.email}');
      return response;
    } catch (e) {
      logError('Sign in error', e);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      logInfo('User signed out');
    } catch (e) {
      logError('Sign out error', e);
      rethrow;
    }
  }

  // Basic connection test
  @override
  Future<bool> testConnection() async {
    try {
      await _client.from('products').select('id').limit(1);
      logInfo('Connection test successful');
      return true;
    } catch (e) {
      logError('Connection test failed', e);
      return false;
    }
  }

  // Database operations
  @override
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await _client.from('products').select();
      logInfo('Products fetched successfully');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logError('Failed to fetch products', e);
      rethrow;
    }
  }

  @override
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await _client.from('products').update(data).eq('id', id);
      logInfo('Product updated successfully: $id');
    } catch (e) {
      logError('Failed to update product: $id', e);
      rethrow;
    }
  }
}
