import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';

class TransactionService {
  final _client = Supabase.instance.client;

  Future<List<POSTransaction>> fetchAll() async {
    try {
      final List data = await _client.from('transactions').select();
      return data.map((json) => POSTransaction.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<POSTransaction?> fetchById(String id) async {
    try {
      final Map<String, dynamic> data =
          await _client.from('transactions').select().eq('id', id).single();
      return POSTransaction.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<POSTransaction> create(POSTransaction tx) async {
    try {
      final Map<String, dynamic> data = await _client
          .from('transactions')
          .insert(tx.toJson())
          .select()
          .single();
      return POSTransaction.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<POSTransaction> update(POSTransaction tx) async {
    try {
      final Map<String, dynamic> data = await _client
          .from('transactions')
          .update(tx.toJson())
          .eq('id', tx.id)
          .select()
          .single();
      return POSTransaction.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.from('transactions').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
}
