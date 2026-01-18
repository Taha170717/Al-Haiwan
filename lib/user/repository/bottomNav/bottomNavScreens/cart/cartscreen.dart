import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../user_service.dart';
import '../checkout/checkout_screen.dart';
import 'cart_item_tile.dart';
import '../../../../models/cart_viewmodel.dart';

// DEBUG: Loading doctor detail - print doctorId when opening detail page
void printLoadingDoctorId(String doctorId) {
  print("Loading for doctorId: $doctorId");
}

class CartScreen extends StatelessWidget {
  final CartViewModel cartVM = Get.put(CartViewModel());
  final UserService userService = Get.put(UserService()); // Added user service

  CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Shopping Cart',
          style: TextStyle(
              color: const Color(0xFF199A8E),
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.bold,
              fontFamily: 'bolditalic'
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => userService.isLoggedIn
              ? Icon(Icons.person, color: const Color(0xFF199A8E), size: 20)
              : Icon(Icons.person_outline, color: Colors.grey, size: 20)),
          const SizedBox(width: 8),
          Obx(() => cartVM.cartItems.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Clear Cart'),
                  content: const Text('Are you sure you want to remove all items from your cart?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        cartVM.clearCart();
                        Get.back();
                      },
                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (cartVM.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.1),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: screenWidth * 0.2,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  'Your cart is empty',
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Add some products to get started',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Items auto-expire after 30 minutes',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF199A8E),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                      vertical: screenHeight * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Continue Shopping',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: const Color(0xFF199A8E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: const Color(0xFF199A8E), size: 16),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Text(
                      'Items expire after 30 minutes • Cart synced across devices',
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: const Color(0xFF199A8E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.01),

            // Cart items list
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
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
            ),

            // Cart summary
            Container(
              margin: EdgeInsets.all(screenWidth * 0.04),
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Rs ${cartVM.subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery Fee',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Rs ${cartVM.tax.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: screenHeight * 0.03,
                    thickness: 1,
                    color: Colors.grey[300],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF199A8E),
                        ),
                      ),
                      Text(
                        'Rs ${cartVM.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF199A8E),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF199A8E).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (userService.isLoggedIn) {
                          Get.to(() => CheckoutScreen());
                        } else {
                          Get.snackbar(
                            'Login Required',
                            'Please login to proceed with checkout',
                            backgroundColor: const Color(0xFFF44336),
                            colorText: Colors.white,
                            duration: const Duration(seconds: 3),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payment,
                            color: Colors.white,
                            size: screenWidth * 0.05,
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'bolditalic'
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
