class CartItemModel {
  final String name;
  final String image;
  final String quantityLabel;
  final double price;
  int quantity;

  CartItemModel({
    required this.name,
    required this.image,
    required this.quantityLabel,
    required this.price,
    this.quantity = 1,
  });
}
