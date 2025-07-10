import 'package:flutter/material.dart';

/// Utility for showing SnackBars safely with mounted check.
class SnackbarUtils {
  /// Shows a SnackBar if the [State] is still mounted.
  static void showIfMounted(
      State state, BuildContext context, SnackBar snackBar) {
    if (!state.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Shows a SnackBar if the [mounted] flag is true (for non-State classes).
  static void showIfMountedFlag(
      bool mounted, BuildContext context, SnackBar snackBar) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
