import 'package:json_annotation/json_annotation.dart';

part 'mpesa_transaction.g.dart';

@JsonSerializable()
class MpesaTransaction {
  final String merchantRequestId;
  final String checkoutRequestId;
  final int resultCode;
  final String resultDesc;
  final double amount;
  final String mpesaReceiptNumber;
  final String transactionDate;
  final String phoneNumber;
  final String? accountReference;
  final String? transactionType;

  MpesaTransaction({
    required this.merchantRequestId,
    required this.checkoutRequestId,
    required this.resultCode,
    required this.resultDesc,
    required this.amount,
    required this.mpesaReceiptNumber,
    required this.transactionDate,
    required this.phoneNumber,
    this.accountReference,
    this.transactionType,
  });

  factory MpesaTransaction.fromJson(Map<String, dynamic> json) =>
      _$MpesaTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$MpesaTransactionToJson(this);

  bool get isSuccessful => resultCode == 0;
}
