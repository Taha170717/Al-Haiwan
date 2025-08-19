import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../../user_service.dart';
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
      final items = snapshot.docs
          .map((doc) => CartItemModel.fromMap(doc.data()))
          .where((item) => !item.isExpired) // Filter expired items
          .toList();

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
  double get tax => subtotal * 0.1; // 10% tax
  double get total => subtotal + tax;

  Future<void> addToCart(String name, String image, String quantityLabel, double price, int quantity) async {
    final userId = await _userService.ensureUserAuthenticated();
    if (userId.isEmpty) return;

    // Check if item already exists in cart
    final existingIndex = cartItems.indexWhere((item) =>
    item.name == name && item.quantityLabel == quantityLabel);

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
        name: name,
        image: image,
        quantityLabel: quantityLabel,
        price: price,
        quantity: quantity,
        userId: userId,
      );

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

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
}
