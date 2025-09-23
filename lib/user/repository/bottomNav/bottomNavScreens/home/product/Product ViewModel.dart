// viewmodels/product_list_viewmodel.dart
import 'package:al_haiwan/user/repository/bottomNav/bottomNavScreens/home/product/product%20Modal.dart';
import 'package:get/get.dart';

class ProductListViewModel extends GetxController {
  var products = <Product>[
    Product(
      name: "Vitamin C",
      price: "₨ 350",
      imagePath: "assets/images/med1.png",
      description: "Boosts immunity and skin health.",
    ),
    Product(
      name: "Pain Relief Gel",
      price: "₨ 250",
      imagePath: "assets/images/panadol.png",
      description: "Relieves muscular pain instantly.",
    ),
    Product(
      name: "Bandage Pack",
      price: "₨ 150",
      imagePath: "assets/images/obh.png",
      description: "Essential first-aid kit item.",
    ),
    Product(
      name: "Face Mask",
      price: "₨ 200",
      imagePath: "assets/images/med1.png",
      description: "Helps reduce airborne infections.",
    ),
  ].obs;
}
