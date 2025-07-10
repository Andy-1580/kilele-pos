import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import 'package:kilele_pos/utils/theme.dart';
import 'package:intl/intl.dart';

class RecentTransactions extends StatelessWidget {
  final List<Order> transactions;
  final Function(Order) onTransactionTap;

  const RecentTransactions({
    super.key,
    required this.transactions,
    required this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No recent transactions',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return ListTile(
          onTap: () => onTransactionTap(transaction),
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(transaction.status).withAlpha(25),
            child: Icon(
              _getStatusIcon(transaction.status),
              color: _getStatusColor(transaction.status),
            ),
          ),
          title: Text(
            'Order #${transaction.id}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          subtitle: Text(
            DateFormat('MMM d, y • h:mm a').format(transaction.date),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${transaction.total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              Text(
                transaction.status.name.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(transaction.status),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}
