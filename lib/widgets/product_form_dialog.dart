import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductFormDialog extends StatelessWidget {
  final Product? product;
  final void Function(Product) onSave;
  const ProductFormDialog({super.key, this.product, required this.onSave});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(product == null ? 'Add Product' : 'Edit Product'),
      content: const Text('Product form goes here.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Call onSave with a dummy product for now
            onSave(product ??
                Product(
                    id: '',
                    name: '',
                    price: 0,
                    stockQuantity: 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now()));
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
