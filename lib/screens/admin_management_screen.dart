import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.profile?['id'];
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Management')),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userProvider.error != null
              ? Center(child: Text('Error: ${userProvider.error}'))
              : ListView.builder(
                  itemCount: userProvider.users.length,
                  itemBuilder: (context, i) {
                    final user = userProvider.users[i];
                    final isCurrent = user.id == currentUserId;
                    return ListTile(
                      title: Text(user.email),
                      subtitle: Text(user.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isCurrent)
                            IconButton(
                              icon: Icon(user.isAdmin == true
                                  ? Icons.remove_moderator
                                  : Icons.admin_panel_settings),
                              tooltip: user.isAdmin == true
                                  ? 'Demote from Admin'
                                  : 'Promote to Admin',
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(user.isAdmin == true
                                        ? 'Demote Admin'
                                        : 'Promote to Admin'),
                                    content: Text(
                                        'Are you sure you want to ${user.isAdmin == true ? 'demote' : 'promote'} this user?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel')),
                                      ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Confirm')),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  try {
                                    await authProvider.client
                                        .from('users')
                                        .update({
                                      'is_admin': user.isAdmin != true
                                    }).eq('id', user.id);
                                    await userProvider.loadUsers();
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      const SnackBar(
                                          content: Text('User updated')),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                          if (!isCurrent)
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Delete User',
                              onPressed: () async {
                                if (!mounted) return;
                                final messenger = ScaffoldMessenger.of(context);
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete User'),
                                    content: Text(
                                        'Are you sure you want to delete ${user.email}?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel')),
                                      ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete')),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  try {
                                    await authProvider.client
                                        .from('users')
                                        .delete()
                                        .eq('id', user.id);
                                    await userProvider.loadUsers();
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      const SnackBar(
                                          content: Text('User deleted')),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                          if (!isCurrent)
                            IconButton(
                              icon: const Icon(Icons.lock_reset),
                              tooltip: 'Reset Password',
                              onPressed: () async {
                                if (!mounted) return;
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  await authProvider
                                      .sendPasswordReset(user.email);
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Password reset email sent')),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
