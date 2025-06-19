import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_history_provider.dart';

class SyncStatusIndicator extends StatelessWidget {
  final bool syncError;
  const SyncStatusIndicator({super.key, this.syncError = false});

  @override
  Widget build(BuildContext context) {
    final pendingCount = context
        .select<TransactionHistoryProvider, int>((p) => p.pendingQueue.length);
    Color color;
    IconData icon;
    String tooltip;
    if (syncError) {
      color = Colors.red;
      icon = Icons.sync_problem;
      tooltip = 'Sync error';
    } else if (pendingCount > 0) {
      color = Colors.orange;
      icon = Icons.sync;
      tooltip = '$pendingCount action(s) pending sync';
    } else {
      color = Colors.green;
      icon = Icons.cloud_done;
      tooltip = 'All synced';
    }
    return Tooltip(
      message: tooltip,
      child: Icon(icon, color: color),
    );
  }
}
