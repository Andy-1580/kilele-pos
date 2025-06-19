import 'dart:convert';
import 'package:http/http.dart' as http;
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

class MpesaService extends BaseService implements IMpesaService {
  static final MpesaService _instance = MpesaService._internal();
  factory MpesaService() => _instance;
  MpesaService._internal();

  // TODO: Move these to environment variables or secure storage
  static const String _baseUrl = 'https://sandbox.safaricom.co.ke';
  static const String _consumerKey = 'YOUR_CONSUMER_KEY';
  static const String _consumerSecret = 'YOUR_CONSUMER_SECRET';
  static const String _passkey = 'YOUR_PASSKEY';
  static const String _shortcode = 'YOUR_SHORTCODE';
  static const String _callbackUrl = 'YOUR_CALLBACK_URL';

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
          base64Encode(utf8.encode('$_consumerKey:$_consumerSecret'));
      final response = await http.get(
        Uri.parse('$_baseUrl/oauth/v1/generate?grant_type=client_credentials'),
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
      logError('Error getting access token', e);
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
        Uri.parse('$_baseUrl/mpesa/stkpush/v1/processrequest'),
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
      logError('Error initiating STK Push', e);
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
        Uri.parse('$_baseUrl/mpesa/stkpushquery/v1/query'),
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
      logError('Error querying transaction status', e);
      rethrow;
    }
  }
}
