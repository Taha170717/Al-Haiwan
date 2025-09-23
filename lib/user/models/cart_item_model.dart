class CartItemModel {
  final String id; // Cart item unique ID for Firestore document
  final String productId; // Original product ID from products collection
  final String name;
  final String image;
  final String quantityLabel;
  final double price;
  int quantity;
  final DateTime addedAt; // Added timestamp for auto-expiry
  final String userId; // Added user ID for user-specific tracking

  CartItemModel({
    String? id,
    required this.productId, // Now required
    required this.name,
    required this.image,
    required this.quantityLabel,
    required this.price,
    this.quantity = 1,
    DateTime? addedAt,
    required this.userId,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'image': image,
      'quantityLabel': quantityLabel,
      'price': price,
      'quantity': quantity,
      'addedAt': addedAt.millisecondsSinceEpoch,
      'userId': userId,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      // Include productId
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      quantityLabel: map['quantityLabel'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt'] ?? 0),
      userId: map['userId'] ?? '',
    );
  }

  bool get isExpired {
    final now = DateTime.now();
    final difference = now.difference(addedAt);
    return difference.inMinutes >= 30;
  }
}
