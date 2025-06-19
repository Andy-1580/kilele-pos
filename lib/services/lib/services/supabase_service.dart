import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;
  final Logger _logger = Logger();

  // Authentication
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _logger.i('User signed in: ${response.user?.email}');
      return response;
    } catch (e) {
      _logger.e('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _logger.i('User signed out');
    } catch (e) {
      _logger.e('Sign out error: $e');
      rethrow;
    }
  }

  // Basic connection test
  Future<bool> testConnection() async {
    try {
      await _client.from('products').select('id').limit(1);
      return true;
    } catch (e) {
      _logger.e('Connection test failed: $e');
      return false;
    }
  }
}
