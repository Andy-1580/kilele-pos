import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer.dart';

class CustomerService {
  final _client = Supabase.instance.client;

  Future<List<Customer>> fetchAll() async {
    try {
      final List data = await _client.from('customers').select();
      return data.map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Customer?> fetchById(String id) async {
    try {
      final Map<String, dynamic> data =
          await _client.from('customers').select().eq('id', id).single();
      return Customer.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<Customer> create(Customer customer) async {
    try {
      final Map<String, dynamic> data = await _client
          .from('customers')
          .insert(customer.toJson())
          .select()
          .single();
      return Customer.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Customer> update(Customer customer) async {
    try {
      final Map<String, dynamic> data = await _client
          .from('customers')
          .update(customer.toJson())
          .eq('id', customer.id)
          .select()
          .single();
      return Customer.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.from('customers').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
}
