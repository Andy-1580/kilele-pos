import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

class UserService {
  final _client = Supabase.instance.client;

  Future<List<User>> fetchAll() async {
    final response = await _client
        .from('users')
        .select()
        .withConverter<List<User>>(
          (data) => (data as List).map((json) => User.fromJson(json)).toList(),
        )
        .execute();
    if (response.error != null) throw response.error!;
    return response.data;
  }

  Future<User?> fetchById(String id) async {
    final response =
        await _client.from('users').select().eq('id', id).maybeSingle();
    if (response.error != null) throw response.error!;
    if (response.data == null) return null;
    return User.fromJson(response.data);
  }

  Future<User> create(User user) async {
    final response = await _client
        .from('users')
        .insert(user.toJson())
        .select()
        .maybeSingle();
    if (response.error != null) throw response.error!;
    return User.fromJson(response.data);
  }

  Future<User> update(User user) async {
    final response = await _client
        .from('users')
        .update(user.toJson())
        .eq('id', user.id)
        .select()
        .maybeSingle();
    if (response.error != null) throw response.error!;
    return User.fromJson(response.data);
  }

  Future<void> delete(String id) async {
    final response = await _client
        .from('users')
        .delete()
        .eq('id', id)
        .select()
        .maybeSingle();
    if (response.error != null) throw response.error!;
  }
}
