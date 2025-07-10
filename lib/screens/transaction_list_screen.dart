import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../models/product.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  void _showTransactionDialog(BuildContext context, {POSTransaction? tx}) {
    final isEdit = tx != null;
    final totalController =
        TextEditingController(text: tx?.total.toString() ?? '');
    final paymentMethodController =
        TextEditingController(text: tx?.paymentMethod ?? 'Cash');
    final customerNameController =
        TextEditingController(text: tx?.customerName ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Transaction Details' : 'Add Transaction'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: totalController,
                decoration: const InputDecoration(labelText: 'Total Amount'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || double.tryParse(v) == null
                    ? 'Enter valid amount'
                    : null,
                enabled: !isEdit,
              ),
              TextFormField(
                controller: paymentMethodController,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                enabled: !isEdit,
              ),
              TextFormField(
                controller: customerNameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                enabled: !isEdit,
              ),
              if (isEdit)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Date: ${tx.createdAt}'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!isEdit)
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final provider =
                    Provider.of<TransactionProvider>(context, listen: false);
                final now = DateTime.now();
                final total = double.parse(totalController.text);
                // Mock product and item for demo
                final mockProduct = Product(
                  id: 'mock-product',
                  name: 'Demo Product',
                  price: total,
                  stockQuantity: 1,
                  createdAt: now,
                  updatedAt: now,
                );
                final mockItem = TransactionItem(
                  id: 'mock-item',
                  product: mockProduct,
                  quantity: 1,
                  price: total,
                );
                final newTx = POSTransaction(
                  id: '',
                  items: [mockItem],
                  subtotal: total,
                  tax: 0,
                  discount: 0,
                  total: total,
                  paymentMethod: paymentMethodController.text,
                  paymentReference: null,
                  customerPhone: null,
                  customerName: customerNameController.text,
                  cashierId: 'demo-cashier',
                  cashierName: 'Demo Cashier',
                  createdAt: now,
                  status: 'completed',
                  etimsReceiptNumber: null,
                  etimsSignature: null,
                  isEtimsSubmitted: false,
                );
                try {
                  await provider.addTransaction(newTx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaction added')));
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Add'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          if (provider.transactions.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }
          return ListView.builder(
            itemCount: provider.transactions.length,
            itemBuilder: (context, i) {
              final tx = provider.transactions[i];
              return ListTile(
                title: Text('Transaction #${tx.id}'),
                subtitle:
                    Text('Total: KES ${tx.total} | Date: ${tx.createdAt}'),
                onTap: () => _showTransactionDialog(context, tx: tx),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionDialog(context),
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}
