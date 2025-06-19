import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'base_provider.dart';

class AuthProvider extends BaseProvider {
  final ISupabaseService _supabaseService;
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthProvider({ISupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService() {
    _initialize();
  }

  void _initialize() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      setLoading(false);
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    return handleAsync(() async {
      final response = await _supabaseService.signIn(email, password);
      if (response.user != null) {
        _user = response.user;
        return true;
      }
      setError('Login failed. Please check your credentials.');
      return false;
    });
  }

  Future<void> signOut() async {
    await handleAsync(() async {
      await _supabaseService.signOut();
      _user = null;
    });
  }

  @override
  void clearError() {
    setError(null);
  }
}
