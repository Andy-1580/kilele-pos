import '../models/product.dart';
import '../services/product_service.dart';
import 'crud_provider.dart';

class ProductProvider extends CrudProvider<Product> {
  ProductProvider()
      : super(
          fetchAll: () => ProductService().fetchAll(),
          create: (product) => ProductService().create(product),
          update: (product) => ProductService().update(product),
          delete: (id) => ProductService().delete(id),
          getId: (product) => product.id,
        );

  List<Product> get products => items;

  Future<void> loadProducts() => loadItems();
  Future<void> addProduct(Product product) => addItem(product);
  Future<void> updateProduct(Product product) => updateItem(product);
  Future<void> deleteProduct(String id) => deleteItem(id);
}
