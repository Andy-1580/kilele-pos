import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// AuthProvider manages Supabase authentication and user profile state.
class AuthProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _profile;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get profile => _profile;
  bool get isLoggedIn => _profile != null;

  /// Register a new user and insert into users table
  Future<void> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response =
          await _client.auth.signUp(email: email, password: password);
      final user = response.user;
      if (user == null) throw Exception('Sign up failed');
      // Insert into users table
      await _client.from('users').insert({
        'auth_uid': user.id,
        'email': email,
        'name': name,
        'is_admin': false,
      });
      // Fetch profile
      await fetchProfile();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Login and fetch user profile
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _client.auth
          .signInWithPassword(email: email, password: password);
      if (response.user == null) throw Exception('Login failed');
      await fetchProfile();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Fetch user profile from users table
  Future<void> fetchProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        _profile = null;
        return;
      }
      final data =
          await _client.from('users').select().eq('auth_uid', user.id).single();
      _profile = data;
    } catch (e) {
      _profile = null;
      _error = e.toString();
    }
    notifyListeners();
  }

  /// Logout and clear profile
  Future<void> logout() async {
    await _client.auth.signOut();
    _profile = null;
    notifyListeners();
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Add this getter to expose the current user (adjust as needed for your logic)
  dynamic get user =>
      _profile; // Replace _profile with your actual user/session variable

  SupabaseClient get client => _client;
}
