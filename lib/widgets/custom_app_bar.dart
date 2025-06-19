import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showProfileMenu;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.showProfileMenu = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      automaticallyImplyLeading: showBackButton,
      actions: [
        if (actions != null) ...actions!,
        if (showProfileMenu)
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      // TODO: Navigate to profile screen
                      break;
                    case 'settings':
                      // TODO: Navigate to settings screen
                      break;
                    case 'logout':
                      auth.signOut();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 8),
                        Text(auth.currentUser?.email ?? 'Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
