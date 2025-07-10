import 'package:flutter/material.dart';

/// A widget that blocks interaction and displays an overlay when offline.
///
/// Wrap any feature or screen with [OfflineBlocker] to prevent usage when
/// [isOnline] is false. Shows a semi-transparent overlay and a message.
class OfflineBlocker extends StatelessWidget {
  /// The child widget to display when online.
  final Widget child;

  /// Whether the app is currently online.
  final bool isOnline;

  /// Optional message to display when offline.
  final String? message;

  /// The default message shown when offline.
  static const String _defaultMessage =
      'This feature is unavailable while offline.';

  /// Creates an [OfflineBlocker].
  ///
  /// [child] is required. [isOnline] controls the overlay.
  const OfflineBlocker({
    super.key,
    required this.child,
    required this.isOnline,
    this.message,
  });

  void _showOfflineMessage(BuildContext context) {
    assert(ScaffoldMessenger.maybeOf(context) != null,
        'OfflineBlocker requires a ScaffoldMessenger ancestor.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? _defaultMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: !isOnline,
          child: child,
        ),
        AnimatedOpacity(
          opacity: isOnline ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          child: IgnorePointer(
            ignoring: isOnline,
            child: isOnline
                ? const SizedBox.shrink()
                : Semantics(
                    label: 'Feature unavailable while offline',
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _showOfflineMessage(context),
                      child: Container(
                        color:
                            const Color(0xCC000000), // 80% black for contrast
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_off,
                                  color: Colors.white,
                                  size: 48,
                                  semanticLabel: 'Offline'),
                              const SizedBox(height: 8),
                              Text(
                                message ?? _defaultMessage,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
