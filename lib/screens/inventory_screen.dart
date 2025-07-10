import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/product_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    Provider.of<InventoryProvider>(context, listen: false).loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportInventory,
          ),
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: _importInventory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search products...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (query) {
                          Provider.of<InventoryProvider>(context, listen: false)
                              .searchProducts(query);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Consumer<InventoryProvider>(
                        builder: (context, inventoryProvider, child) {
                          return DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            items: ['All', ...inventoryProvider.categories]
                                .map((category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedCategory = value!);
                              inventoryProvider.filterByCategory(
                                value == 'All' ? '' : value!,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _sortBy,
                        decoration: const InputDecoration(
                          labelText: 'Sort by',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'name', child: Text('Name')),
                          DropdownMenuItem(
                              value: 'price', child: Text('Price')),
                          DropdownMenuItem(
                              value: 'stock', child: Text('Stock')),
                          DropdownMenuItem(
                              value: 'category', child: Text('Category')),
                        ],
                        onChanged: (value) {
                          setState(() => _sortBy = value!);
                          Provider.of<InventoryProvider>(context, listen: false)
                              .sortProducts(value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Summary Cards
                Consumer<InventoryProvider>(
                  builder: (context, inventoryProvider, child) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Products',
                            inventoryProvider.products.length.toString(),
                            Icons.inventory,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            'Low Stock',
                            inventoryProvider.lowStockItems.length.toString(),
                            Icons.warning,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            'Out of Stock',
                            inventoryProvider.outOfStockItems.length.toString(),
                            Icons.error,
                            Colors.red,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Value',
                            'KES ${inventoryProvider.totalInventoryValue.toStringAsFixed(2)}',
                            Icons.attach_money,
                            Colors.green,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (context, inventoryProvider, child) {
                if (inventoryProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (inventoryProvider.filteredProducts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: inventoryProvider.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = inventoryProvider.filteredProducts[index];
                    return ProductCard(
                      product: product,
                      onEdit: () => _editProduct(product),
                      onDelete: () => _deleteProduct(product),
                      onStockUpdate: () => _updateStock(product),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'Add Product',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addProduct() {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        onSave: (product) {
          Provider.of<InventoryProvider>(context, listen: false)
              .addProduct(product);
        },
      ),
    );
  }

  void _editProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        product: product,
        onSave: (updatedProduct) {
          Provider.of<InventoryProvider>(context, listen: false)
              .updateProduct(updatedProduct);
        },
      ),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<InventoryProvider>(context, listen: false)
                  .deleteProduct(product.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _updateStock(Product product) {
    final TextEditingController stockController =
        TextEditingController(text: product.stockQuantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock - ${product.name}'),
        content: TextField(
          controller: stockController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'New Stock Quantity',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newStock = int.tryParse(stockController.text) ?? 0;
              Provider.of<InventoryProvider>(context, listen: false)
                  .updateProductStock(product.id, newStock);
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _exportInventory() {
    Provider.of<InventoryProvider>(context, listen: false)
        .exportInventory()
        .then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory exported successfully')),
      );
    }).catchError((error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $error')),
      );
    });
  }

  void _importInventory() {
    Provider.of<InventoryProvider>(context, listen: false)
        .importInventory()
        .then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory imported successfully')),
      );
    }).catchError((error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $error')),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
