import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'transaction.g.dart';

@JsonSerializable()
class POSTransaction {
  final String id;
  final List<TransactionItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String paymentMethod;
  final String? paymentReference;
  final String? customerPhone;
  final String? customerName;
  final String cashierId;
  final String cashierName;
  final DateTime createdAt;
  final String status;
  final String? etimsReceiptNumber;
  final String? etimsSignature;
  final bool isEtimsSubmitted;

  POSTransaction({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.tax,
    this.discount = 0,
    required this.total,
    required this.paymentMethod,
    this.paymentReference,
    this.customerPhone,
    this.customerName,
    required this.cashierId,
    required this.cashierName,
    required this.createdAt,
    this.status = 'completed',
    this.etimsReceiptNumber,
    this.etimsSignature,
    this.isEtimsSubmitted = false,
  });

  factory POSTransaction.fromJson(Map<String, dynamic> json) =>
      _$POSTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$POSTransactionToJson(this);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalProfit => items.fold(0, (sum, item) => sum + item.profit);
}

@JsonSerializable()
class TransactionItem {
  final String id;
  final Product product;
  final int quantity;
  final double price;
  final double discount;

  TransactionItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    this.discount = 0,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) =>
      _$TransactionItemFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionItemToJson(this);

  double get subtotal => quantity * price;
  double get total => subtotal - discount;
  double get profit => total - (quantity * (product.costPrice ?? 0));
}
