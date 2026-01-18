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
      // Parameters are non-nullable; validate they are not empty
      if (deliveryAddress.trim().isEmpty ||
          city.trim().isEmpty ||
          state.trim().isEmpty ||
          zipCode.trim().isEmpty) {
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
        if (item.productId.trim().isEmpty) {
          _showErrorSnackbar(
              'Invalid product ID found for ${item.productName}. Please refresh your cart.');
          return false;
        }
        if (item.productName.trim().isEmpty) {
          _showErrorSnackbar(
              'Invalid product name found. Please refresh your cart.');
          return false;
        }
        if (item.productImage.trim().isEmpty) {
          _showErrorSnackbar(
              'Invalid product image found. Please refresh your cart.');
          return false;
        }
      }

      // Get user data from Firestore with comprehensive null checking
      DocumentSnapshot userDoc;
      try {
        userDoc = await _firestore.collection('users').doc(user.uid).get();
      } catch (e) {
        _showErrorSnackbar('Failed to fetch user profile: ${e.toString()}');
        return false;
      }

      if (!userDoc.exists) {
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
        final finalOrderId = orderId;
        final finalUserId = user.uid;
        final finalUserName = userName;
        final finalUserPhone = userPhone;
        final finalUserEmail = userEmail;
        final finalDeliveryAddress = deliveryAddress;
        final finalCity = city;
        final finalState = state;
        final finalZipCode = zipCode;
        final finalItems = items;
        final finalSubtotal = subtotal;
        final finalDeliveryFee = deliveryFee;

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

      // Update product stock now that order is created. This is a best-effort
      // client-side update — if Cloud Functions are not deployed, this will
      // update stockQuantity and soldCount using the narrow rules we added.
      try {
        await _updateProductStockWithLogging(items, orderId);
      } catch (e) {
        print('Warning: failed to update product stock after order creation: $e');
      }

      currentOrder.value = order;
      orders.insert(0, order);

      if (showSuccessSnackbar) {
        _showSuccessSnackbar('Order placed successfully!');

        // Also show a blocking confirmation dialog so the user sees the next step
        try {
          Get.defaultDialog(
            title: 'Order Placed',
            middleText:
                'Your order has been placed successfully. You will receive a confirmation call shortly.',
            textConfirm: 'OK',
            onConfirm: () {
              Get.back();
            },
            barrierDismissible: false,
          );
        } catch (e) {
          // ignore dialog errors silently
        }
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

      // Determine previous status and items (from local cache or Firestore)
      String? previousStatus;
      List<OrderItem> items = [];
      final orderIndex = orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        previousStatus = orders[orderIndex].status;
        items = orders[orderIndex].items;
      } else {
        // Try to fetch from Firestore as fallback
        try {
          final doc = await _firestore.collection('orders').doc(orderId).get();
          if (doc.exists) {
            final map = doc.data() as Map<String, dynamic>;
            previousStatus = map['status']?.toString();
            items = (map['items'] as List<dynamic>?)?.map((m) => OrderItem.fromMap(m as Map<String, dynamic>)).toList() ?? [];
          }
        } catch (e) {
          print('Warning: failed to fetch order details for status update: $e');
        }
      }

      final updateData = {
        'status': newStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (adminNotes != null) {
        updateData['adminNotes'] = adminNotes;
      }

      await _firestore.collection('orders').doc(orderId).update(updateData);

      // Update local orders list
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

      // If the order was cancelled by admin (or updated to 'cancelled'), restore stock.
      // Only restore if previousStatus was not already 'cancelled' to avoid double-restores.
      if (newStatus == 'cancelled' && previousStatus != null && previousStatus != 'cancelled') {
        try {
          await _restoreProductStockWithLogging(items, orderId);
        } catch (e) {
          print('Warning: failed to restore product stock after cancellation: $e');
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

        // Stock restore is handled by server-side Cloud Function; no client-side restore here.
        // Try client-side restore (best-effort) if functions aren't available.
        try {
          await _restoreProductStockWithLogging(orders[orderIndex].items, orderId);
        } catch (e) {
          print('Warning: client restore failed (order cancelled): $e');
        }
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
    // First commit product stock updates in a batch so they succeed even if logs are not writable
    final updateBatch = _firestore.batch();
    final logsToWrite = <Map<String, dynamic>>[];

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

        // Prepare product stock update
        updateBatch.update(productRef, {
          'stockQuantity': newStock, // Use stockQuantity field name
          'soldCount': FieldValue.increment(item.quantity),
          'updatedAt': DateTime.now().toIso8601String(),
          'orderId': orderId,
          'lastUpdatedBy': _auth.currentUser?.uid ?? '' ,
        });

        // Prepare stock log entry data for separate write
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

        logsToWrite.add({
          'docRef': _firestore.collection('inventory_logs').doc(logId),
          'data': stockLog.toMap(),
        });
      }
    }

    // Commit product updates first
    var productUpdateSucceeded = true;
    try {
      await updateBatch.commit();

      // If batch commit succeeded, mark order doc accordingly (best-effort)
      try {
        await _firestore.collection('orders').doc(orderId).update({
          'stockUpdateStatus': 'updated_by_client',
          'stockUpdatedAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // ignore: couldn't write status to order (maybe permission denied)
        print('Warning: could not write stockUpdateStatus to order $orderId: $e');
      }
    } on FirebaseException catch (e) {
      // If permission denied for product updates, log and continue without failing the whole order
      if (e.code == 'permission-denied') {
        productUpdateSucceeded = false;
        print('Product stock update skipped: insufficient permissions. Order ${orderId} was created without updating product stock. Error: ${e.message}');

        // Try to record this on the order doc so it's visible for debugging (best-effort)
        try {
          await _firestore.collection('orders').doc(orderId).update({
            'stockUpdateStatus': 'permission_denied_client',
            'stockUpdateError': e.message ?? e.toString(),
            'stockUpdatedAt': DateTime.now().toIso8601String(),
          });
        } catch (e2) {
          print('Warning: failed to write stockUpdate permission status to order: $e2');
        }
      } else {
        // Re-throw other Firebase exceptions so caller can handle them
        rethrow;
      }
    } catch (e) {
      // Non-Firebase exceptions should propagate
      rethrow;
    }

    // Attempt to write logs in a separate batch only if the product update succeeded.
    // If product updates were skipped due to permissions, skip logs to avoid inconsistent entries.
    if (logsToWrite.isNotEmpty && productUpdateSucceeded) {
      try {
        final logBatch = _firestore.batch();
        for (final logEntry in logsToWrite) {
          logBatch.set(logEntry['docRef'] as DocumentReference, logEntry['data']);
        }
        await logBatch.commit();
      } on FirebaseException catch (e) {
        // Permission errors are common if rules prevent writing logs from client; don't fail the order
        if (e.code == 'permission-denied') {
          // Log quietly
          print('Inventory log write skipped: insufficient permissions.');
        } else {
          print('Inventory log write failed: ${e.toString()}');
        }
      } catch (e) {
        print('Inventory log write failed: ${e.toString()}');
      }
    }
  }

  Future<void> _restoreProductStockWithLogging(List<OrderItem> items, String orderId) async {
    // First commit product stock restores in a batch so they succeed even if logs are not writable
    final updateBatch = _firestore.batch();
    final logsToWrite = <Map<String, dynamic>>[];

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

        // Prepare product stock restore
        updateBatch.update(productRef, {
          'stockQuantity': newStock, // Use stockQuantity field name
          'soldCount': FieldValue.increment(-item.quantity),
          'updatedAt': DateTime.now().toIso8601String(),
          'orderId': orderId,
          'lastUpdatedBy': _auth.currentUser?.uid ?? '' ,
        });

        // Prepare stock log entry data for separate write
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

        logsToWrite.add({
          'docRef': _firestore.collection('inventory_logs').doc(logId),
          'data': stockLog.toMap(),
        });
      }
    }

    // Commit product restores first
    var productRestoreSucceeded = true;
    try {
      await updateBatch.commit();

      // Mark order that client restored stock successfully (best-effort)
      try {
        await _firestore.collection('orders').doc(orderId).update({
          'stockUpdateStatus': 'restored_by_client',
          'stockUpdatedAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        print('Warning: could not write stock restore status to order $orderId: $e');
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        productRestoreSucceeded = false;
        print('Product stock restore skipped: insufficient permissions.');
        try {
          await _firestore.collection('orders').doc(orderId).update({
            'stockUpdateStatus': 'permission_denied_restore',
            'stockUpdateError': e.message ?? e.toString(),
            'stockUpdatedAt': DateTime.now().toIso8601String(),
          });
        } catch (e2) {
          print('Warning: failed to write stock restore permission status to order: $e2');
        }
      } else {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }

    // Attempt to write logs in a separate batch only if the product restore succeeded.
    if (logsToWrite.isNotEmpty && productRestoreSucceeded) {
      try {
        final logBatch = _firestore.batch();
        for (final logEntry in logsToWrite) {
          logBatch.set(logEntry['docRef'] as DocumentReference, logEntry['data']);
        }
        await logBatch.commit();
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          print('Inventory log write skipped: insufficient permissions.');
        } else {
          print('Inventory log write failed: ${e.toString()}');
        }
      } catch (e) {
        print('Inventory log write failed: ${e.toString()}');
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    // Prefer ScaffoldMessenger if context is available (works with MaterialApp)
    try {
      final ctx = Get.context;
      if (ctx != null) {
        try {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(message, style: const TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFF4CAF50),
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        } catch (_) {
          // Fall through to Get.snackbar if ScaffoldMessenger isn't available
        }
      }

      // Fallback to Get.snackbar (wrapped in try/catch to avoid overlay errors)
      try {
        Get.snackbar(
          'Success',
          message,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } catch (e) {
        // As a last resort, log to console
        print('Success message (no UI): $message');
      }
    } catch (e) {
      print('Failed to show success message: $message');
    }
  }

  void _showErrorSnackbar(String message) {
    // Prefer ScaffoldMessenger if context is available (works with MaterialApp)
    try {
      final ctx = Get.context;
      if (ctx != null) {
        try {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(message, style: const TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFFF44336),
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        } catch (_) {
          // Fall through to Get.snackbar if ScaffoldMessenger isn't available
        }
      }

      // Fallback to Get.snackbar (wrapped in try/catch to avoid overlay errors)
      try {
        Get.snackbar(
          'Error',
          message,
          backgroundColor: const Color(0xFFF44336),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } catch (e) {
        // As a last resort, log to console
        print('Error message (no UI): $message');
      }
    } catch (e) {
      print('Failed to show error message: $message');
    }
  }
}
