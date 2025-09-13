import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import '../../../../user/controllers/order_controller.dart';
import '../../../../user/models/order_model.dart';

class AdminOrderManagementScreen extends StatefulWidget {
  const AdminOrderManagementScreen({super.key});

  @override
  State<AdminOrderManagementScreen> createState() =>
      _AdminOrderManagementScreenState();
}

class _AdminOrderManagementScreenState extends State<AdminOrderManagementScreen>
    with WidgetsBindingObserver {
  final OrderController orderController = Get.put(OrderController());
  bool _hasLoadedOrders = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize the screen
    _initializeScreen();
  }

  void _initializeScreen() async {
    // Ensure the controller is ready
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted && !_isInitialized) {
      _isInitialized = true;
      // Clear any existing data and load fresh
      orderController.orders.clear();
      orderController.selectedStatus.value = '';
      _loadOrdersOnInit();
    }
  }

  void _loadOrdersOnInit() async {
    // Wait a bit for the widget to be fully built
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted && !_hasLoadedOrders) {
      _hasLoadedOrders = true;
      _loadOrders();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reload orders when app becomes active
    if (state == AppLifecycleState.resumed) {
      _loadOrders();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Removed the automatic order loading here
  }

  Future<void> _loadOrders({bool forceRefresh = false}) async {
    // Prevent multiple simultaneous loads
    if (orderController.isLoading.value && !forceRefresh) {
      return;
    }

    try {
      print('Loading orders...'); // Debug log
      await orderController.loadAllOrders();
      print('Orders loaded: ${orderController.orders.length}'); // Debug log
    } catch (e) {
      print('Error loading orders: $e');
      // Show error message if needed
      if (mounted) {
        Get.showSnackbar(
          GetSnackBar(
            messageText: const Text(
              'Failed to load orders. Please check your connection.',
              style: TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: const Color(0xFFef4444),
            borderRadius: 8,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWeb = screenWidth > 800;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF199A8E).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.04,
                MediaQuery.of(context).padding.top + 16,
                screenWidth * 0.04,
                16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (!isWeb)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF199A8E)),
                      onPressed: () => Get.back(),
                    ),
                  Expanded(
                    child: Text(
                      'Order Management',
                      style: TextStyle(
                        color: const Color(0xFF199A8E),
                        fontSize: isWeb ? 28 : screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: isWeb ? TextAlign.center : TextAlign.start,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF199A8E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFF199A8E)),
                      onPressed: () => _loadOrders(forceRefresh: true),
                      tooltip: 'Refresh Orders',
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: isWeb ? 70 : screenHeight * 0.08,
              margin: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: 16,
              ),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatusTab('All', '', screenWidth, isWeb),
                      _buildStatusTab('Pending', 'pending', screenWidth, isWeb),
                      _buildStatusTab('Accepted', 'accepted', screenWidth, isWeb),
                      _buildStatusTab('Preparing', 'preparing', screenWidth, isWeb),
                      _buildStatusTab('In Transit', 'in_transit', screenWidth, isWeb),
                      _buildStatusTab('Delivered', 'delivered', screenWidth, isWeb),
                      _buildStatusTab('Cancelled', 'cancelled', screenWidth, isWeb),
                    ],
                  ),
                ),
              ),
            ),

            // Orders List
            Expanded(
              child: Obx(() {
                // Debug info
                print(
                    'Orders list rebuild - Loading: ${orderController.isLoading
                        .value}, Orders count: ${orderController.orders
                        .length}');

                if (orderController.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF199A8E),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading orders...',
                          style: TextStyle(
                            fontSize: isWeb ? 18 : screenWidth * 0.04,
                            color: const Color(0xFF374151),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final filteredOrders = orderController.selectedStatus.value.isEmpty
                    ? orderController.orders
                    : orderController.orders.where((order) =>
                order.status == orderController.selectedStatus.value).toList();

                print('Filtered orders count: ${filteredOrders
                    .length}, Selected status: ${orderController.selectedStatus
                    .value}');

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: isWeb ? 80 : screenWidth * 0.2,
                          color: const Color(0xFF199A8E).withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          orderController.selectedStatus.value.isEmpty
                              ? 'No orders found'
                              : 'No ${orderController.selectedStatus.value} orders',
                          style: TextStyle(
                            fontSize: isWeb ? 24 : screenWidth * 0.05,
                            color: const Color(0xFF374151),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Debug info
                        if (kDebugMode)
                          Text(
                            'Total orders: ${orderController.orders
                                .length}\nLoading: ${orderController.isLoading
                                .value}\nSelected: ${orderController
                                .selectedStatus.value}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loadOrders(forceRefresh: true),
                          child: Text('Reload Orders'),
                        ),
                      ],
                    ),
                  );
                }

                return Center(
                  child: Container(
                    width: isWeb ? 800 : double.infinity,
                    child: RefreshIndicator(
                      onRefresh: () => _loadOrders(forceRefresh: true),
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWeb ? 0 : screenWidth * 0.04,
                          vertical: 16,
                        ),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return _buildOrderCard(
                              order, screenWidth, screenHeight, isWeb);
                        },
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTab(String title, String status, double screenWidth, bool isWeb) {
    return Obx(() {
      final isSelected = orderController.selectedStatus.value == status;
      return GestureDetector(
        onTap: () {
          orderController.selectedStatus.value = status;
          // Ensure orders are loaded when status changes
          if (orderController.orders.isEmpty) {
            _loadOrders();
          } else {
            _loadOrders(forceRefresh: true);
          }
        },
        child: Container(
          margin: EdgeInsets.only(right: isWeb ? 12 : screenWidth * 0.02),
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 24 : screenWidth * 0.04,
            vertical: isWeb ? 16 : screenWidth * 0.02,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF199A8E) : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? const Color(0xFF199A8E) : const Color(0xFFe5e7eb),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF199A8E).withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isSelected ? 10 : 5,
                offset:  Offset(0, isSelected ? 4 : 2),
              ),
            ],
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF374151),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: isWeb ? 16 : screenWidth * 0.035,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildOrderCard(OrderModel order, double screenWidth, double screenHeight, bool isWeb) {
    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 24 : screenHeight * 0.02),
      padding: EdgeInsets.all(isWeb ? 24 : screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: TextStyle(
                        fontSize: isWeb ? 20 : screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF199A8E),
                      ),
                    ),
                    SizedBox(height: isWeb ? 8 : screenHeight * 0.005),
                    Text(
                      order.userName,
                      style: TextStyle(
                        fontSize: isWeb ? 16 : screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    Text(
                      order.userPhone,
                      style: TextStyle(
                        fontSize: isWeb ? 14 : screenWidth * 0.035,
                        color: const Color(0xFF6b7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 16 : screenWidth * 0.03,
                  vertical: isWeb ? 8 : screenWidth * 0.015,
                ),
                decoration: BoxDecoration(
                  color: orderController.getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: orderController.getStatusColor(order.status),
                  ),
                ),
                child: Text(
                  orderController.getStatusDisplayText(order.status),
                  style: TextStyle(
                    color: orderController.getStatusColor(order.status),
                    fontWeight: FontWeight.bold,
                    fontSize: isWeb ? 12 : screenWidth * 0.03,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isWeb ? 16 : screenHeight * 0.015),

          // Address
          Container(
            padding: EdgeInsets.all(isWeb ? 12 : screenWidth * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFF199A8E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: const Color(0xFF199A8E), size: isWeb ? 20 : screenWidth * 0.045),
                SizedBox(width: isWeb ? 8 : screenWidth * 0.02),
                Expanded(
                  child: Text(
                    '${order.deliveryAddress}, ${order.city}, ${order.state} ${order.zipCode}',
                    style: TextStyle(
                      fontSize: isWeb ? 14 : screenWidth * 0.035,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isWeb ? 16 : screenHeight * 0.015),

          // Order Items
          Text(
            'Items (${order.items.length})',
            style: TextStyle(
              fontSize: isWeb ? 16 : screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF374151),
            ),
          ),
          SizedBox(height: isWeb ? 8 : screenHeight * 0.01),

          ...order.items.take(2).map((item) => Container(
            margin: EdgeInsets.only(bottom: isWeb ? 8 : screenHeight * 0.01),
            padding: EdgeInsets.all(isWeb ? 12 : screenWidth * 0.025),
            decoration: BoxDecoration(
              color: const Color(0xFFf8f9fa),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.productImage,
                    width: isWeb ? 50 : screenWidth * 0.1,
                    height: isWeb ? 50 : screenWidth * 0.1,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: isWeb ? 50 : screenWidth * 0.1,
                      height: isWeb ? 50 : screenWidth * 0.1,
                      color: const Color(0xFFe5e7eb),
                      child: const Icon(Icons.image, color: Color(0xFF6b7280)),
                    ),
                  ),
                ),
                SizedBox(width: isWeb ? 12 : screenWidth * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: TextStyle(
                          fontSize: isWeb ? 14 : screenWidth * 0.035,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Qty: ${item.quantity} × Rs ${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: isWeb ? 12 : screenWidth * 0.03,
                          color: const Color(0xFF6b7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rs ${item.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isWeb ? 14 : screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF199A8E),
                  ),
                ),
              ],
            ),
          )).toList(),

          if (order.items.length > 2)
            Text(
              '+ ${order.items.length - 2} more items',
              style: TextStyle(
                fontSize: isWeb ? 12 : screenWidth * 0.03,
                color: const Color(0xFF6b7280),
                fontStyle: FontStyle.italic,
              ),
            ),

          SizedBox(height: isWeb ? 16 : screenHeight * 0.015),

          // Total
          Container(
            padding: EdgeInsets.all(isWeb ? 16 : screenWidth * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFF199A8E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: isWeb ? 16 : screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Rs ${order.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isWeb ? 18 : screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isWeb ? 12 : screenHeight * 0.01),

          // Order Date
          Text(
            'Ordered on ${_formatDate(order.createdAt)}',
            style: TextStyle(
              fontSize: isWeb ? 12 : screenWidth * 0.03,
              color: const Color(0xFF6b7280),
            ),
          ),

          if (order.adminNotes != null && order.adminNotes!.isNotEmpty) ...[
            SizedBox(height: isWeb ? 12 : screenHeight * 0.01),
            Container(
              padding: EdgeInsets.all(isWeb ? 12 : screenWidth * 0.03),
              decoration: BoxDecoration(
                color: const Color(0xFFdbeafe),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Admin Notes: ${order.adminNotes!}',
                style: TextStyle(
                  fontSize: isWeb ? 12 : screenWidth * 0.03,
                  color: const Color(0xFF1e40af),
                ),
              ),
            ),
          ],

          SizedBox(height: isWeb ? 16 : screenHeight * 0.015),

          if (order.status != 'delivered' && order.status != 'cancelled')
            Row(
              children: [
                if (order.status == 'pending') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatusDirectly(order.id, 'accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF199A8E),
                        padding: EdgeInsets.symmetric(
                          vertical: isWeb ? 12 : screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Accept Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWeb ? 14 : screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isWeb ? 12 : screenWidth * 0.02),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatusDirectly(order.id, 'cancelled'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFef4444),
                        padding: EdgeInsets.symmetric(
                          vertical: isWeb ? 12 : screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Reject Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWeb ? 14 : screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                if (order.status == 'accepted') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatusDirectly(order.id, 'preparing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8b5cf6),
                        padding: EdgeInsets.symmetric(
                          vertical: isWeb ? 12 : screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Start Preparing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWeb ? 14 : screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                if (order.status == 'preparing') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatusDirectly(order.id, 'in_transit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06b6d4),
                        padding: EdgeInsets.symmetric(
                          vertical: isWeb ? 12 : screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Out for Delivery',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWeb ? 14 : screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                if (order.status == 'in_transit') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatusDirectly(order.id, 'delivered'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF199A8E),
                        padding: EdgeInsets.symmetric(
                          vertical: isWeb ? 12 : screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Mark Delivered',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWeb ? 14 : screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  void _updateOrderStatusDirectly(String orderId, String newStatus) async {
    final success = await orderController.updateOrderStatus(orderId, newStatus);

    if (success) {
      Get.showSnackbar(
        GetSnackBar(
          messageText: const Text(
            'Order status updated successfully!',
            style: TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF199A8E),
          borderRadius: 8,
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      Get.showSnackbar(
        GetSnackBar(
          messageText: const Text(
            'Failed to update order status. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: const Color(0xFFef4444),
          borderRadius: 8,
          margin: const EdgeInsets.all(16),
        ),
      );
    }

  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
