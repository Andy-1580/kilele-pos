import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../models/customer.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  void _showCustomerDialog(BuildContext context, {Customer? customer}) {
    final isEdit = customer != null;
    final nameController = TextEditingController(text: customer?.name ?? '');
    final emailController = TextEditingController(text: customer?.email ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEdit ? 'Edit Customer' : 'Add Customer'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v != null && v.isNotEmpty && !v.contains('@')
                    ? 'Enter valid email'
                    : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final provider =
                  Provider.of<CustomerProvider>(dialogContext, listen: false);
              final now = DateTime.now();
              final newCustomer = Customer(
                id: customer?.id ?? '',
                name: nameController.text,
                email:
                    emailController.text.isEmpty ? null : emailController.text,
                phone:
                    phoneController.text.isEmpty ? null : phoneController.text,
                createdAt: now,
                updatedAt: now,
              );
              final nav = Navigator.of(dialogContext);
              final messenger = ScaffoldMessenger.of(context);
              nav.pop(); // Pop dialog before await
              try {
                if (isEdit) {
                  await provider.updateCustomer(newCustomer);
                  messenger.showSnackBar(
                      const SnackBar(content: Text('Customer updated')));
                } else {
                  await provider.addCustomer(newCustomer);
                  messenger.showSnackBar(
                      const SnackBar(content: Text('Customer added')));
                }
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete "${customer.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider =
                  Provider.of<CustomerProvider>(dialogContext, listen: false);
              final nav = Navigator.of(dialogContext);
              final messenger = ScaffoldMessenger.of(context);
              nav.pop(); // Pop dialog before await
              try {
                await provider.deleteCustomer(customer.id);
                messenger.showSnackBar(
                    const SnackBar(content: Text('Customer deleted')));
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
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
      appBar: AppBar(title: const Text('Customers')),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          if (provider.customers.isEmpty) {
            return const Center(child: Text('No customers found.'));
          }
          return ListView.builder(
            itemCount: provider.customers.length,
            itemBuilder: (context, i) {
              final customer = provider.customers[i];
              return ListTile(
                title: Text(customer.name),
                subtitle: Text(customer.email ?? customer.phone ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                      onPressed: () =>
                          _showCustomerDialog(context, customer: customer),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete',
                      onPressed: () => _confirmDelete(context, customer),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomerDialog(context),
        tooltip: 'Add Customer',
        child: const Icon(Icons.add),
      ),
    );
  }
}
