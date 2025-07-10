import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onStockUpdate;
  const ProductCard(
      {super.key,
      required this.product,
      this.onEdit,
      this.onDelete,
      this.onStockUpdate});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(product.name),
        subtitle:
            Text('KES ${product.price} | Stock: ${product.stockQuantity}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            if (onDelete != null)
              IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
            if (onStockUpdate != null)
              IconButton(icon: const Icon(Icons.add), onPressed: onStockUpdate),
          ],
        ),
      ),
    );
  }
}
