import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () =>
                Provider.of<NotificationProvider>(context, listen: false)
                    .markAllAsRead(),
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear all',
            onPressed: () =>
                Provider.of<NotificationProvider>(context, listen: false)
                    .clearAll(),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notifProvider, _) {
          final notifications = notifProvider.notifications;
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications.'));
          }
          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final n = notifications[i];
              return ListTile(
                leading: Icon(
                  n.type == 'transaction'
                      ? Icons.receipt_long
                      : n.type == 'stock'
                          ? Icons.inventory
                          : Icons.notifications,
                  color: n.read ? Colors.grey : Theme.of(context).primaryColor,
                ),
                title: Text(n.title,
                    style: TextStyle(
                        fontWeight:
                            n.read ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text(n.message),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!n.read)
                      IconButton(
                        icon: const Icon(Icons.mark_email_read),
                        tooltip: 'Mark as read',
                        onPressed: () => notifProvider.markAsRead(n.id),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Remove',
                      onPressed: () => notifProvider.removeNotification(n.id),
                    ),
                  ],
                ),
                onTap: () => notifProvider.markAsRead(n.id),
              );
            },
          );
        },
      ),
    );
  }
}
