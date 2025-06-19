import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import '../widgets/product_search.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/payment_dialog.dart';
import '../providers/mpesa_provider.dart';
import '../providers/etims_provider.dart';
import '../screens/transaction_history_screen.dart';
import '../providers/transaction_history_provider.dart';
import '../models/transaction_record.dart';
import 'package:uuid/uuid.dart';
import '../widgets/offline_blocker.dart';
import '../providers/connectivity_provider.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<InventoryProvider>(context, listen: false).loadProducts();
    // Register transaction status listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final historyProvider =
          Provider.of<TransactionHistoryProvider>(context, listen: false);
      historyProvider.addStatusListener(_onTransactionStatus);
    });
  }

  void _onTransactionStatus(TransactionRecord tx) {
    if (!mounted) return;
    final color = tx.status == 'success' ? Colors.green : Colors.red;
    final msg = tx.status == 'success'
        ? 'Transaction successful: ${tx.type.toUpperCase()} KES ${tx.amount.toStringAsFixed(2)}'
        : 'Transaction failed: ${tx.type.toUpperCase()}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MpesaProvider(MpesaService())),
        ChangeNotifierProvider(create: (_) => EtimsProvider(EtimsService())),
        ChangeNotifierProvider(create: (_) => TransactionHistoryProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Point of Sale'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            actions: [
              Consumer<POSProvider>(
                builder: (context, posProvider, child) {
                  return IconButton(
                    icon: Badge(
                      label: Text(posProvider.cartItems.length.toString()),
                      child: const Icon(Icons.shopping_cart),
                    ),
                    onPressed: () => _showCartDetails(),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Transaction History',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const TransactionHistoryScreen()),
                  );
                },
              ),
            ],
          ),
          body: Row(
            children: [
              // Product Selection Panel
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText: 'Search Products',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (query) {
                              Provider.of<InventoryProvider>(context,
                                      listen: false)
                                  .searchProducts(query);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _barcodeController,
                            decoration: const InputDecoration(
                              labelText: 'Scan/Enter Barcode',
                              prefixIcon: Icon(Icons.qr_code_scanner),
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (barcode) =>
                                _addProductByBarcode(barcode),
                          ),
                        ],
                      ),
                    ),

                    // Product Grid
                    Expanded(
                      child: Consumer<InventoryProvider>(
                        builder: (context, inventoryProvider, child) {
                          if (inventoryProvider.isLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final products = inventoryProvider.filteredProducts;

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _buildProductCard(product);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Cart Panel
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: const Border(left: BorderSide(color: Colors.grey)),
                  ),
                  child: Column(
                    children: [
                      // Cart Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Theme.of(context).primaryColor,
                        child: const Row(
                          children: [
                            Icon(Icons.shopping_cart, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Current Sale',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Cart Items
                      Expanded(
                        child: Consumer<POSProvider>(
                          builder: (context, posProvider, child) {
                            if (posProvider.cartItems.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No items in cart',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: posProvider.cartItems.length,
                              itemBuilder: (context, index) {
                                final cartItem = posProvider.cartItems[index];
                                return CartItemCard(
                                  cartItem: cartItem,
                                  onQuantityChanged: (newQuantity) {
                                    posProvider.updateCartItemQuantity(
                                      cartItem.product.id,
                                      newQuantity,
                                    );
                                  },
                                  onRemove: () {
                                    posProvider
                                        .removeFromCart(cartItem.product.id);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Cart Summary and Checkout
                      Consumer<POSProvider>(
                        builder: (context, posProvider, child) {
                          return Consumer2<MpesaProvider, EtimsProvider>(
                            builder:
                                (context, mpesaProvider, etimsProvider, _) {
                              final isMpesaLoading = mpesaProvider.isLoading;
                              final isEtimsLoading = etimsProvider.isLoading;
                              final cartIsEmpty = posProvider.cartItems.isEmpty;
                              return OfflineBlocker(
                                isOnline: Provider.of<ConnectivityProvider>(
                                        context,
                                        listen: false)
                                    .isOnline,
                                message: 'M-Pesa payment unavailable offline',
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                        top: BorderSide(color: Colors.grey)),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Subtotal:'),
                                          Text(
                                              'KES ${posProvider.subtotal.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Tax:'),
                                          Text(
                                              'KES ${posProvider.taxAmount.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Total:',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              'KES ${posProvider.total.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green)),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Payment/Invoice Buttons
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OfflineBlocker(
                                              isOnline: Provider.of<
                                                          ConnectivityProvider>(
                                                      context,
                                                      listen: false)
                                                  .isOnline,
                                              message:
                                                  'M-Pesa payment unavailable offline',
                                              child: ElevatedButton.icon(
                                                icon: isMpesaLoading
                                                    ? const SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child:
                                                            CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: Colors
                                                                    .white))
                                                    : const Icon(
                                                        Icons.phone_android),
                                                label: const Text(
                                                    'Pay with M-Pesa'),
                                                onPressed: cartIsEmpty ||
                                                        isMpesaLoading
                                                    ? null
                                                    : () async {
                                                        final phone =
                                                            await _promptPhoneNumber(
                                                                context);
                                                        if (phone == null)
                                                          return;
                                                        final confirm =
                                                            await _showConfirmationDialog(
                                                                context,
                                                                'Confirm M-Pesa Payment',
                                                                'Send KES ${posProvider.total.toStringAsFixed(2)} to $phone?');
                                                        if (!confirm) return;
                                                        final historyProvider =
                                                            Provider.of<
                                                                    TransactionHistoryProvider>(
                                                                context,
                                                                listen: false);
                                                        final uuid =
                                                            const Uuid();
                                                        await mpesaProvider
                                                            .initiatePayment(
                                                          phone: phone,
                                                          amount:
                                                              posProvider.total,
                                                        );
                                                        historyProvider
                                                            .addTransaction(
                                                                TransactionRecord(
                                                          id: uuid.v4(),
                                                          type: 'mpesa',
                                                          status: mpesaProvider
                                                                      .errorMessage ==
                                                                  null
                                                              ? 'success'
                                                              : 'failed',
                                                          date: DateTime.now(),
                                                          amount:
                                                              posProvider.total,
                                                          details: mpesaProvider
                                                                  .lastResponse ??
                                                              {},
                                                          errorMessage:
                                                              mpesaProvider
                                                                  .errorMessage,
                                                        ));
                                                        if (mpesaProvider
                                                                .errorMessage !=
                                                            null) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'M-Pesa Error: ${mpesaProvider.errorMessage}'),
                                                                backgroundColor:
                                                                    Colors.red),
                                                          );
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    'M-Pesa payment initiated!'),
                                                                backgroundColor:
                                                                    Colors
                                                                        .green),
                                                          );
                                                        }
                                                      },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OfflineBlocker(
                                              isOnline: Provider.of<
                                                          ConnectivityProvider>(
                                                      context,
                                                      listen: false)
                                                  .isOnline,
                                              message:
                                                  'eTIMS invoice unavailable offline',
                                              child: ElevatedButton.icon(
                                                icon: isEtimsLoading
                                                    ? const SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child:
                                                            CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: Colors
                                                                    .white))
                                                    : const Icon(
                                                        Icons.receipt_long),
                                                label:
                                                    const Text('eTIMS Invoice'),
                                                onPressed: cartIsEmpty ||
                                                        isEtimsLoading
                                                    ? null
                                                    : () async {
                                                        final invoiceData =
                                                            _buildInvoiceData(
                                                                posProvider);
                                                        final historyProvider =
                                                            Provider.of<
                                                                    TransactionHistoryProvider>(
                                                                context,
                                                                listen: false);
                                                        final uuid =
                                                            const Uuid();
                                                        final confirm =
                                                            await _showConfirmationDialog(
                                                                context,
                                                                'Confirm eTIMS Invoice',
                                                                'Submit invoice for KES ${posProvider.total.toStringAsFixed(2)}?');
                                                        if (!confirm) return;
                                                        await etimsProvider
                                                            .submitInvoice(
                                                                invoiceData);
                                                        historyProvider
                                                            .addTransaction(
                                                                TransactionRecord(
                                                          id: uuid.v4(),
                                                          type: 'etims',
                                                          status: etimsProvider
                                                                      .errorMessage ==
                                                                  null
                                                              ? 'success'
                                                              : 'failed',
                                                          date: DateTime.now(),
                                                          amount:
                                                              posProvider.total,
                                                          details: etimsProvider
                                                                  .lastResponse ??
                                                              {},
                                                          errorMessage:
                                                              etimsProvider
                                                                  .errorMessage,
                                                        ));
                                                        if (etimsProvider
                                                                .errorMessage !=
                                                            null) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'eTIMS Error: ${etimsProvider.errorMessage}'),
                                                                backgroundColor:
                                                                    Colors.red),
                                                          );
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    'Invoice submitted to eTIMS!'),
                                                                backgroundColor:
                                                                    Colors
                                                                        .green),
                                                          );
                                                        }
                                                      },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Status display
                                      if (mpesaProvider.lastResponse != null)
                                        Text(
                                            'M-Pesa Status: ${mpesaProvider.lastResponse}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue)),
                                      if (etimsProvider.lastResponse != null)
                                        Text(
                                            'eTIMS Status: ${etimsProvider.lastResponse}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue)),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: cartIsEmpty
                                                  ? null
                                                  : () =>
                                                      posProvider.clearCart(),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor:
                                                      Colors.white),
                                              child: const Text('Clear'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: ElevatedButton(
                                              onPressed: cartIsEmpty
                                                  ? null
                                                  : () => _processPayment(),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .primaryColor,
                                                  foregroundColor:
                                                      Colors.white),
                                              child:
                                                  const Text('Process Payment'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _addProductToCart(product),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported,
                                size: 40);
                          },
                        )
                      : const Icon(Icons.shopping_bag, size: 40),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'KES ${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Stock: ${product.stock}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addProductToCart(Product product) {
    if (product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product is out of stock')),
      );
      return;
    }

    Provider.of<POSProvider>(context, listen: false).addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart')),
    );
  }

  void _addProductByBarcode(String barcode) {
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);
    final product = inventoryProvider.getProductByBarcode(barcode);

    if (product != null) {
      _addProductToCart(product);
      _barcodeController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product not found')),
      );
    }
  }

  void _showCartDetails() {
    // Implementation for cart details modal
  }

  void _processPayment() {
    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        total: Provider.of<POSProvider>(context, listen: false).total,
        onPaymentComplete: (paymentMethod, amount) {
          _completeTransaction(paymentMethod, amount);
        },
      ),
    );
  }

  void _completeTransaction(String paymentMethod, double amount) {
    final posProvider = Provider.of<POSProvider>(context, listen: false);
    posProvider.completeTransaction(paymentMethod, amount).then((_) {
      Navigator.of(context).pop(); // Close payment dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction completed successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction failed: $error')),
      );
    });
  }

  Future<String?> _promptPhoneNumber(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Phone Number'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: 'e.g. 2547XXXXXXXX'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _buildInvoiceData(POSProvider posProvider) {
    // Build invoice data from cart for eTIMS
    return {
      'items': posProvider.cartItems
          .map((item) => {
                'name': item.product.name,
                'quantity': item.quantity,
                'price': item.product.price,
                'total': item.quantity * item.product.price,
              })
          .toList(),
      'subtotal': posProvider.subtotal,
      'tax': posProvider.taxAmount,
      'total': posProvider.total,
      // Add more fields as needed
    };
  }

  Future<bool> _showConfirmationDialog(
      BuildContext context, String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _barcodeController.dispose();
    // Unregister transaction status listener
    final historyProvider =
        Provider.of<TransactionHistoryProvider>(context, listen: false);
    historyProvider.removeStatusListener(_onTransactionStatus);
    super.dispose();
  }
}
