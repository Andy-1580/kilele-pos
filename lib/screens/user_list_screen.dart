import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  void _showUserDialog(BuildContext context, {User? user}) {
    final isEdit = user != null;
    final emailController = TextEditingController(text: user?.email ?? '');
    final nameController = TextEditingController(text: user?.name ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit User' : 'Add User'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty || !v.contains('@')
                    ? 'Enter valid email'
                    : null,
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final provider =
                  Provider.of<UserProvider>(context, listen: false);
              final now = DateTime.now();
              final newUser = User(
                id: user?.id ?? '',
                email: emailController.text,
                name: nameController.text,
                createdAt: now,
              );
              try {
                if (isEdit) {
                  await provider.updateUser(newUser);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User updated')));
                } else {
                  await provider.addUser(newUser);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User added')));
                }
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content:
            Text('Are you sure you want to delete "${user.email ?? user.id}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider =
                  Provider.of<UserProvider>(context, listen: false);
              try {
                await provider.deleteUser(user.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User deleted')));
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: Consumer<UserProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          if (provider.users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          return ListView.builder(
            itemCount: provider.users.length,
            itemBuilder: (context, i) {
              final user = provider.users[i];
              return ListTile(
                title: Text(user.email ?? user.id),
                subtitle: Text(user.name ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                      onPressed: () => _showUserDialog(context, user: user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete',
                      onPressed: () => _confirmDelete(context, user),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(context),
        tooltip: 'Add User',
        child: const Icon(Icons.add),
      ),
    );
  }
}
