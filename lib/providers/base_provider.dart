import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

abstract class BaseProvider with ChangeNotifier {
  final Logger _logger = Logger();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get hasError => _errorMessage != null;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    if (message != null) {
      _logger.e('Provider Error: $message');
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setInitialized(bool value) {
    _isInitialized = value;
    notifyListeners();
  }

  Future<T> handleAsync<T>(Future<T> Function() operation) async {
    try {
      setLoading(true);
      clearError();
      final result = await operation();
      setLoading(false);
      return result;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      rethrow;
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await handleAsync(() async {
        await onInitialize();
        setInitialized(true);
      });
    } catch (e) {
      setError('Failed to initialize: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> refresh() async {
    try {
      await handleAsync(() async {
        await onRefresh();
      });
    } catch (e) {
      setError('Failed to refresh: ${e.toString()}');
      rethrow;
    }
  }

  void dispose() {
    _logger.d('Disposing ${runtimeType.toString()}');
    super.dispose();
  }

  // Override these methods in subclasses
  Future<void> onInitialize() async {}
  Future<void> onRefresh() async {}
}
