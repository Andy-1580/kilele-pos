import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();
  List<POSTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<POSTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _transactions = await _service.fetchAll();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(POSTransaction tx) async {
    try {
      final newTx = await _service.create(tx);
      _transactions.add(newTx);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTransaction(POSTransaction tx) async {
    try {
      final updated = await _service.update(tx);
      final idx = _transactions.indexWhere((t) => t.id == tx.id);
      if (idx != -1) _transactions[idx] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _service.delete(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
