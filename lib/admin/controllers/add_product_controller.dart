import 'package:al_haiwan/admin/views/bottom_nav_pages/products/products_page.dart';
import 'package:al_haiwan/admin/controllers/admin_bottom_nav_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' if (dart.library.html) 'dart:io';
import 'package:al_haiwan/admin/views/bottom_nav_pages/products/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Remove Firebase Storage import
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

// Add ImageKit service import
import '../../utils/services/imagekit_service.dart';
import '../views/adminside.dart'; // Import AdminScreen

class AddProductController extends GetxController {
  var isLoading = false.obs;
  var selectedImages = <XFile>[].obs;
  var existingImageUrls = <String>[].obs;

  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final descriptionController = TextEditingController();
  final ingredientsController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final weightController = TextEditingController();
  final animalTypeController = TextEditingController();
  final expiryDateController = TextEditingController();
  final skuController = TextEditingController();

  var selectedCategory = ''.obs;

  final List<String> categories = [
    "Deworming",
    "Vaccines",
    "Pain Relief",
    "Skin & Coat",
    "Eye/Ear Drops",
    "Supplements",
    "Pet Food",
    "Grooming",
    "Toys",
    "Cleaning",
  ];

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 70);
    if (pickedFiles.isNotEmpty) {
      selectedImages.addAll(pickedFiles);
    }
  }

  Future<List<String>> uploadImagesToStorage(String productId) async {
    try {
      // Use ImageKit service to upload all images to product_images folder
      List<String> downloadUrls = await ImageKitService.uploadProductImages(
        selectedImages,
        productId,
      );
      return downloadUrls;
    } catch (e) {
      print("Error uploading images to ImageKit: $e");
      throw Exception("Failed to upload images: $e");
    }
  }

  Future<void> addProduct() async {
    if (nameController.text.isEmpty ||
        selectedCategory.value.isEmpty ||
        priceController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill required fields",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      String productId = const Uuid().v4();

      List<String> imageUrls = await uploadImagesToStorage(productId);

      ProductModel product = ProductModel(
        id: productId,
        name: nameController.text,
        category: selectedCategory.value,
        brand: brandController.text,
        description: descriptionController.text,
        ingredients: ingredientsController.text,
        price: double.parse(priceController.text),
        stockQuantity: int.tryParse(stockController.text) ?? 0,
        imageUrls: imageUrls,
        weight: weightController.text,
        animalType: animalTypeController.text,
        expiryDate: expiryDateController.text,
        sku: skuController.text,
      );

      await FirebaseFirestore.instance
          .collection("products")
          .doc(productId)
          .set(product.toMap());

      clearFields();
      _showSuccessThenRedirect();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(String productId) async {
    if (nameController.text.isEmpty ||
        selectedCategory.value.isEmpty ||
        priceController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill required fields",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      List<String> newImageUrls = [];
      if (selectedImages.isNotEmpty) {
        newImageUrls = await uploadImagesToStorage(productId);
      }

      List<String> finalImageUrls = [
        ...existingImageUrls,
        ...newImageUrls,
      ];

      ProductModel updatedProduct = ProductModel(
        id: productId,
        name: nameController.text,
        category: selectedCategory.value,
        brand: brandController.text,
        description: descriptionController.text,
        ingredients: ingredientsController.text,
        price: double.parse(priceController.text),
        stockQuantity: int.tryParse(stockController.text) ?? 0,
        imageUrls: finalImageUrls,
        weight: weightController.text,
        animalType: animalTypeController.text,
        expiryDate: expiryDateController.text,
        sku: skuController.text,
      );

      await FirebaseFirestore.instance
          .collection("products")
          .doc(productId)
          .update(updatedProduct.toMap());

      clearFields();
      _showSuccessThenRedirect(message: "Product updated successfully");
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccessThenRedirect({
    String message = "Your product has been published successfully.",
  }) {
    final snackDuration = const Duration(seconds: 2);

    Get.snackbar(
      "Success",
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      borderRadius: 14,
      margin: const EdgeInsets.all(16),
      duration: snackDuration,
      isDismissible: true,
      snackStyle: SnackStyle.FLOATING,
      barBlur: 8,
      forwardAnimationCurve: Curves.fastOutSlowIn,
      reverseAnimationCurve: Curves.easeInBack,
    );

    Future.delayed(snackDuration + const Duration(milliseconds: 150), () {
      try {
        Get.until((route) => route.settings.name == '/AdminScreen' || route.isFirst);

        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            final adminController = Get.find<AdminBottomNavController>();
            adminController.changeIndex(2);
          } catch (e) {
            print('Error finding AdminBottomNavController: $e');
            Get.offAll(() =>  AdminScreen());
            Future.delayed(const Duration(milliseconds: 200), () {
              try {
                Get.find<AdminBottomNavController>().changeIndex(2);
              } catch (e) {
                print('Still unable to find controller: $e');
              }
            });
          }
        });
      } catch (e) {
        print('Navigation error: $e');
        Get.offAll(() => const AdminScreen());
      }
    });
  }

  void clearFields() {
    nameController.clear();
    brandController.clear();
    descriptionController.clear();
    ingredientsController.clear();
    priceController.clear();
    stockController.clear();
    weightController.clear();
    animalTypeController.clear();
    expiryDateController.clear();
    skuController.clear();
    selectedImages.clear();
    existingImageUrls.clear();
    selectedCategory.value = '';
  }

  void loadProductData(ProductModel product) {
    nameController.text = product.name;
    brandController.text = product.brand;
    descriptionController.text = product.description;
    ingredientsController.text = product.ingredients;
    priceController.text = product.price.toString();
    stockController.text = product.stockQuantity.toString();
    weightController.text = product.weight;
    animalTypeController.text = product.animalType;
    expiryDateController.text = product.expiryDate;
    skuController.text = product.sku;
    selectedCategory.value = product.category;
    existingImageUrls.assignAll(product.imageUrls);
  }
}
