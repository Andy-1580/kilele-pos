import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:kilele_pos/models/mpesa_transaction.dart';
import 'base_service.dart';

abstract class IMpesaService {
  Future<String> getAccessToken();
  Future<MpesaTransaction> initiateSTKPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  });
  Future<MpesaTransaction> queryTransactionStatus(String checkoutRequestId);
}

/// Service for handling M-Pesa (Daraja API) operations via REST.
class MpesaService extends BaseService implements IMpesaService {
  final Logger _logger = Logger();
  final String baseUrl = dotenv.env['MPESA_API_BASE_URL'] ?? '';
  final String consumerKey = dotenv.env['MPESA_CONSUMER_KEY'] ?? '';
  final String consumerSecret = dotenv.env['MPESA_CONSUMER_SECRET'] ?? '';

  static final MpesaService _instance = MpesaService._internal();
  factory MpesaService() => _instance;
  MpesaService._internal();

  /// M-Pesa API passkey (should be set in .env)
  final String _passkey = dotenv.env['MPESA_PASSKEY'] ?? '';

  /// M-Pesa shortcode (should be set in .env)
  final String _shortcode = dotenv.env['MPESA_SHORTCODE'] ?? '';

  /// Callback URL for M-Pesa (should be set in .env)
  final String _callbackUrl = dotenv.env['MPESA_CALLBACK_URL'] ?? '';

  String? _accessToken;
  DateTime? _tokenExpiry;

  @override
  Future<String> getAccessToken() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    try {
      final credentials =
          base64Encode(utf8.encode('$consumerKey:$consumerSecret'));
      final response = await http.get(
        Uri.parse('$baseUrl/oauth/v1/generate?grant_type=client_credentials'),
        headers: {
          'Authorization': 'Basic $credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _tokenExpiry =
            DateTime.now().add(Duration(seconds: data['expires_in']));
        return _accessToken!;
      } else {
        throw Exception('Failed to get access token: ${response.body}');
      }
    } catch (e) {
      _logger.e('Error getting access token', error: e);
      rethrow;
    }
  }

  @override
  Future<MpesaTransaction> initiateSTKPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    try {
      final accessToken = await getAccessToken();
      final timestamp =
          DateTime.now().toUtc().toString().replaceAll(RegExp(r'[^0-9]'), '');
      final password =
          base64Encode(utf8.encode('$_shortcode$_passkey$timestamp'));

      final response = await http.post(
        Uri.parse('$baseUrl/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'BusinessShortCode': _shortcode,
          'Password': password,
          'Timestamp': timestamp,
          'TransactionType': 'CustomerPayBillOnline',
          'Amount': amount.toStringAsFixed(0),
          'PartyA': phoneNumber,
          'PartyB': _shortcode,
          'PhoneNumber': phoneNumber,
          'CallBackURL': _callbackUrl,
          'AccountReference': accountReference,
          'TransactionDesc': transactionDesc,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MpesaTransaction(
          merchantRequestId: data['MerchantRequestID'],
          checkoutRequestId: data['CheckoutRequestID'],
          resultCode: data['ResponseCode'],
          resultDesc: data['ResponseDescription'],
          amount: amount,
          mpesaReceiptNumber: '',
          transactionDate: DateTime.now().toIso8601String(),
          phoneNumber: phoneNumber,
          accountReference: accountReference,
          transactionType: 'STKPush',
        );
      } else {
        throw Exception('Failed to initiate STK Push: ${response.body}');
      }
    } catch (e) {
      _logger.e('Error initiating STK Push', error: e);
      rethrow;
    }
  }

  @override
  Future<MpesaTransaction> queryTransactionStatus(
      String checkoutRequestId) async {
    try {
      final accessToken = await getAccessToken();
      final timestamp =
          DateTime.now().toUtc().toString().replaceAll(RegExp(r'[^0-9]'), '');
      final password =
          base64Encode(utf8.encode('$_shortcode$_passkey$timestamp'));

      final response = await http.post(
        Uri.parse('$baseUrl/mpesa/stkpushquery/v1/query'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'BusinessShortCode': _shortcode,
          'Password': password,
          'Timestamp': timestamp,
          'CheckoutRequestID': checkoutRequestId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MpesaTransaction(
          merchantRequestId: data['MerchantRequestID'],
          checkoutRequestId: data['CheckoutRequestID'],
          resultCode: data['ResultCode'],
          resultDesc: data['ResultDesc'],
          amount: 0, // This will be updated from the actual transaction
          mpesaReceiptNumber: data['MpesaReceiptNumber'] ?? '',
          transactionDate:
              data['TransactionDate'] ?? DateTime.now().toIso8601String(),
          phoneNumber: data['PhoneNumber'] ?? '',
          transactionType: 'STKPushQuery',
        );
      } else {
        throw Exception('Failed to query transaction status: ${response.body}');
      }
    } catch (e) {
      _logger.e('Error querying transaction status', error: e);
      rethrow;
    }
  }

  /// Initiates an M-Pesa STK Push payment.
  Future<Map<String, dynamic>> initiateStkPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    final url = Uri.parse('$baseUrl/mpesa/stkpush');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phone': phoneNumber,
              'amount': amount,
              'account_reference': accountReference,
              'transaction_desc': transactionDesc,
            }),
          )
          .timeout(const Duration(seconds: 30));
      _logger.i('STK Push request: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        _logger.e('STK Push failed: ${response.body}');
        throw Exception('M-Pesa STK Push failed');
      }
    } catch (e, stack) {
      _logger.e('STK Push error', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Handles M-Pesa payment confirmation/callback (if needed client-side).
  Future<void> handleConfirmation(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/mpesa/confirmation');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));
      _logger.i('Confirmation response: ${response.body}');
      if (response.statusCode != 200) {
        _logger.e('Confirmation failed: ${response.body}');
        throw Exception('M-Pesa confirmation failed');
      }
    } catch (e, stack) {
      _logger.e('Confirmation error', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
