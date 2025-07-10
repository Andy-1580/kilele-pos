import '../models/transaction.dart';
import '../services/transaction_service.dart';
import 'crud_provider.dart';

class TransactionProvider extends CrudProvider<POSTransaction> {
  TransactionProvider()
      : super(
          fetchAll: () async =>
              (await TransactionService().fetchAll()).cast<POSTransaction>(),
          create: (tx) async => (await TransactionService().create(tx)),
          update: (tx) async => (await TransactionService().update(tx)),
          delete: (id) => TransactionService().delete(id),
          getId: (tx) => tx.id,
        );

  List<POSTransaction> get transactions => items;

  Future<void> loadTransactions() => loadItems();
  Future<void> addTransaction(POSTransaction tx) => addItem(tx);
  Future<void> updateTransaction(POSTransaction tx) => updateItem(tx);
  Future<void> deleteTransaction(String id) => deleteItem(id);
}
