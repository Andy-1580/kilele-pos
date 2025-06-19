import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'product.g.dart';

@JsonSerializable()
class Product extends BaseModel {
  final String name;
  final String? description;
  final double price;
  final double? costPrice;
  final String? barcode;
  final String? sku;
  final int stockQuantity;
  final String? category;
  final String? imageUrl;
  final bool isActive;
  final int minStock;

  Product({
    required super.id,
    required this.name,
    this.description,
    required this.price,
    this.costPrice,
    this.barcode,
    this.sku,
    required this.stockQuantity,
    this.category,
    this.imageUrl,
    this.isActive = true,
    required super.createdAt,
    required super.updatedAt,
    this.minStock = 10,
  }) : super();

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  bool get isLowStock => stockQuantity <= minStock;
  bool get isOutOfStock => stockQuantity <= 0;

  Product copyWith({
    String? name,
    String? description,
    double? price,
    double? costPrice,
    String? barcode,
    String? sku,
    int? stockQuantity,
    String? category,
    String? imageUrl,
    bool? isActive,
    int? minStock,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      minStock: minStock ?? this.minStock,
    );
  }
}
