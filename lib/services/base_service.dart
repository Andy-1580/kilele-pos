import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BaseService {
  final Logger _logger = Logger();
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  void logInfo(String message) {
    _logger.i(message);
  }

  void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void logWarning(String message) {
    _logger.w(message);
  }

  void logDebug(String message) {
    _logger.d(message);
  }

  Future<T> handleAsync<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      logError('Operation failed', e, stackTrace);
      rethrow;
    }
  }

  Future<List<T>> fetchAll<T>({
    required String table,
    required T Function(Map<String, dynamic>) fromJson,
    String? orderBy,
    bool descending = false,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from(table).select();

      if (orderBy != null) {
        query = query.order(orderBy, ascending: !descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      return response.map((json) => fromJson(json)).toList();
    } catch (e, stackTrace) {
      logError('Failed to fetch from $table', e, stackTrace);
      rethrow;
    }
  }

  Future<T?> fetchOne<T>({
    required String table,
    required String id,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _client.from(table).select().eq('id', id).single();

      return fromJson(response);
    } catch (e, stackTrace) {
      logError('Failed to fetch one from $table', e, stackTrace);
      rethrow;
    }
  }

  Future<T> create<T>({
    required String table,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _client.from(table).insert(data).select().single();

      return fromJson(response);
    } catch (e, stackTrace) {
      logError('Failed to create in $table', e, stackTrace);
      rethrow;
    }
  }

  Future<T> update<T>({
    required String table,
    required String id,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response =
          await _client.from(table).update(data).eq('id', id).select().single();

      return fromJson(response);
    } catch (e, stackTrace) {
      logError('Failed to update in $table', e, stackTrace);
      rethrow;
    }
  }

  Future<void> delete({
    required String table,
    required String id,
  }) async {
    try {
      await _client.from(table).delete().eq('id', id);
    } catch (e, stackTrace) {
      logError('Failed to delete from $table', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> exists({
    required String table,
    required String id,
  }) async {
    try {
      final response =
          await _client.from(table).select('id').eq('id', id).maybeSingle();

      return response != null;
    } catch (e, stackTrace) {
      logError('Failed to check existence in $table', e, stackTrace);
      rethrow;
    }
  }
}
