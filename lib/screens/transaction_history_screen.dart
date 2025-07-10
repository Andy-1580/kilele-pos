import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_history_provider.dart';
import '../models/transaction_record.dart';
import '../providers/mpesa_provider.dart';
import '../providers/etims_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:convert';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _searchQuery = '';
  String _typeFilter = 'all';
  String _statusFilter = 'all';
  String _sortBy = 'date';
  bool _sortAsc = false;

  Future<void> _retryTransaction(
      BuildContext context, TransactionRecord tx) async {
    final mpesaProvider = Provider.of<MpesaProvider>(context, listen: false);
    final etimsProvider = Provider.of<EtimsProvider>(context, listen: false);
    final historyProvider =
        Provider.of<TransactionHistoryProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    const uuid = Uuid();
    messenger.showSnackBar(
      const SnackBar(content: Text('Retrying transaction...')),
    );
    try {
      if (tx.type == 'mpesa') {
        final phone = tx.details['phone'] ?? '';
        final amount = tx.amount;
        await mpesaProvider.initiatePayment(phone: phone, amount: amount);
        if (mpesaProvider.errorMessage == null) {
          historyProvider.addTransaction(TransactionRecord(
            id: uuid.v4(),
            type: 'mpesa',
            status: 'success',
            date: DateTime.now(),
            amount: amount,
            details: mpesaProvider.lastResponse ?? {},
            errorMessage: null,
          ));
          messenger.showSnackBar(
            const SnackBar(
              content: Text('M-Pesa retry successful!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          historyProvider.addTransaction(TransactionRecord(
            id: uuid.v4(),
            type: 'mpesa',
            status: 'failed',
            date: DateTime.now(),
            amount: amount,
            details: mpesaProvider.lastResponse ?? {},
            errorMessage: mpesaProvider.errorMessage,
          ));
          messenger.showSnackBar(
            SnackBar(
              content:
                  Text('M-Pesa retry failed: ${mpesaProvider.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (tx.type == 'etims') {
        final invoiceData = tx.details;
        final amount = tx.amount;
        await etimsProvider.submitInvoice(invoiceData);
        final messenger = ScaffoldMessenger.of(context);
        if (etimsProvider.errorMessage == null) {
          historyProvider.addTransaction(TransactionRecord(
            id: uuid.v4(),
            type: 'etims',
            status: 'success',
            date: DateTime.now(),
            amount: amount,
            details: etimsProvider.lastResponse ?? {},
            errorMessage: null,
          ));
          messenger.showSnackBar(
            const SnackBar(
              content: Text('eTIMS retry successful!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          historyProvider.addTransaction(TransactionRecord(
            id: uuid.v4(),
            type: 'etims',
            status: 'failed',
            date: DateTime.now(),
            amount: amount,
            details: etimsProvider.lastResponse ?? {},
            errorMessage: etimsProvider.errorMessage,
          ));
          messenger.showSnackBar(
            SnackBar(
              content:
                  Text('eTIMS retry failed: ${etimsProvider.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text('Retry error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _printReceipt(BuildContext context, TransactionRecord tx) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Receipt',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text('Type: ${tx.type.toUpperCase()}'),
            pw.Text('Status: ${tx.status.toUpperCase()}'),
            pw.Text('Date: ${tx.date.toLocal()}'),
            pw.Text('Amount: KES ${tx.amount.toStringAsFixed(2)}'),
            pw.SizedBox(height: 8),
            pw.Text('Details:'),
            pw.Text(tx.details.toString()),
            if (tx.errorMessage != null) ...[
              pw.SizedBox(height: 8),
              pw.Text('Error: ${tx.errorMessage}',
                  style: const pw.TextStyle(color: PdfColors.red)),
            ],
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  List<MapEntry<String, int>> _getBestCustomers(
      List<TransactionRecord> transactions) {
    final customerCounts = <String, int>{};
    for (final tx in transactions) {
      final phone = tx.details['phone']?.toString() ?? '';
      if (phone.isNotEmpty) {
        customerCounts[phone] = (customerCounts[phone] ?? 0) + 1;
      }
    }
    final sorted = customerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search by phone or amount',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.trim()),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _typeFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Types')),
                    DropdownMenuItem(value: 'mpesa', child: Text('M-Pesa')),
                    DropdownMenuItem(value: 'etims', child: Text('eTIMS')),
                  ],
                  onChanged: (value) => setState(() => _typeFilter = value!),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                    DropdownMenuItem(value: 'success', child: Text('Success')),
                    DropdownMenuItem(value: 'failed', child: Text('Failed')),
                  ],
                  onChanged: (value) => setState(() => _statusFilter = value!),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(
                        value: 'date', child: Text('Sort by Date')),
                    DropdownMenuItem(
                        value: 'amount', child: Text('Sort by Amount')),
                    DropdownMenuItem(
                        value: 'customer', child: Text('Sort by Customer')),
                  ],
                  onChanged: (value) => setState(() => _sortBy = value!),
                ),
                IconButton(
                  icon: Icon(
                      _sortAsc ? Icons.arrow_upward : Icons.arrow_downward),
                  tooltip: 'Toggle sort order',
                  onPressed: () => setState(() => _sortAsc = !_sortAsc),
                ),
              ],
            ),
          ),
          Consumer<TransactionHistoryProvider>(
            builder: (context, historyProvider, _) {
              var transactions = historyProvider.transactions;
              // Apply filters
              if (_typeFilter != 'all') {
                transactions =
                    transactions.where((t) => t.type == _typeFilter).toList();
              }
              if (_statusFilter != 'all') {
                transactions = transactions
                    .where((t) => t.status == _statusFilter)
                    .toList();
              }
              if (_searchQuery.isNotEmpty) {
                transactions = transactions.where((t) {
                  final phone = t.details['phone']?.toString() ?? '';
                  final amount = t.amount.toString();
                  return phone.contains(_searchQuery) ||
                      amount.contains(_searchQuery);
                }).toList();
              }
              // Sort
              transactions.sort((a, b) {
                int cmp = 0;
                switch (_sortBy) {
                  case 'date':
                    cmp = a.date.compareTo(b.date);
                    break;
                  case 'amount':
                    cmp = a.amount.compareTo(b.amount);
                    break;
                  case 'customer':
                    cmp = (a.details['phone'] ?? '')
                        .compareTo(b.details['phone'] ?? '');
                    break;
                }
                return _sortAsc ? cmp : -cmp;
              });
              final bestCustomers =
                  _getBestCustomers(historyProvider.transactions);
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (bestCustomers.isNotEmpty) ...[
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('Best Customers',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: bestCustomers.length,
                          itemBuilder: (context, i) {
                            final entry = bestCustomers[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(entry.key,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text('Tx: ${entry.value}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Expanded(
                      child: transactions.isEmpty
                          ? const Center(child: Text('No transactions found.'))
                          : ListView.separated(
                              itemCount: transactions.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final tx = transactions[index];
                                return ListTile(
                                  leading: Icon(
                                    tx.type == 'mpesa'
                                        ? Icons.phone_android
                                        : Icons.receipt_long,
                                    color: tx.type == 'mpesa'
                                        ? Colors.green
                                        : Colors.blue,
                                  ),
                                  title: Text(
                                      '${tx.type.toUpperCase()} - ${tx.status.toUpperCase()}'),
                                  subtitle: Text(
                                    'Amount: KES ${tx.amount.toStringAsFixed(2)}\nDate: ${tx.date.toLocal()}\n${tx.errorMessage != null ? 'Error: ${tx.errorMessage}' : ''}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (tx.status == 'failed')
                                        IconButton(
                                          icon: const Icon(Icons.refresh,
                                              color: Colors.red),
                                          tooltip: 'Retry',
                                          onPressed: () =>
                                              _retryTransaction(context, tx),
                                        ),
                                      if (tx.status == 'success')
                                        IconButton(
                                          icon: const Icon(Icons.print,
                                              color: Colors.blue),
                                          tooltip: 'Print Receipt',
                                          onPressed: () =>
                                              _printReceipt(context, tx),
                                        ),
                                      IconButton(
                                        icon: const Icon(Icons.info_outline,
                                            color: Colors.grey),
                                        tooltip: 'Details',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text(
                                                  'Transaction Details'),
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('API Response:',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    const SizedBox(height: 4),
                                                    Text(const JsonEncoder
                                                            .withIndent('  ')
                                                        .convert(tx.details)),
                                                    if (tx.errorMessage !=
                                                        null) ...[
                                                      const SizedBox(height: 8),
                                                      const Text('Error:',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.red)),
                                                      Text(tx.errorMessage!),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title:
                                            const Text('Transaction Details'),
                                        content: SingleChildScrollView(
                                          child: Text(tx.details.toString()),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
