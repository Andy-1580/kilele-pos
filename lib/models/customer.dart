import 'package:json_annotation/json_annotation.dart';

part 'customer.g.dart';

/// Customer model for Kilele POS.
@JsonSerializable()
class Customer {
  /// Unique identifier for the customer.
  final String id;

  /// Customer's full name.
  final String name;

  /// Customer's email address.
  final String? email;

  /// Customer's phone number.
  final String? phone;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a Customer from a JSON map.
  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);

  /// Converts the Customer to a JSON map.
  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}
