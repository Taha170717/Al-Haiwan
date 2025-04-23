import 'package:flutter/material.dart';
import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/cart/cart_item_model.dart';

class CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF199A8E),
            blurRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(item.image, width: 50, height: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item.quantityLabel, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete, size: 18, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.remove),
                    color: const Color(0xFF199A8E),
                  ),
                  Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.w500)),
                  IconButton(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                    color: const Color(0xFF199A8E),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "\Rs. ${(item.price * item.quantity).toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }
}
