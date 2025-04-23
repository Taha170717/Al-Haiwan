import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/cart/cart_item_tile.dart';
import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/cart/cart_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Cartscreen extends StatelessWidget {
  final cartVM = Get.put(CartViewModel());

  //CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => SafeArea(
        child: Column(
        
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartVM.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartVM.cartItems[index];
                  return CartItemTile(
                    item: item,
                    onAdd: () => cartVM.increaseQuantity(index),
                    onRemove: () => cartVM.decreaseQuantity(index),
                    onDelete: () => cartVM.removeItem(index),
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "\Rs. ${cartVM.total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {}, // Add your checkout logic here
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF199A8E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    child: const Text(
                      "Checkout",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;

  const SummaryRow({super.key, required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text("\Rs. ${value.toStringAsFixed(2)}", style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
