import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mpesa_provider.dart';

class PaymentDialog extends StatefulWidget {
  final double amount;
  const PaymentDialog({super.key, required this.amount});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String _paymentMethod = 'mpesa';
  final TextEditingController _phoneController = TextEditingController();
  bool _isProcessing = false;
  String? _error;
  bool _success = false;

  @override
  Widget build(BuildContext context) {
    final mpesaProvider = Provider.of<MpesaProvider>(context);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('M-Pesa'),
                  selected: _paymentMethod == 'mpesa',
                  onSelected: (selected) {
                    setState(() => _paymentMethod = 'mpesa');
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Cash'),
                  selected: _paymentMethod == 'cash',
                  onSelected: (selected) {
                    setState(() => _paymentMethod = 'cash');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_paymentMethod == 'mpesa') ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_isProcessing || mpesaProvider.isLoading)
              const CircularProgressIndicator(),
            if (_success)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Payment Successful!',
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            if (!_isProcessing && !_success)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _error = null;
                        _isProcessing = true;
                      });
                      final nav = Navigator.of(context);
                      if (_paymentMethod == 'mpesa') {
                        final phone = _phoneController.text.trim();
                        if (phone.isEmpty) {
                          setState(() {
                            _error = 'Enter phone number';
                            _isProcessing = false;
                          });
                          return;
                        }
                        final success = await mpesaProvider.initiatePayment(
                          phone: phone,
                          amount: widget.amount,
                        );
                        setState(() {
                          _isProcessing = false;
                          _success = success;
                          _error = success
                              ? null
                              : mpesaProvider.errorMessage ?? 'Payment failed';
                        });
                        if (success) {
                          await Future.delayed(const Duration(seconds: 1));
                          nav.pop(true);
                        } else {
                          // Cash payment Logic
                          setState(() {
                            _success = true;
                            _isProcessing = false;
                          });
                          await Future.delayed(const Duration(seconds: 1));
                          nav.pop(true);
                        }
                      } else {
                        // Cash payment Logic
                        setState(() {
                          _success = true;
                          _isProcessing = false;
                        });
                        await Future.delayed(const Duration(seconds: 1));
                        nav.pop(true);
                      }
                    },
                    child: const Text('Pay'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
