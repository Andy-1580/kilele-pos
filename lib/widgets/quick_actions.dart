import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'New Sale',
                Icons.add_shopping_cart,
                Colors.green,
                () => Navigator.pushNamed(context, '/pos'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                'Add Product',
                Icons.add_box,
                Colors.blue,
                () => Navigator.pushNamed(context, '/inventory'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                'View Reports',
                Icons.analytics,
                Colors.purple,
                () => Navigator.pushNamed(context, '/reports'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
