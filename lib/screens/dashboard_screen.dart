import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/quick_actions.dart';
import '../providers/transaction_history_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<MapEntry<String, int>> _topProducts = [];
  List<MapEntry<String, int>> _topCustomers = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    final posProvider = Provider.of<POSProvider>(context, listen: false);
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);
    final historyProvider =
        Provider.of<TransactionHistoryProvider>(context, listen: false);

    posProvider.loadTodaysSales();
    inventoryProvider.loadLowStockItems();

    // Top products by sales
    final productSales = <String, int>{};
    for (final tx in historyProvider.transactions) {
      if (tx.type == 'mpesa' || tx.type == 'etims') {
        final items = tx.details['items'] as List<dynamic>?;
        if (items != null) {
          for (final item in items) {
            final name = item['name'] as String?;
            final qty = item['quantity'] as int? ?? 1;
            if (name != null) {
              productSales[name] = (productSales[name] ?? 0) + qty;
            }
          }
        }
      }
    }
    final topProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Top customers by frequency
    final customerCounts = <String, int>{};
    for (final tx in historyProvider.transactions) {
      final phone = tx.details['phone']?.toString() ?? '';
      if (phone.isNotEmpty) {
        customerCounts[phone] = (customerCounts[phone] ?? 0) + 1;
      }
    }
    final topCustomers = customerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      _topProducts = topProducts;
      _topCustomers = topCustomers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kilele POS Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Consumer2<POSProvider, InventoryProvider>(
        builder: (context, posProvider, inventoryProvider, child) {
          if (posProvider.isLoading || inventoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async => _loadDashboardData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                          title: 'Today\'s Sales',
                          value:
                              'KES ${posProvider.todaysSales.toStringAsFixed(2)}',
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardCard(
                          title: 'Transactions',
                          value: posProvider.todaysTransactionCount.toString(),
                          icon: Icons.receipt,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                          title: 'Low Stock Items',
                          value:
                              inventoryProvider.lowStockItems.length.toString(),
                          icon: Icons.warning,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardCard(
                          title: 'Total Products',
                          value: inventoryProvider.products.length.toString(),
                          icon: Icons.inventory,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  const QuickActions(),
                  const SizedBox(height: 24),

                  // Recent Transactions
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  RecentTransactions(
                    transactions: const [], // TODO: Replace with real orders if available
                    onTransactionTap: (order) {},
                  ),

                  const SizedBox(height: 24),
                  const Text('Top Products',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_topProducts.isEmpty)
                    const Text('No sales data yet.')
                  else
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount:
                            _topProducts.length > 5 ? 5 : _topProducts.length,
                        itemBuilder: (context, i) {
                          final entry = _topProducts[i];
                          return ListTile(
                            leading: CircleAvatar(child: Text('${i + 1}')),
                            title: Text(entry.key),
                            trailing: Text('Sold: ${entry.value}'),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text('Top Customers',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_topCustomers.isEmpty)
                    const Text('No customer data yet.')
                  else
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount:
                            _topCustomers.length > 5 ? 5 : _topCustomers.length,
                        itemBuilder: (context, i) {
                          final entry = _topCustomers[i];
                          return ListTile(
                            leading: CircleAvatar(child: Text('${i + 1}')),
                            title: Text(entry.key),
                            trailing: Text('Transactions: ${entry.value}'),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/pos'),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'New Sale',
        child: const Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
    );
  }
}
