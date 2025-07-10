// import 'package:flutter/foundation.dart';
import 'base_provider.dart';

/// Generic CRUD provider for any model type T.
class CrudProvider<T> extends BaseProvider {
  final Future<List<T>> Function() fetchAll;
  final Future<T> Function(T) create;
  final Future<T> Function(T) update;
  final Future<void> Function(String) delete;
  final String Function(T) getId;

  List<T> _items = [];
  String? _error;

  CrudProvider({
    required this.fetchAll,
    required this.create,
    required this.update,
    required this.delete,
    required this.getId,
  });

  List<T> get items => _items;
  String? get error => _error;

  Future<void> loadItems() async {
    setLoading(true);
    _error = null;
    notifyListeners();
    try {
      _items = await fetchAll();
    } catch (e) {
      _error = e.toString();
    }
    setLoading(false);
    notifyListeners();
  }

  Future<void> addItem(T item) async {
    try {
      final newItem = await create(item);
      _items.add(newItem);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateItem(T item) async {
    try {
      final updated = await update(item);
      final idx = _items.indexWhere((i) => getId(i) == getId(item));
      if (idx != -1) _items[idx] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await delete(id);
      _items.removeWhere((i) => getId(i) == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
