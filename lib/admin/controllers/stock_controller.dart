import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_order_model.dart';

class StockController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var products = <ProductModel>[].obs;
  var stockLogs = <StockLogModel>[].obs;
  var lowStockProducts = <ProductModel>[].obs;
  var outOfStockProducts = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    loadStockLogs();
  }

  // Load all products
  Future<void> loadProducts() async {
    try {
      isLoading.value = true;

      final querySnapshot = await _firestore
          .collection('products')
          .orderBy('name')
          .get();

      products.value = querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();

      _updateStockAlerts();
    } catch (e) {
      _showErrorSnackbar('Failed to load products: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load stock logs
  Future<void> loadStockLogs() async {
    try {
      final querySnapshot = await _firestore
          .collection('inventory_logs')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      stockLogs.value = querySnapshot.docs
          .map((doc) => StockLogModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      _showErrorSnackbar('Failed to load stock logs: ${e.toString()}');
    }
  }

  // Update product stock manually (Admin only)
  Future<bool> updateProductStock(String productId, int newStock, {String? reason}) async {
    try {
      isLoading.value = true;

      final productDoc = await _firestore.collection('products').doc(productId).get();
      if (!productDoc.exists) {
        _showErrorSnackbar('Product not found');
        return false;
      }

      final product = ProductModel.fromMap(productDoc.data()!);
      final previousStock = product.stock;
      final quantityChanged = newStock - previousStock;

      // Update product stock
      await _firestore.collection('products').doc(productId).update({
        'stockQuantity': newStock,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Log the stock change
      await _logStockChange(
        productId: productId,
        productName: product.name,
        action: 'manual_adjustment',
        quantityChanged: quantityChanged,
        previousStock: previousStock,
        newStock: newStock,
        reason: reason,
      );

      // Update local products list
      final productIndex = products.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        products[productIndex] = products[productIndex].copyWith(
          stock: newStock,
          updatedAt: DateTime.now(),
        );
      }

      _updateStockAlerts();
      _showSuccessSnackbar('Stock updated successfully');
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to update stock: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Restock product (Admin only)
  Future<bool> restockProduct(String productId, int quantity, {String? reason}) async {
    try {
      isLoading.value = true;

      final productDoc = await _firestore.collection('products').doc(productId).get();
      if (!productDoc.exists) {
        _showErrorSnackbar('Product not found');
        return false;
      }

      final product = ProductModel.fromMap(productDoc.data()!);
      final previousStock = product.stock;
      final newStock = previousStock + quantity;

      // Update product stock
      await _firestore.collection('products').doc(productId).update({
        'stockQuantity': newStock,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Log the restock
      await _logStockChange(
        productId: productId,
        productName: product.name,
        action: 'restock',
        quantityChanged: quantity,
        previousStock: previousStock,
        newStock: newStock,
        reason: reason ?? 'Product restocked',
      );

      // Update local products list
      final productIndex = products.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        products[productIndex] = products[productIndex].copyWith(
          stock: newStock,
          updatedAt: DateTime.now(),
        );
      }

      _updateStockAlerts();
      _showSuccessSnackbar('Product restocked successfully');
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to restock product: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update minimum stock level
  Future<bool> updateMinStockLevel(String productId, int minLevel) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'minStockLevel': minLevel,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update local products list
      final productIndex = products.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        products[productIndex] = products[productIndex].copyWith(
          minStockLevel: minLevel,
          updatedAt: DateTime.now(),
        );
      }

      _updateStockAlerts();
      _showSuccessSnackbar('Minimum stock level updated');
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to update minimum stock level: ${e.toString()}');
      return false;
    }
  }

  // Log stock changes
  Future<void> _logStockChange({
    required String productId,
    required String productName,
    required String action,
    required int quantityChanged,
    required int previousStock,
    required int newStock,
    String? orderId,
    String? reason,
  }) async {
    try {
      final logId = _firestore.collection('inventory_logs').doc().id;
      final user = _auth.currentUser;

      final stockLog = StockLogModel(
        id: logId,
        productId: productId,
        productName: productName,
        action: action,
        quantityChanged: quantityChanged,
        previousStock: previousStock,
        newStock: newStock,
        orderId: orderId,
        adminId: user?.uid,
        reason: reason,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('inventory_logs').doc(logId).set(stockLog.toMap());

      // Add to local logs
      stockLogs.insert(0, stockLog);
      if (stockLogs.length > 100) {
        stockLogs.removeLast();
      }
    } catch (e) {
      print('Failed to log stock change: ${e.toString()}');
    }
  }

  // Update stock alerts
  void _updateStockAlerts() {
    lowStockProducts.value = products.where((product) => product.isLowStock && !product.isOutOfStock).toList();
    outOfStockProducts.value = products.where((product) => product.isOutOfStock).toList();
  }

  // Get stock status color
  Color getStockStatusColor(ProductModel product) {
    if (product.isOutOfStock) {
      return const Color(0xFFF44336); // Red
    } else if (product.isLowStock) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFF4CAF50); // Green
    }
  }

  // Get stock status text
  String getStockStatusText(ProductModel product) {
    if (product.isOutOfStock) {
      return 'Out of Stock';
    } else if (product.isLowStock) {
      return 'Low Stock';
    } else {
      return 'In Stock';
    }
  }

  // Get products by stock status
  List<ProductModel> getProductsByStockStatus(String status) {
    switch (status.toLowerCase()) {
      case 'low':
        return lowStockProducts;
      case 'out':
        return outOfStockProducts;
      case 'in_stock':
        return products.where((p) => !p.isLowStock && !p.isOutOfStock).toList();
      default:
        return products;
    }
  }

  // Check if product has sufficient stock for order
  bool hasEnoughStock(String productId, int requiredQuantity) {
    final product = products.firstWhereOrNull((p) => p.id == productId);
    return product != null && product.stock >= requiredQuantity;
  }

  // Get low stock count
  int get lowStockCount => lowStockProducts.length;

  // Get out of stock count
  int get outOfStockCount => outOfStockProducts.length;

  // Get total products count
  int get totalProductsCount => products.length;

  // Get total stock value
  double get totalStockValue {
    return products.fold(0.0, (sum, product) => sum + (product.price * product.stock));
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
