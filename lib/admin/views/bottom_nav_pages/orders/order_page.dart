import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../user/controllers/order_controller.dart';
import '../../../../user/models/order_model.dart';

class AdminOrderManagementScreen extends StatelessWidget {
  final OrderController orderController = Get.put(OrderController());

  AdminOrderManagementScreen({super.key}) {
    // Load all orders when screen opens
    orderController.loadAllOrders();
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
        title: Text(
          'Order Management',
          style: TextStyle(
              color: const Color(0xFF199A8E),
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.bold,
              fontFamily: 'bolditalic'
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: const Color(0xFF199A8E)),
            onPressed: () => orderController.loadAllOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Order Status Filter Tabs
          Container(
            height: screenHeight * 0.08,
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildStatusTab('All', '', screenWidth),
                _buildStatusTab('Pending', 'pending', screenWidth),
                _buildStatusTab('Accepted', 'accepted', screenWidth),
                _buildStatusTab('Preparing', 'preparing', screenWidth),
                _buildStatusTab('In Transit', 'in_transit', screenWidth),
                _buildStatusTab('Delivered', 'delivered', screenWidth),
                _buildStatusTab('Cancelled', 'cancelled', screenWidth),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          // Orders List
          Expanded(
            child: Obx(() {
              if (orderController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF199A8E),
                  ),
                );
              }

              if (orderController.orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: screenWidth * 0.2,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'No orders found',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                itemCount: orderController.orders.length,
                itemBuilder: (context, index) {
                  final order = orderController.orders[index];
                  return _buildOrderCard(order, screenWidth, screenHeight);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(String title, String status, double screenWidth) {
    return Obx(() {
      final isSelected = orderController.selectedStatus.value == status;
      return GestureDetector(
        onTap: () {
          orderController.selectedStatus.value = status;
          orderController.filterOrdersByStatus(status);
        },
        child: Container(
          margin: EdgeInsets.only(right: screenWidth * 0.02),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.02,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF199A8E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF199A8E) : Colors.grey[300]!,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: const Color(0xFF199A8E).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildOrderCard(OrderModel order, double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.04),
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
          // Order Header
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
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF199A8E),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      order.userName,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      order.userPhone,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenWidth * 0.015,
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
                    fontSize: screenWidth * 0.032,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.015),

          // Delivery Address
          Container(
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: const Color(0xFF199A8E),
                  size: screenWidth * 0.05,
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    '${order.deliveryAddress}, ${order.city}, ${order.state} ${order.zipCode}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.015),

          // Order Items
          Text(
            'Items (${order.items.length})',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),

          ...order.items.take(2).map((item) => Container(
            margin: EdgeInsets.only(bottom: screenHeight * 0.01),
            padding: EdgeInsets.all(screenWidth * 0.025),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.productImage,
                    width: screenWidth * 0.12,
                    height: screenWidth * 0.12,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
                      color: Colors.grey[300],
                      child: Icon(Icons.image, color: Colors.grey[500]),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Qty: ${item.quantity} × Rs ${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rs ${item.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
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
                fontSize: screenWidth * 0.032,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),

          SizedBox(height: screenHeight * 0.015),

          // Order Total
          Container(
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFF199A8E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rs ${order.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF199A8E),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.015),

          // Order Date
          Text(
            'Ordered on ${_formatDate(order.createdAt)}',
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: Colors.grey[600],
            ),
          ),

          if (order.adminNotes != null && order.adminNotes!.isNotEmpty) ...[
            SizedBox(height: screenHeight * 0.01),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.note, color: Colors.blue[600], size: screenWidth * 0.04),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Text(
                      order.adminNotes!,
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: screenHeight * 0.02),

          // Action Buttons
          if (order.status != 'delivered' && order.status != 'cancelled')
            Row(
              children: [
                if (order.status == 'pending') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatus(order.id, 'accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Accept Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatus(order.id, 'cancelled'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF44336),
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Reject Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                if (order.status == 'accepted') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatus(order.id, 'preparing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Start Preparing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                if (order.status == 'preparing') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatus(order.id, 'in_transit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Out for Delivery',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                if (order.status == 'in_transit') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatus(order.id, 'delivered'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Mark Delivered',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.035,
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

  void _updateOrderStatus(String orderId, String newStatus) {
    Get.dialog(
      AlertDialog(
        title: Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Change order status to ${orderController.getStatusDisplayText(newStatus)}?'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Admin Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => orderController.tempAdminNotes.value = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              orderController.tempAdminNotes.value = '';
              Get.back();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await orderController.updateOrderStatus(
                orderId,
                newStatus,
                adminNotes: orderController.tempAdminNotes.value.isNotEmpty
                    ? orderController.tempAdminNotes.value
                    : null,
              );
              if (success) {
                orderController.tempAdminNotes.value = '';
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF199A8E),
            ),
            child: Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
