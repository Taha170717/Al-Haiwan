class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  final int soldCount;
  final int minStockLevel;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    this.soldCount = 0,
    this.minStockLevel = 5,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    try {
      // Safe DateTime parsing
      DateTime createdAt;
      try {
        final createdAtRaw = map['createdAt'];
        if (createdAtRaw is String && createdAtRaw.isNotEmpty) {
          createdAt = DateTime.parse(createdAtRaw);
        } else {
          createdAt = DateTime.now();
        }
      } catch (e) {
        print('Error parsing createdAt for product: $e');
        createdAt = DateTime.now();
      }

      DateTime? updatedAt;
      try {
        final updatedAtRaw = map['updatedAt'];
        if (updatedAtRaw is String && updatedAtRaw.isNotEmpty) {
          updatedAt = DateTime.parse(updatedAtRaw);
        }
      } catch (e) {
        print('Error parsing updatedAt for product: $e');
        updatedAt = null;
      }

      return ProductModel(
        id: (map['id'] ?? '').toString(),
        name: (map['name'] ?? '').toString(),
        description: (map['description'] ?? '').toString(),
        price: (map['price'] ?? 0).toDouble(),
        imageUrl: (map['imageUrl'] ?? '').toString(),
        category: (map['category'] ?? '').toString(),
        stock: map.containsKey('stockQuantity')
            ? (map['stockQuantity'] ?? 0).toInt()
            : map.containsKey('stock')
                ? (map['stock'] ?? 0).toInt()
                : 0,
        soldCount: (map['soldCount'] ?? 0).toInt(),
        minStockLevel: (map['minStockLevel'] ?? 5).toInt(),
        isActive: map['isActive'] ?? true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      print('Error in ProductModel.fromMap(): $e');
      print('Map data: $map');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'stockQuantity': stock,
      'soldCount': soldCount,
      'minStockLevel': minStockLevel,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    int? stock,
    int? soldCount,
    int? minStockLevel,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      soldCount: soldCount ?? this.soldCount,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLowStock => stock <= minStockLevel;
  bool get isOutOfStock => stock <= 0;
}

class StockLogModel {
  final String id;
  final String productId;
  final String productName;
  final String action; // 'order_placed', 'order_cancelled', 'manual_adjustment', 'restock'
  final int quantityChanged;
  final int previousStock;
  final int newStock;
  final String? orderId;
  final String? adminId;
  final String? reason;
  final DateTime createdAt;

  StockLogModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.action,
    required this.quantityChanged,
    required this.previousStock,
    required this.newStock,
    this.orderId,
    this.adminId,
    this.reason,
    required this.createdAt,
  });

  factory StockLogModel.fromMap(Map<String, dynamic> map) {
    return StockLogModel(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      action: map['action'] ?? '',
      quantityChanged: map['quantityChanged'] ?? 0,
      previousStock: map['previousStock'] ?? 0,
      newStock: map['newStock'] ?? 0,
      orderId: map['orderId'],
      adminId: map['adminId'],
      reason: map['reason'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'action': action,
      'quantityChanged': quantityChanged,
      'previousStock': previousStock,
      'newStock': newStock,
      'orderId': orderId,
      'adminId': adminId,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
