import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/cart/cart_item_model.dart';
import 'package:get/get.dart';

class CartViewModel extends GetxController {
  var cartItems = <CartItemModel>[
    CartItemModel(name: "OBH Combi", image: "assets/images/obh.png", quantityLabel: "75ml", price: 9.99),
    CartItemModel(name: "Panadol", image: "assets/images/panadol.png", quantityLabel: "20pcs", price: 15.99, quantity: 2),
    CartItemModel(name: "OBH Combi", image: "assets/images/obh.png", quantityLabel: "75ml", price: 9.99),
    CartItemModel(name: "Panadol", image: "assets/images/panadol.png", quantityLabel: "20pcs", price: 15.99, quantity: 2),
    CartItemModel(name: "OBH Combi", image: "assets/images/obh.png", quantityLabel: "75ml", price: 9.99),



  ].obs;

  double get subtotal => cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get tax => 1.0;
  double get total => subtotal + tax;

  void increaseQuantity(int index) {
    cartItems[index].quantity++;
    cartItems.refresh();
  }

  void decreaseQuantity(int index) {
    if (cartItems[index].quantity > 1) {
      cartItems[index].quantity--;
      cartItems.refresh();
    }
  }

  void removeItem(int index) {
    cartItems.removeAt(index);
  }
}
