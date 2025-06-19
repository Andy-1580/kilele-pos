import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'user_profile_screen.dart';
import 'admin_management_screen.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<AuthProvider>(context).profile;
    final isAdmin = profile?['is_admin'] == true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'My Profile',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserProfileScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profile != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Text('Hello, ${profile['name'] ?? profile['email'] ?? ''}',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(width: 16),
                    if (isAdmin) const Chip(label: Text('Admin')),
                  ],
                ),
              ),
            Expanded(
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _DashboardCard(
                    icon: Icons.inventory_2,
                    label: 'Products',
                    onTap: () => Navigator.pushNamed(context, '/products'),
                  ),
                  _DashboardCard(
                    icon: Icons.receipt_long,
                    label: 'Transactions',
                    onTap: () => Navigator.pushNamed(context, '/transactions'),
                  ),
                  _DashboardCard(
                    icon: Icons.people,
                    label: 'Customers',
                    onTap: () => Navigator.pushNamed(context, '/customers'),
                  ),
                  _DashboardCard(
                    icon: Icons.person,
                    label: 'Users',
                    onTap: () => Navigator.pushNamed(context, '/users'),
                  ),
                  if (isAdmin)
                    _DashboardCard(
                      icon: Icons.admin_panel_settings,
                      label: 'Admin Only',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdminManagementScreen()),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard card widget for navigation
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
