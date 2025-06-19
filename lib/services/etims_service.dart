import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// Service for handling KRA eTIMS operations via REST.
class EtimsService {
  final Logger _logger = Logger();
  final String baseUrl = dotenv.env['ETIMS_API_BASE_URL'] ?? '';
  final String apiKey = dotenv.env['ETIMS_API_KEY'] ?? '';

  /// Authenticates with eTIMS and returns a token.
  Future<String> authenticate() async {
    final url = Uri.parse('$baseUrl/etims/auth');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'x-api-key': apiKey},
      ).timeout(const Duration(seconds: 30));
      _logger.i('eTIMS Auth response: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['token'] as String;
      } else {
        _logger.e('eTIMS Auth failed: ${response.body}');
        throw Exception('eTIMS authentication failed');
      }
    } catch (e, stack) {
      _logger.e('eTIMS Auth error', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Submits an invoice to eTIMS.
  Future<Map<String, dynamic>> submitInvoice({
    required String token,
    required Map<String, dynamic> invoiceData,
  }) async {
    final url = Uri.parse('$baseUrl/etims/invoice');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'x-api-key': apiKey,
            },
            body: jsonEncode(invoiceData),
          )
          .timeout(const Duration(seconds: 30));
      _logger.i('eTIMS Invoice response: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        _logger.e('eTIMS Invoice failed: ${response.body}');
        throw Exception('eTIMS invoice submission failed');
      }
    } catch (e, stack) {
      _logger.e('eTIMS Invoice error', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
