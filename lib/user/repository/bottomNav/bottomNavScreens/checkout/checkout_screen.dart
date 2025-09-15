import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/order_controller.dart';
import '../../../../controllers/profile_controller.dart';
import '../../../../controllers/bottom_nav_controller.dart';
import '../../../../models/order_model.dart';
import '../../bottomNavScreen.dart';
import '../../../../models/cart_viewmodel.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderController orderController = Get.put(OrderController());
  final ProfileController profileController = Get.put(ProfileController());
  final CartViewModel cartVM = Get.find<CartViewModel>();
  final BottomNavController bottomNavController =
      Get.put(BottomNavController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Ensure profile data is loaded
    if (profileController.currentUser.value == null) {
      profileController.loadUserProfile();
    }
  }

  void _loadUserData() {
    // Listen to profile controller changes and update form fields
    ever(profileController.currentUser, (user) {
      if (user != null && mounted) {
        nameController.text = user.name;
        phoneController.text = user.phone ?? '';
        addressController.text = user.address ?? '';
        cityController.text = user.city ?? '';
        stateController.text = user.state ?? '';
        zipController.text = user.zipCode ?? '';
      }
    });

    // If user data is already loaded, populate immediately
    final user = profileController.currentUser.value;
    if (user != null) {
      nameController.text = user.name;
      phoneController.text = user.phone ?? '';
      addressController.text = user.address ?? '';
      cityController.text = user.city ?? '';
      stateController.text = user.state ?? '';
      zipController.text = user.zipCode ?? '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF199A8E)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(
              color: const Color(0xFF199A8E),
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.bold,
              fontFamily: 'bolditalic'
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // Show loading indicator while profile is loading
        if (profileController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: const Color(0xFF199A8E),
                ),
                SizedBox(height: screenWidth * 0.04),
                Text(
                  'Loading your information...',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Information Card
              Container(
                width: double.infinity,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            color: const Color(0xFF199A8E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: const Color(0xFF199A8E),
                            size: screenWidth * 0.06,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Text(
                          'Delivery Information',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF199A8E),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Name Field
                    _buildTextField(
                      controller: nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      screenWidth: screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Phone Field
                    _buildTextField(
                      controller: phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      screenWidth: screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Address Field
                    _buildTextField(
                      controller: addressController,
                      label: 'Street Address',
                      icon: Icons.home,
                      maxLines: 2,
                      screenWidth: screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // City and State Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: cityController,
                            label: 'City',
                            icon: Icons.location_city,
                            screenWidth: screenWidth,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: _buildTextField(
                            controller: stateController,
                            label: 'State',
                            icon: Icons.map,
                            screenWidth: screenWidth,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // ZIP Code Field
                    _buildTextField(
                      controller: zipController,
                      label: 'ZIP Code',
                      icon: Icons.pin_drop,
                      keyboardType: TextInputType.number,
                      screenWidth: screenWidth,
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Order Summary Card
              Container(
                width: double.infinity,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            color: const Color(0xFF199A8E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.shopping_bag,
                            color: const Color(0xFF199A8E),
                            size: screenWidth * 0.06,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF199A8E),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Order Items
                    Obx(() => Column(
                          children: cartVM.cartItems
                              .map((item) => Container(
                                    margin: EdgeInsets.only(
                                        bottom: screenHeight * 0.015),
                                    padding: EdgeInsets.all(screenWidth * 0.03),
                                    decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.image,
                                width: screenWidth * 0.15,
                                height: screenWidth * 0.15,
                                fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              width: screenWidth * 0.15,
                                              height: screenWidth * 0.15,
                                              color: Colors.grey[300],
                                              child: Icon(Icons.image,
                                                  color: Colors.grey[500]),
                                            ),
                                          ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: screenHeight * 0.005),
                                  Text(
                                    'Qty: ${item.quantity}',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                                          'Rs ${(item.price * item.quantity).toStringAsFixed(2)}',
                                          style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF199A8E),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    )),

                    Divider(height: screenHeight * 0.03, thickness: 1),

                    // Price Breakdown
                    Obx(() => Column(
                          children: [
                            _buildPriceRow(
                                'Subtotal', cartVM.subtotal, screenWidth),
                            SizedBox(height: screenHeight * 0.01),
                            _buildPriceRow(
                                'Delivery Fee', cartVM.tax, screenWidth),
                            SizedBox(height: screenHeight * 0.015),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015),
                              decoration: BoxDecoration(
                                color: const Color(0xFF199A8E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _buildPriceRow(
                                  'Total', cartVM.total, screenWidth,
                                  isTotal: true),
                            ),
                      ],
                    )),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Payment Method Card
              Container(
                width: double.infinity,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            color: const Color(0xFF199A8E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.payment,
                            color: const Color(0xFF199A8E),
                            size: screenWidth * 0.06,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Text(
                          'Payment Method',
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
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: const Color(0xFF199A8E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: const Color(0xFF199A8E), width: 2),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.money,
                            color: const Color(0xFF199A8E),
                            size: screenWidth * 0.06,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cash on Delivery',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF199A8E),
                                  ),
                                ),
                                Text(
                                  'Pay when your order arrives',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: const Color(0xFF199A8E),
                            size: screenWidth * 0.06,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Place Order Button
              Obx(() => Container(
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
                      onPressed:
                          orderController.isLoading.value ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: orderController.isLoading.value
                          ? SizedBox(
                              height: screenWidth * 0.06,
                              width: screenWidth * 0.06,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_checkout,
                                  color: Colors.white,
                                  size: screenWidth * 0.05,
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  'Place Order - Rs ${cartVM.total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'bolditalic'),
                      ),
                    ],
                  ),
                ),
                  )),

              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required double screenWidth,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(fontSize: screenWidth * 0.04),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF199A8E)),
        labelStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: const Color(0xFF199A8E), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.04,
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, double screenWidth, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? screenWidth * 0.045 : screenWidth * 0.04,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? const Color(0xFF199A8E) : Colors.grey[600],
          ),
        ),
        Text(
          'Rs ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? screenWidth * 0.045 : screenWidth * 0.04,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? const Color(0xFF199A8E) : Colors.black87,
          ),
        ),
      ],
    );
  }

  void _placeOrder() async {
    // Validate fields
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        stateController.text.trim().isEmpty ||
        zipController.text.trim().isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please fill in all delivery details',
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Convert cart items to order items with comprehensive null safety
    final orderItems = <OrderItem>[];

    for (final cartItem in cartVM.cartItems) {
      try {
        // Validate each cart item field individually
        final productId = cartItem.productId?.toString() ?? '';
        final productName = cartItem.name?.toString() ?? 'Unknown Product';
        final productImage = cartItem.image?.toString() ?? '';
        final price = cartItem.price?.toDouble() ?? 0.0;
        final quantity = cartItem.quantity?.toInt() ?? 1;
        final total = price * quantity;

        if (productId.isEmpty) {
          continue; // Skip this item
        }

        final orderItem = OrderItem(
          productId: productId,
          productName: productName,
          productImage: productImage,
          price: price,
          quantity: quantity,
          total: total,
        );

        orderItems.add(orderItem);
      } catch (e) {
        continue; // Skip this problematic item
      }
    }

    if (orderItems.isEmpty) {
      Get.snackbar(
        'Cart Error',
        'No valid items found in cart. Please add items and try again.',
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    // Create order
    final success = await orderController.createOrder(
      items: orderItems,
      subtotal: cartVM.subtotal,
      deliveryFee: cartVM.tax,
      deliveryAddress: addressController.text.trim().isNotEmpty
          ? addressController.text.trim()
          : 'No address provided',
      city: cityController.text.trim().isNotEmpty
          ? cityController.text.trim()
          : 'Unknown',
      state: stateController.text.trim().isNotEmpty
          ? stateController.text.trim()
          : 'Unknown',
      zipCode: zipController.text.trim().isNotEmpty
          ? zipController.text.trim()
          : '00000',
      showSuccessSnackbar: false,
    );

    if (success) {
      cartVM.clearCartSilently();

      Get.snackbar(
        'Order Placed!',
        'Your order has been placed successfully. You will receive a confirmation call shortly.',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      // Set cart page index and navigate to BottomNavScreen
      bottomNavController.changeIndex(4);
      Get.off(() => BottomNavScreen());
    }
  }
}
