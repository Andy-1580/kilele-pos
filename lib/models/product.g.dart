// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      costPrice: (json['costPrice'] as num?)?.toDouble(),
      barcode: json['barcode'] as String?,
      sku: json['sku'] as String?,
      stockQuantity: (json['stockQuantity'] as num).toInt(),
      category: json['category'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      minStock: (json['minStock'] as num?)?.toInt() ?? 10,
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'costPrice': instance.costPrice,
      'barcode': instance.barcode,
      'sku': instance.sku,
      'stockQuantity': instance.stockQuantity,
      'category': instance.category,
      'imageUrl': instance.imageUrl,
      'isActive': instance.isActive,
      'minStock': instance.minStock,
    };
