import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../repository/user_service.dart';
import 'cart_item_model.dart';

class CartViewModel extends GetxController {
  var cartItems = <CartItemModel>[].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = Get.find<UserService>();
  Timer? _expiryTimer;
  StreamSubscription? _cartSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeCart();
    _startExpiryTimer();
  }

  @override
  void onClose() {
    _expiryTimer?.cancel();
    _cartSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initializeCart() async {
    // Clear local cart on app restart as requested
    cartItems.clear();

    final userId = await _userService.ensureUserAuthenticated();
    if (userId.isNotEmpty) {
      _listenToCartChanges(userId);
    }
  }

  void _listenToCartChanges(String userId) {
    _cartSubscription = _firestore
        .collection('user_carts')
        .doc(userId)
        .collection('items')
        .snapshots()
        .listen((snapshot) {
      final items = <CartItemModel>[];

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();

          // Check if productId exists, if not skip this item (old format)
          if (data['productId'] == null ||
              data['productId'].toString().isEmpty) {
            // Remove old format items
            doc.reference.delete();
            continue;
          }

          final item = CartItemModel.fromMap(data);
          if (!item.isExpired) {
            items.add(item);
          }
        } catch (e) {
          // If there's an error parsing the item, remove it
          doc.reference.delete();
        }
      }

      cartItems.assignAll(items);
      _removeExpiredItems(userId);
    });
  }

  void _startExpiryTimer() {
    _expiryTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndRemoveExpiredItems();
    });
  }

  Future<void> _checkAndRemoveExpiredItems() async {
    final userId = _userService.currentUserId;
    if (userId == null) return;

    final expiredItems = cartItems.where((item) => item.isExpired).toList();

    for (final item in expiredItems) {
      await _removeItemFromFirestore(userId, item.id);
      cartItems.remove(item);

      Get.snackbar(
        'Item Expired',
        '${item.name} was removed from cart (30 min timeout)',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _removeExpiredItems(String userId) async {
    final batch = _firestore.batch();
    final expiredDocs = await _firestore
        .collection('user_carts')
        .doc(userId)
        .collection('items')
        .get();

    for (final doc in expiredDocs.docs) {
      final item = CartItemModel.fromMap(doc.data());
      if (item.isExpired) {
        batch.delete(doc.reference);
      }
    }

    await batch.commit();
  }

  double get subtotal => cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get tax => 150; // 10% tax
  double get total => subtotal + tax;

  Future<void> addToCart(String productId, String name, String image,
      String quantityLabel, double price, int quantity) async {
    print('=== ADD TO CART DEBUG ===');
    print('ProductID: "$productId"');
    print('Name: "$name"');
    print('ProductID isEmpty: ${productId.isEmpty}');
    print('ProductID trimmed isEmpty: ${productId.trim().isEmpty}');

    final userId = await _userService.ensureUserAuthenticated();
    if (userId.isEmpty) return;

    // Validate productId
    if (productId.isEmpty || productId.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Invalid product. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Check if item already exists in cart
    final existingIndex = cartItems.indexWhere((item) =>
        item.productId == productId && item.quantityLabel == quantityLabel);

    if (existingIndex != -1) {
      // Update existing item quantity
      final existingItem = cartItems[existingIndex];
      existingItem.quantity += quantity;

      await _updateItemInFirestore(userId, existingItem);

      Get.snackbar(
        'Updated Cart',
        'Increased quantity of $name',
        backgroundColor: const Color(0xFF199A8E),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      // Add new item to cart
      final newItem = CartItemModel(
        productId: productId.trim(),
        // Ensure it's trimmed
        name: name,
        image: image,
        quantityLabel: quantityLabel,
        price: price,
        quantity: quantity,
        userId: userId,
      );

      print('Creating new cart item with ProductID: "${newItem.productId}"');

      await _addItemToFirestore(userId, newItem);

      Get.snackbar(
        'Added to Cart',
        '$name has been added to your cart',
        backgroundColor: const Color(0xFF199A8E),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _addItemToFirestore(String userId, CartItemModel item) async {
    await _firestore
        .collection('user_carts')
        .doc(userId)
        .collection('items')
        .doc(item.id)
        .set(item.toMap());
  }

  Future<void> _updateItemInFirestore(String userId, CartItemModel item) async {
    await _firestore
        .collection('user_carts')
        .doc(userId)
        .collection('items')
        .doc(item.id)
        .update(item.toMap());
  }

  Future<void> _removeItemFromFirestore(String userId, String itemId) async {
    await _firestore
        .collection('user_carts')
        .doc(userId)
        .collection('items')
        .doc(itemId)
        .delete();
  }

  Future<void> increaseQuantity(int index) async {
    if (index < cartItems.length) {
      final userId = _userService.currentUserId;
      if (userId == null) return;

      cartItems[index].quantity++;
      await _updateItemInFirestore(userId, cartItems[index]);
    }
  }

  Future<void> decreaseQuantity(int index) async {
    if (index < cartItems.length && cartItems[index].quantity > 1) {
      final userId = _userService.currentUserId;
      if (userId == null) return;

      cartItems[index].quantity--;
      await _updateItemInFirestore(userId, cartItems[index]);
    }
  }

  Future<void> removeItem(int index) async {
    if (index < cartItems.length) {
      final userId = _userService.currentUserId;
      if (userId == null) return;

      final item = cartItems[index];
      await _removeItemFromFirestore(userId, item.id);

      Get.snackbar(
        'Removed from Cart',
        '${item.name} has been removed from your cart',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> clearCart() async {
    final userId = _userService.currentUserId;
    if (userId == null) return;

    // Clear all items from Firestore
    final batch = _firestore.batch();
    final cartDocs = await _firestore
        .collection('user_carts')
        .doc(userId)
        .collection('items')
        .get();

    for (final doc in cartDocs.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    Get.snackbar(
      'Cart Cleared',
      'All items have been removed from your cart',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> clearCartSilently() async {
    final userId = _userService.currentUserId;
    if (userId == null) return;

    // Clear all items from Firestore without showing snackbar
    final batch = _firestore.batch();
    final cartDocs = await _firestore
        .collection('user_carts')
        .doc(userId)
        .collection('items')
        .get();

    for (final doc in cartDocs.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
}
