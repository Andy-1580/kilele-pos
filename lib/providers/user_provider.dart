import '../models/user.dart';
import '../services/user_service.dart';
import 'crud_provider.dart';

class UserProvider extends CrudProvider<User> {
  UserProvider()
      : super(
          fetchAll: () async => await UserService().fetchAll(),
          create: (user) async => await UserService().create(user),
          update: (user) async => await UserService().update(user),
          delete: (id) => UserService().delete(id),
          getId: (user) => user.id,
        );

  List<User> get users => items;

  Future<void> loadUsers() => loadItems();
  Future<void> addUser(User user) => addItem(user);
  Future<void> updateUser(User user) => updateItem(user);
  Future<void> deleteUser(String id) => deleteItem(id);
}
