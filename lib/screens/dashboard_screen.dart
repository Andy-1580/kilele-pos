import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/quick_actions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    final posProvider = Provider.of<POSProvider>(context, listen: false);
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);

    posProvider.loadTodaysSales();
    inventoryProvider.loadLowStockItems();
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
                  const RecentTransactions(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/pos'),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add_shopping_cart, color: Colors.white),
        tooltip: 'New Sale',
      ),
    );
  }
}
