import 'package:flutter/material.dart';

class SalesChart extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  const SalesChart({super.key, required this.startDate, required this.endDate});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.blue[50],
      child: const Center(child: Text('Sales Chart Placeholder')),
    );
  }
}
