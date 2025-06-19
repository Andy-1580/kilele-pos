// lib/widgets/cart_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../models/transaction.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<POSProvider>(
      builder: (context, pos, child) {
        if (pos.cartItems.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Cart is empty',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'Add products to start a transaction',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cart Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: pos.clearCart,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: pos.cartItems.length,
                itemBuilder: (context, index) {
                  final item = pos.cartItems[index];
                  return _buildCartItem(context, item, pos);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCartItem(BuildContext context, TransactionItem item, POSProvider pos) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'KSh ${item.unitPrice.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => pos.removeFromCart(item.productId),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: item.quantity > 1 
                          ? () => pos.updateQuantity(item.productId, item.quantity - 1)
                          : null,
                    ),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => pos.updateQuantity(item.productId, item.quantity + 1),
                    ),
                  ],
                ),
                Text(
                  'KSh ${item.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// lib/widgets/product_grid_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/pos_provider.dart';

class ProductGridWidget extends StatelessWidget {
  final List<Product> products;

  const ProductGridWidget({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(context, product);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _addToCart(context, product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image placeholder
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.inventory_2, size: 40, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              
              // Product name
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Price and stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KSh ${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Stock: ${product.quantity}',
                    style: TextStyle(
                      fontSize: 12,
                      color: product.quantity > 0 ? Colors.grey : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, Product product) {
    if (product.quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product is out of stock'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<POSProvider>().addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// lib/widgets/payment_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../services/mpesa_service.dart';
import '../services/etims_service.dart';

class PaymentDialog extends StatefulWidget {
  const PaymentDialog({super.key});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String _selectedPaymentMethod = 'cash';
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complete Payment',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            Consumer<POSProvider>(
              builder: (context, pos, child) {
                return Card(
                  color: Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal:'),
                            Text('KSh ${pos.subtotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tax (16%):'),
                            Text('KSh ${pos.tax.toStringAsFixed(2)}'),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('KSh ${pos.total.toStringAsFixed(2)}', 
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            const Text('Payment Method:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // Payment method selection
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Cash'),
                  value: 'cash',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('M-Pesa'),
                  value: 'mpesa',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                ),
              ],
            ),
            
            // M-Pesa phone number input
            if (_selectedPaymentMethod == 'mpesa') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '254XXXXXXXXX',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _isProcessing ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Process Payment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == 'mpesa' && _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final pos = context.read<POSProvider>();
      
      // Process payment based on selected method
      bool paymentSuccess = false;
      
      if (_selectedPaymentMethod == 'cash') {
        paymentSuccess = true; // Cash payments are immediate
      } else if (_selectedPaymentMethod == 'mpesa') {
        // Process M-Pesa payment
        final mpesaService = MpesaService();
        final response = await mpesaService.stkPush(
          phoneNumber: _phoneController.text,
          amount: pos.total,
          reference: 'POS-${DateTime.now().millisecondsSinceEpoch}',
        );
        paymentSuccess = response.success;
      }

      if (paymentSuccess) {
        // Create transaction
        final transaction = await pos.createTransaction(_selectedPaymentMethod);
        
        // Submit to eTIMS for tax compliance
        final etimsService = ETimsService();
        await etimsService.submitTransaction(transaction);
        
        // Clear cart and close dialog
        pos.clearCart();
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment processed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Payment failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}

// lib/widgets/add_product_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _lowStockController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Product',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),