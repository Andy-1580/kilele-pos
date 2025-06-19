import 'package:flutter/material.dart';
import 'custom_app_bar.dart';
import 'loading_overlay.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool isLoading;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;

  const BaseScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBackButton = true,
    this.isLoading = false,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        showBackButton: showBackButton,
        actions: actions,
      ),
      body: Stack(
        children: [
          body,
          if (isLoading) const LoadingOverlay(),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
    );
  }
}
