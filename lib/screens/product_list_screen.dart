import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/confirmation_dialog.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  void _showProductDialog(BuildContext context, {Product? product}) {
    showDialog(
      context: context,
      builder: (dialogContext) => ProductFormDialog(
        product: product,
        onSave: (newProduct) async {
          final provider = Provider.of<ProductProvider>(context, listen: false);
          final messenger = ScaffoldMessenger.of(context);
          try {
            if (product != null) {
              await provider.updateProduct(newProduct);
              messenger.showSnackBar(
                const SnackBar(content: Text('Product updated')),
              );
            } else {
              await provider.addProduct(newProduct);
              messenger.showSnackBar(
                const SnackBar(content: Text('Product added')),
              );
            }
          } catch (e) {
            messenger.showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Product',
      message: 'Are you sure you want to delete "${product.name}"?',
      confirmText: 'Delete',
      confirmColor: Colors.red,
    );
    if (confirmed) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final messenger = ScaffoldMessenger.of(context);
      try {
        await provider.deleteProduct(product.id);
        messenger.showSnackBar(
          const SnackBar(content: Text('Product deleted')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          if (provider.products.isEmpty) {
            return const Center(child: Text('No products found.'));
          }
          return ListView.builder(
            itemCount: provider.products.length,
            itemBuilder: (context, i) {
              final product = provider.products[i];
              return ListTile(
                title: Text(product.name),
                subtitle: Text(
                    'KES ${product.price} | Stock: ${product.stockQuantity}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                      onPressed: () =>
                          _showProductDialog(context, product: product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete',
                      onPressed: () => _confirmDelete(context, product),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(context),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}
