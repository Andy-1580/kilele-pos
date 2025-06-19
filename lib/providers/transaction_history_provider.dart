import 'package:flutter/material.dart';
import '../models/transaction_record.dart';

/// Provider for managing transaction history (M-Pesa and eTIMS), with offline queue support.
class TransactionHistoryProvider extends ChangeNotifier {
  final List<TransactionRecord> _transactions = [];
  final List<TransactionRecord> _pendingQueue = [];
  final List<void Function(TransactionRecord)> _statusListeners = [];

  List<TransactionRecord> get transactions => List.unmodifiable(_transactions);
  List<TransactionRecord> get pendingQueue => List.unmodifiable(_pendingQueue);

  /// Adds a transaction to the history.
  void addTransaction(TransactionRecord record) {
    _transactions.insert(0, record); // Most recent first
    notifyListeners();
  }

  /// Adds a transaction to the offline queue.
  void queuePending(TransactionRecord record) {
    _pendingQueue.insert(0, record);
    notifyListeners();
  }

  /// Removes a transaction from the offline queue.
  void removeFromQueue(String id) {
    _pendingQueue.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Clears all transaction history.
  void clearHistory() {
    _transactions.clear();
    notifyListeners();
  }

  /// Updates a transaction (e.g., after retry).
  void updateTransaction(String id, TransactionRecord updated) {
    final idx = _transactions.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _transactions[idx] = updated;
      notifyListeners();
    }
  }

  /// Processes all pending transactions in the queue using the provided callback.
  /// The callback should return true if the transaction was processed successfully.
  Future<void> processQueue(
      Future<bool> Function(TransactionRecord) process) async {
    final List<String> processedIds = [];
    for (final tx in List<TransactionRecord>.from(_pendingQueue)) {
      final success = await process(tx);
      if (success) {
        processedIds.add(tx.id);
        addTransaction(tx);
      }
    }
    for (final id in processedIds) {
      removeFromQueue(id);
    }
  }

  /// Register a callback to be notified when a transaction is added.
  void addStatusListener(void Function(TransactionRecord) listener) {
    _statusListeners.add(listener);
  }

  /// Remove a previously registered status listener.
  void removeStatusListener(void Function(TransactionRecord) listener) {
    _statusListeners.remove(listener);
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (_transactions.isNotEmpty) {
      final latest = _transactions.first;
      for (final listener in _statusListeners) {
        listener(latest);
      }
    }
  }
}
