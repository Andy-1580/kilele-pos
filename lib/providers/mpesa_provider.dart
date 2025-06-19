import 'package:kilele_pos/models/mpesa_transaction.dart';
import 'package:kilele_pos/services/mpesa_service.dart';
import 'base_provider.dart';

class MpesaProvider extends BaseProvider {
  final IMpesaService _mpesaService;
  MpesaTransaction? _currentTransaction;
  bool _isProcessing = false;

  MpesaProvider({IMpesaService? mpesaService})
      : _mpesaService = mpesaService ?? MpesaService();

  MpesaTransaction? get currentTransaction => _currentTransaction;
  bool get isProcessing => _isProcessing;

  Future<bool> initiatePayment({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    String transactionDesc = 'Payment for goods/services',
  }) async {
    return handleAsync(() async {
      _isProcessing = true;
      notifyListeners();

      try {
        _currentTransaction = await _mpesaService.initiateSTKPush(
          phoneNumber: phoneNumber,
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
    });
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
