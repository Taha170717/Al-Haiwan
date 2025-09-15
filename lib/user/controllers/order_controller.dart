import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../admin/models/product_order_model.dart';
import '../models/order_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var orders = <OrderModel>[].obs;
  var filteredOrders = <OrderModel>[].obs;
  var currentOrder = Rxn<OrderModel>();
  var selectedStatus = ''.obs;
  var tempAdminNotes = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserOrders();
  }

  // Create new order
  Future<bool> createOrder({
    required List<OrderItem> items,
    required double subtotal,
    required double deliveryFee,
    required String deliveryAddress,
    required String city,
    required String state,
    required String zipCode,
    bool showSuccessSnackbar = true,
  }) async {
    try {
      isLoading.value = true;

      // Validate all input parameters
      if (deliveryAddress == null ||
          city == null ||
          state == null ||
          zipCode == null) {
        _showErrorSnackbar('Invalid delivery information provided');
        return false;
      }

      final user = _auth.currentUser;
      if (user == null) {
        _showErrorSnackbar('Please login to place order');
        return false;
      }

      // Validate all product IDs are non-empty
      for (final item in items) {
        if (item.productId == null ||
            item.productId.isEmpty ||
            item.productId.trim().isEmpty) {
          _showErrorSnackbar(
              'Invalid product ID found for ${item.productName ?? "unknown product"}. Please refresh your cart.');
          return false;
        }
        if (item.productName == null) {
          _showErrorSnackbar(
              'Invalid product name found. Please refresh your cart.');
          return false;
        }
        if (item.productImage == null) {
          _showErrorSnackbar(
              'Invalid product image found. Please refresh your cart.');
          return false;
        }
      }

      // Get user data from Firestore with comprehensive null checking
      DocumentSnapshot? userDoc;
      try {
        userDoc = await _firestore.collection('users').doc(user.uid).get();
      } catch (e) {
        _showErrorSnackbar('Failed to fetch user profile: ${e.toString()}');
        return false;
      }

      if (userDoc == null || !userDoc.exists) {
        _showErrorSnackbar('User profile not found');
        return false;
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      if (userData == null) {
        _showErrorSnackbar('User profile data is invalid');
        return false;
      }

      // Extract user data with maximum safety
      String userName;
      String userPhone;
      String userEmail;

      try {
        final usernameRaw = userData['username'] ?? userData['name'] ?? 'User';
        final phoneRaw = userData['phone'] ?? '';
        final emailRaw = userData['email'] ?? user.email ?? '';

        userName = usernameRaw?.toString() ?? 'User';
        userPhone = phoneRaw?.toString() ?? '';
        userEmail = emailRaw?.toString() ?? '';

      } catch (e) {
        _showErrorSnackbar('Error processing user data: ${e.toString()}');
        return false;
      }

      // Check stock availability before creating order
      for (final item in items) {
        try {
          // print('=== CHECKING PRODUCT: ${item.productName} ===');
          // print('Product ID: "${item.productId}"');

          final productDoc = await _firestore
              .collection('products')
              .doc(item.productId.trim())
              .get();

          if (!productDoc.exists) {
            _showErrorSnackbar(
                'Product ${item.productName} not found in database');
            return false;
          }

          final productData = productDoc.data();
          if (productData == null) {
            _showErrorSnackbar('Product ${item.productName} has no data');
            return false;
          }

          ProductModel product;
          try {
            product = ProductModel.fromMap(productData);
            // print('Product parsed successfully: ${product.name}');
            // print('=== PARSED PRODUCT DETAILS ===');
            // print('Product ID: ${product.id}');
            // print('Product Name: ${product.name}');
            // print('Product Stock: ${product.stock}');
            // print('Product SoldCount: ${product.soldCount}');
            // print('Product isActive: ${product.isActive}');
          } catch (e) {
            // print('ERROR parsing ProductModel: $e');
            _showErrorSnackbar('Error reading product ${item.productName}: $e');
            return false;
          }

          if (product.stock < item.quantity) {
            _showErrorSnackbar(
                'Insufficient stock for ${item.productName}. Available: ${product.stock}, Requested: ${item.quantity}');
            return false;
          }

          // print(
          //     'Stock check passed for ${product.name}: ${product.stock} available, ${item.quantity} requested');
        } catch (e) {
          // print('ERROR in stock check: $e');
          _showErrorSnackbar(
              'Error checking product ${item.productName}: ${e.toString()}');
          return false;
        }
      }

      final orderId = _firestore.collection('orders').doc().id;

      OrderModel? order;
      try {
        // Final validation before creating order
        final finalOrderId = orderId ?? 'unknown';
        final finalUserId = user.uid ?? 'unknown';
        final finalUserName = userName ?? 'User';
        final finalUserPhone = userPhone ?? '';
        final finalUserEmail = userEmail ?? '';
        final finalDeliveryAddress = deliveryAddress ?? 'No address provided';
        final finalCity = city ?? 'Unknown';
        final finalState = state ?? 'Unknown';
        final finalZipCode = zipCode ?? '00000';
        final finalItems = items ?? <OrderItem>[];
        final finalSubtotal = subtotal ?? 0.0;
        final finalDeliveryFee = deliveryFee ?? 0.0;

        order = OrderModel(
          id: finalOrderId,
          userId: finalUserId,
          userName: finalUserName,
          userPhone: finalUserPhone,
          userEmail: finalUserEmail,
          deliveryAddress: finalDeliveryAddress,
          city: finalCity,
          state: finalState,
          zipCode: finalZipCode,
          items: finalItems,
          subtotal: finalSubtotal,
          deliveryFee: finalDeliveryFee,
          total: finalSubtotal + finalDeliveryFee,
          paymentMethod: 'Cash on Delivery',
          status: 'pending',
          createdAt: DateTime.now(),
        );
        // print('Order model created successfully');

        // print('=== TESTING ORDER TO MAP ===');
        Map<String, dynamic>? orderMap;
        try {
          orderMap = order.toMap();
          // print('Order toMap() successful');
          // print('Map keys: ${orderMap.keys.toList()}');

          // Check for any null values in the map
          orderMap.forEach((key, value) {
            if (value == null) {
              // print('WARNING: Null value found for key: $key');
            }
          });
        } catch (e) {
          // print('ERROR in order.toMap(): $e');
          _showErrorSnackbar('Error converting order to map: $e');
          return false;
        }

        // print('=== WRITING TO FIRESTORE ===');
        try {
          await _firestore.collection('orders').doc(orderId).set(orderMap);
          // print('Firestore write successful');
        } catch (e) {
          // print('ERROR writing to Firestore: $e');
          _showErrorSnackbar('Error saving order to database: $e');
          return false;
        }
      } catch (e) {
        _showErrorSnackbar('Error creating order: ${e.toString()}');
        // print('ORDER CREATION ERROR: $e');
        return false;
      }

      // Update product stock with detailed logging
      await _updateProductStockWithLogging(items, orderId);

      currentOrder.value = order;
      orders.insert(0, order);

      if (showSuccessSnackbar) {
        _showSuccessSnackbar('Order placed successfully!');
      }
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to place order: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Load user orders
  Future<void> loadUserOrders() async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) return;

      // Fetch orders without orderBy to avoid index requirement
      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();

      // Sort the results in memory instead of using Firestore orderBy
      final ordersList = querySnapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data()))
          .toList();

      // Sort by createdAt in descending order
      ordersList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      orders.value = ordersList;
      filteredOrders.value = orders;
    } catch (e) {
      _showErrorSnackbar('Failed to load orders: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load all orders (Admin only)
  Future<void> loadAllOrders() async {
    try {
      isLoading.value = true;

      // Fetch all orders without orderBy to avoid potential index issues
      final querySnapshot = await _firestore
          .collection('orders')
          .get();

      // Sort the results in memory instead of using Firestore orderBy
      final ordersList = querySnapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data()))
          .toList();

      // Sort by createdAt in descending order
      ordersList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      orders.value = ordersList;
      filteredOrders.value = orders;
    } catch (e) {
      _showErrorSnackbar('Failed to load orders: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Filter orders by status
  void filterOrdersByStatus(String status) {
    if (status.isEmpty) {
      filteredOrders.value = orders;
    } else {
      filteredOrders.value = orders.where((order) => order.status == status).toList();
    }
  }

  // Update order status (Admin only)
  Future<bool> updateOrderStatus(String orderId, String newStatus, {String? adminNotes}) async {
    try {
      isLoading.value = true;

      final updateData = {
        'status': newStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (adminNotes != null) {
        updateData['adminNotes'] = adminNotes;
      }

      await _firestore.collection('orders').doc(orderId).update(updateData);

      // Update local orders list
      final orderIndex = orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        orders[orderIndex] = orders[orderIndex].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
          adminNotes: adminNotes,
        );

        // Update filtered orders as well
        final filteredIndex = filteredOrders.indexWhere((order) => order.id == orderId);
        if (filteredIndex != -1) {
          filteredOrders[filteredIndex] = filteredOrders[filteredIndex].copyWith(
            status: newStatus,
            updatedAt: DateTime.now(),
            adminNotes: adminNotes,
          );
        }
      }

      _showSuccessSnackbar('Order status updated to ${newStatus.replaceAll('_', ' ')}');
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to update order: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      isLoading.value = true;

      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update local orders list
      final orderIndex = orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        orders[orderIndex] = orders[orderIndex].copyWith(
          status: 'cancelled',
          updatedAt: DateTime.now(),
        );

        // Restore product stock with detailed logging
        await _restoreProductStockWithLogging(orders[orderIndex].items, orderId);
      }

      _showSuccessSnackbar('Order cancelled successfully');
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to cancel order: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update product stock when order is placed
  Future<void> _updateProductStock(List<OrderItem> items) async {
    final batch = _firestore.batch();

    for (final item in items) {
      final productRef = _firestore.collection('products').doc(item.productId);
      batch.update(productRef, {
        'stockQuantity': FieldValue.increment(-item.quantity),
        // Use stockQuantity field name
        'soldCount': FieldValue.increment(item.quantity),
      });
    }

    await batch.commit();
  }

  // Restore product stock when order is cancelled
  Future<void> _restoreProductStock(List<OrderItem> items) async {
    final batch = _firestore.batch();

    for (final item in items) {
      final productRef = _firestore.collection('products').doc(item.productId);
      batch.update(productRef, {
        'stockQuantity': FieldValue.increment(item.quantity),
        // Use stockQuantity field name
        'soldCount': FieldValue.increment(-item.quantity),
      });
    }

    await batch.commit();
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      _showErrorSnackbar('Failed to load order: ${e.toString()}');
      return null;
    }
  }

  // Get orders by status
  List<OrderModel> getOrdersByStatus(String status) {
    return orders.where((order) => order.status == status).toList();
  }

  // Get order status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFF9800);
      case 'accepted':
        return const Color(0xFF2196F3);
      case 'preparing':
        return const Color(0xFF9C27B0);
      case 'in_transit':
        return const Color(0xFF00BCD4);
      case 'delivered':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF757575);
    }
  }

  // Get order status display text
  String getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'preparing':
        return 'Preparing';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Future<void> _updateProductStockWithLogging(List<OrderItem> items, String orderId) async {
    final batch = _firestore.batch();

    for (final item in items) {
      if (item.productId.isEmpty || item.productId.trim().isEmpty) {
        continue; // Skip items with invalid product IDs
      }

      final productRef =
          _firestore.collection('products').doc(item.productId.trim());
      final productDoc = await productRef.get();

      if (productDoc.exists) {
        final product = ProductModel.fromMap(productDoc.data()!);
        final previousStock = product.stock;
        final newStock = previousStock - item.quantity;

        // Update product stock and sold count
        batch.update(productRef, {
          'stockQuantity': newStock, // Use stockQuantity field name
          'soldCount': FieldValue.increment(item.quantity),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Create stock log entry
        final logId = _firestore.collection('inventory_logs').doc().id;
        final stockLog = StockLogModel(
          id: logId,
          productId: item.productId.trim(),
          productName: item.productName,
          action: 'order_placed',
          quantityChanged: -item.quantity,
          previousStock: previousStock,
          newStock: newStock,
          orderId: orderId,
          createdAt: DateTime.now(),
        );

        batch.set(_firestore.collection('inventory_logs').doc(logId), stockLog.toMap());
      }
    }

    await batch.commit();
  }

  Future<void> _restoreProductStockWithLogging(List<OrderItem> items, String orderId) async {
    final batch = _firestore.batch();

    for (final item in items) {
      if (item.productId.isEmpty || item.productId.trim().isEmpty) {
        continue; // Skip items with invalid product IDs
      }

      final productRef =
          _firestore.collection('products').doc(item.productId.trim());
      final productDoc = await productRef.get();

      if (productDoc.exists) {
        final product = ProductModel.fromMap(productDoc.data()!);
        final previousStock = product.stock;
        final newStock = previousStock + item.quantity;

        // Restore product stock and sold count
        batch.update(productRef, {
          'stockQuantity': newStock, // Use stockQuantity field name
          'soldCount': FieldValue.increment(-item.quantity),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Create stock log entry
        final logId = _firestore.collection('inventory_logs').doc().id;
        final stockLog = StockLogModel(
          id: logId,
          productId: item.productId.trim(),
          productName: item.productName,
          action: 'order_cancelled',
          quantityChanged: item.quantity,
          previousStock: previousStock,
          newStock: newStock,
          orderId: orderId,
          reason: 'Order cancelled - stock restored',
          createdAt: DateTime.now(),
        );

        batch.set(_firestore.collection('inventory_logs').doc(logId), stockLog.toMap());
      }
    }

    await batch.commit();
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: const Color(0xFFF44336),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
