import '../models/customer.dart';
import '../services/customer_service.dart';
import 'crud_provider.dart';

class CustomerProvider extends CrudProvider<Customer> {
  CustomerProvider()
      : super(
          fetchAll: () => CustomerService().fetchAll(),
          create: (customer) => CustomerService().create(customer),
          update: (customer) => CustomerService().update(customer),
          delete: (id) => CustomerService().delete(id),
          getId: (customer) => customer.id,
        );

  List<Customer> get customers => items;

  Future<void> loadCustomers() => loadItems();
  Future<void> addCustomer(Customer customer) => addItem(customer);
  Future<void> updateCustomer(Customer customer) => updateItem(customer);
  Future<void> deleteCustomer(String id) => deleteItem(id);
}
