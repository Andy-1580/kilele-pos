import 'package:flutter/material.dart';
import '../services/mpesa_service.dart';
import 'package:logger/logger.dart';
import 'package:kilele_pos/models/mpesa_transaction.dart';
import 'base_provider.dart';

/// Provider for managing M-Pesa payment state and logic.
class MpesaProvider extends ChangeNotifier {
  final MpesaService _mpesaService;
  final Logger _logger = Logger();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _lastResponse;
  MpesaTransaction? _currentTransaction;
  bool _isProcessing = false;

  MpesaProvider(this._mpesaService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get lastResponse => _lastResponse;
  MpesaTransaction? get currentTransaction => _currentTransaction;
  bool get isProcessing => _isProcessing;

  /// Initiates a payment via M-Pesa STK Push.
  Future<void> initiatePayment({
    required String phone,
    required double amount,
    String accountReference = 'POS',
    String transactionDesc = 'POS Sale',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _mpesaService.initiateStkPush(
        phoneNumber: phone,
        amount: amount,
        accountReference: accountReference,
        transactionDesc: transactionDesc,
      );
      _lastResponse = response;
      _logger.i('M-Pesa payment success: $response');

      _isProcessing = true;
      notifyListeners();

      try {
        _currentTransaction = await _mpesaService.initiateSTKPush(
          phoneNumber: phone,
          amount: amount,
          accountReference: accountReference,
          transactionDesc: transactionDesc,
        );

        if (_currentTransaction?.isSuccessful ?? false) {
          // Start polling for transaction status
          _pollTransactionStatus(_currentTransaction!.checkoutRequestId);
        }

        return _currentTransaction?.isSuccessful ?? false;
      } finally {
        _isProcessing = false;
        notifyListeners();
      }
    } catch (e, stack) {
      _errorMessage = e.toString();
      _logger.e('M-Pesa payment failed', error: e, stackTrace: stack);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _pollTransactionStatus(String checkoutRequestId) async {
    const maxAttempts = 10;
    const delaySeconds = 5;
    var attempts = 0;

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: delaySeconds));

      try {
        final status =
            await _mpesaService.queryTransactionStatus(checkoutRequestId);
        _currentTransaction = status;
        notifyListeners();

        if (status.isSuccessful || status.resultCode != 1032) {
          break;
        }
      } catch (e) {
        logError('Error polling transaction status', e);
        break;
      }

      attempts++;
    }
  }

  void clearTransaction() {
    _currentTransaction = null;
    notifyListeners();
  }
}
