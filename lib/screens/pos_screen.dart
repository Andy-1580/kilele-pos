import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import '../widgets/payment_dialog.dart';
import '../providers/mpesa_provider.dart';
import '../providers/etims_provider.dart';
import '../screens/transaction_history_screen.dart';
import '../providers/transaction_history_provider.dart';
import '../models/transaction_record.dart';
import '../providers/connectivity_provider.dart';
import '../widgets/product_grid_widget.dart';
import '../widgets/cart_widget.dart';
import '../services/mpesa_service.dart';
import '../services/etims_service.dart';

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
                          return ProductGridWidget(products: products);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Cart Panel
              const Expanded(
                flex: 2,
                child: CartWidget(),
              ),
            ],
          ),
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton.extended(
              onPressed: () {
                final total =
                    Provider.of<POSProvider>(context, listen: false).total;
                if (total <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Cart is empty. Add items to checkout.')),
                  );
                  return;
                }
                showDialog(
                  context: context,
                  builder: (context) => PaymentDialog(amount: total),
                );
              },
              icon: const Icon(Icons.payment),
              label: const Text('Checkout'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  void _addProductToCart(Product product) {
    if (product.stockQuantity <= 0) {
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
