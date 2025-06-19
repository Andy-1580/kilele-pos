import 'package:flutter/material.dart';

class OfflineBlocker extends StatelessWidget {
  final Widget child;
  final bool isOnline;
  final String? message;

  const OfflineBlocker({
    super.key,
    required this.child,
    required this.isOnline,
    this.message,
  });

  void _showOfflineMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'This feature is unavailable while offline.'),
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
                    liveRegion: true,
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
                                message ?? 'Feature unavailable offline',
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
