import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          SettingsTile(
            icon: Icons.store,
            title: 'Store Information',
            subtitle: 'Configure store details',
            onTap: () => Navigator.pushNamed(context, '/store-settings'),
          ),
          SettingsTile(
            icon: Icons.receipt,
            title: 'eTIMS Configuration',
            subtitle: 'Setup KRA eTIMS integration',
            onTap: () => Navigator.pushNamed(context, '/etims-settings'),
          ),
          SettingsTile(
            icon: Icons.payment,
            title: 'M-Pesa Configuration',
            subtitle: 'Setup M-Pesa payments',
            onTap: () => Navigator.pushNamed(context, '/mpesa-settings'),
          ),
          SettingsTile(
            icon: Icons.print,
            title: 'Receipt Settings',
            subtitle: 'Configure receipt printing',
            onTap: () => Navigator.pushNamed(context, '/receipt-settings'),
          ),
          SettingsTile(
            icon: Icons.backup,
            title: 'Backup & Sync',
            subtitle: 'Manage data backup',
            onTap: () => Navigator.pushNamed(context, '/backup-settings'),
          ),
          SettingsTile(
            icon: Icons.person,
            title: 'User Management',
            subtitle: 'Manage users and permissions',
            onTap: () => Navigator.pushNamed(context, '/user-settings'),
          ),
          const Divider(),
          SettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of the application',
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
