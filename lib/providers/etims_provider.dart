import 'package:flutter/material.dart';
import '../services/etims_service.dart';
import 'package:logger/logger.dart';

/// Provider for managing eTIMS invoice state and logic.
class EtimsProvider extends ChangeNotifier {
  final EtimsService _etimsService;
  final Logger _logger = Logger();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _lastResponse;

  EtimsProvider(this._etimsService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get lastResponse => _lastResponse;

  /// Submits an invoice to eTIMS.
  Future<void> submitInvoice(Map<String, dynamic> transaction) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final token = await _etimsService.authenticate();
      final response = await _etimsService.submitInvoice(
        token: token,
        invoiceData: transaction,
      );
      _lastResponse = response;
      _logger.i('eTIMS invoice success: $response');
    } catch (e, stack) {
      _errorMessage = e.toString();
      _logger.e('eTIMS invoice failed', error: e, stackTrace: stack);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
