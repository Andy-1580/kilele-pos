import 'package:flutter/material.dart';

class SearchableList<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemLabel;
  final Widget Function(BuildContext, T) itemBuilder;
  final String hintText;
  final bool isLoading;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final void Function(String)? onSearchChanged;

  const SearchableList({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.itemBuilder,
    this.hintText = 'Search...',
    this.isLoading = false,
    this.emptyWidget,
    this.loadingWidget,
    this.onSearchChanged,
  });

  @override
  State<SearchableList<T>> createState() => _SearchableListState<T>();
}

class _SearchableListState<T> extends State<SearchableList<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    widget.onSearchChanged?.call(_searchQuery);
  }

  List<T> get _filteredItems {
    if (_searchQuery.isEmpty) return widget.items;
    return widget.items
        .where((item) => widget
            .itemLabel(item)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: widget.isLoading
              ? widget.loadingWidget ??
                  const Center(child: CircularProgressIndicator())
              : _filteredItems.isEmpty
                  ? widget.emptyWidget ??
                      const Center(
                        child: Text('No items found'),
                      )
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) =>
                          widget.itemBuilder(context, _filteredItems[index]),
                    ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
