// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

POSTransaction _$POSTransactionFromJson(Map<String, dynamic> json) =>
    POSTransaction(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => TransactionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      paymentReference: json['paymentReference'] as String?,
      customerPhone: json['customerPhone'] as String?,
      customerName: json['customerName'] as String?,
      cashierId: json['cashierId'] as String,
      cashierName: json['cashierName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String? ?? 'completed',
      etimsReceiptNumber: json['etimsReceiptNumber'] as String?,
      etimsSignature: json['etimsSignature'] as String?,
      isEtimsSubmitted: json['isEtimsSubmitted'] as bool? ?? false,
    );

Map<String, dynamic> _$POSTransactionToJson(POSTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'items': instance.items,
      'subtotal': instance.subtotal,
      'tax': instance.tax,
      'discount': instance.discount,
      'total': instance.total,
      'paymentMethod': instance.paymentMethod,
      'paymentReference': instance.paymentReference,
      'customerPhone': instance.customerPhone,
      'customerName': instance.customerName,
      'cashierId': instance.cashierId,
      'cashierName': instance.cashierName,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': instance.status,
      'etimsReceiptNumber': instance.etimsReceiptNumber,
      'etimsSignature': instance.etimsSignature,
      'isEtimsSubmitted': instance.isEtimsSubmitted,
    };

TransactionItem _$TransactionItemFromJson(Map<String, dynamic> json) =>
    TransactionItem(
      id: json['id'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$TransactionItemToJson(TransactionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product': instance.product,
      'quantity': instance.quantity,
      'price': instance.price,
      'discount': instance.discount,
    };
