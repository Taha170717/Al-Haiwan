class ProductModel {
  String id;
  String name;
  String category;
  String brand;
  String description;
  String ingredients;
  double price;
  int stockQuantity;
  List<String> imageUrls;
  String weight;
  String animalType;
  String expiryDate;
  String sku;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.description,
    required this.ingredients,
    required this.price,
    required this.stockQuantity,
    required this.imageUrls,
    required this.weight,
    required this.animalType,
    required this.expiryDate,
    required this.sku,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'brand': brand,
      'description': description,
      'ingredients': ingredients,
      'price': price,
      'stockQuantity': stockQuantity,
      'imageUrls': imageUrls,
      'weight': weight,
      'animalType': animalType,
      'expiryDate': expiryDate,
      'sku': sku,
    };
  }

  // Create from Map (Firestore snapshot)
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      brand: map['brand'] ?? '',
      description: map['description'] ?? '',
      ingredients: map['ingredients'] ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0.0),
      stockQuantity: map['stockQuantity'] ?? 0,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      weight: map['weight'] ?? '',
      animalType: map['animalType'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      sku: map['sku'] ?? '',
    );
  }
}
