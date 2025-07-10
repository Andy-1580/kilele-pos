import 'order_status.dart';

/// Order model for Kilele POS.
class Order {
  final String id;
  final OrderStatus status;
  final double total;
  final DateTime date;

  const Order({
    required this.id,
    required this.status,
    required this.total,
    required this.date,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        status: OrderStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
          orElse: () => OrderStatus.pending,
        ),
        total: (json['total'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status.toString().split('.').last,
        'total': total,
        'date': date.toIso8601String(),
      };
}
