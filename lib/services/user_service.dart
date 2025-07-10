import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;

class UserService {
  final _client = Supabase.instance.client;

  Future<List<app_user.User>> fetchAll() async {
    final response = await _client.from('users').select();
    return (response as List)
        .map((json) => app_user.User.fromJson(json))
        .toList();
  }

  Future<app_user.User?> fetchById(String id) async {
    final response =
        await _client.from('users').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return app_user.User.fromJson(response);
  }

  Future<app_user.User> create(app_user.User user) async {
    final response =
        await _client.from('users').insert(user.toJson()).select().single();
    return app_user.User.fromJson(response);
  }

  Future<app_user.User> update(app_user.User user) async {
    final response = await _client
        .from('users')
        .update(user.toJson())
        .eq('id', user.id)
        .select()
        .single();
    return app_user.User.fromJson(response);
  }

  Future<void> delete(String id) async {
    await _client.from('users').delete().eq('id', id);
  }
}
