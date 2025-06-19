import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Offline Guide')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Text('Online & Offline Features',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text(
              '• All features are always visible. Online-only features are disabled when offline, but you can still see them.'),
          SizedBox(height: 8),
          Text(
              '• When offline, you will see a banner at the top of the app and overlays on online-only features.'),
          SizedBox(height: 8),
          Text(
              '• You can continue to use all offline features, such as viewing inventory, making sales, and more.'),
          SizedBox(height: 8),
          Text(
              '• If you try to use an online-only feature while offline, you will see a message explaining why it is unavailable.'),
          SizedBox(height: 8),
          Text(
              '• Any actions that require the internet (like syncing sales or submitting invoices) will be queued and automatically synced when you are back online.'),
          SizedBox(height: 8),
          Text(
              '• The sync status icon in the app bar shows if you are fully synced, have pending actions, or if there is a sync error.'),
          SizedBox(height: 8),
          Text(
              '• You will be notified when actions are synced or if there are any errors.'),
          SizedBox(height: 24),
          Text('Need more help?',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
              'Contact support or check the user manual for more information.'),
        ],
      ),
    );
  }
}
