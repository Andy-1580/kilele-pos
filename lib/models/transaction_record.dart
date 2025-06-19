/// Represents a payment or invoice transaction (M-Pesa or eTIMS).
class TransactionRecord {
  /// Unique identifier for the transaction (could be UUID or timestamp).
  final String id;

  /// Type of transaction: 'mpesa' or 'etims'.
  final String type;

  /// Status: 'success', 'pending', 'failed'.
  final String status;

  /// Date and time of the transaction.
  final DateTime date;

  /// Amount involved in the transaction.
  final double amount;

  /// Additional details (e.g., phone, invoice number, API response).
  final Map<String, dynamic> details;

  /// Error message if failed.
  final String? errorMessage;

  TransactionRecord({
    required this.id,
    required this.type,
    required this.status,
    required this.date,
    required this.amount,
    required this.details,
    this.errorMessage,
  });

  /// Creates a copy with updated fields.
  TransactionRecord copyWith({
    String? id,
    String? type,
    String? status,
    DateTime? date,
    double? amount,
    Map<String, dynamic>? details,
    String? errorMessage,
  }) {
    return TransactionRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      details: details ?? this.details,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
