import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import 'cart_item_card.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<POSProvider>(
      builder: (context, pos, child) {
        if (pos.cartItems.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Cart is empty',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'Add products to start a transaction',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cart Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: pos.clearCart,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: pos.cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = pos.cartItems[index];
                  return CartItemCard(
                    cartItem: cartItem,
                    onQuantityChanged: (newQuantity) {
                      pos.updateCartItemQuantity(
                          cartItem.product.id, newQuantity);
                    },
                    onRemove: () {
                      pos.removeFromCart(cartItem.product.id);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
