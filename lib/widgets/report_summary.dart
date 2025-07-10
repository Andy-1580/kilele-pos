import 'package:flutter/material.dart';

class ReportSummary extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String reportType;
  const ReportSummary(
      {super.key,
      required this.startDate,
      required this.endDate,
      required this.reportType});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Summary for $reportType'),
        subtitle: Text('From: $startDate to $endDate'),
      ),
    );
  }
}
