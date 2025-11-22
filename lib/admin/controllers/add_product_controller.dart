
import 'package:al_haiwan/admin/views/bottom_nav_pages/products/products_page.dart';
import 'package:al_haiwan/admin/controllers/admin_bottom_nav_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' if (dart.library.html) 'dart:io';
import 'package:al_haiwan/admin/views/bottom_nav_pages/products/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../utils/services/imagekit_service.dart';
import '../views/adminside.dart';

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
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(imageQuality: 70);
      if (pickedFiles.isNotEmpty) {
        selectedImages.addAll(pickedFiles);
        _showSuccessSnackbar(
          'Images Selected',
          '${pickedFiles.length} image(s) selected successfully',
        );
      }
    } catch (e) {
      _showErrorSnackbar(
        'Image Selection Failed',
        'Unable to select images. Please try again.',
      );
    }
  }

  Future<List<String>> uploadImagesToStorage(String productId) async {
    try {
      List<String> downloadUrls = await ImageKitService.uploadProductImages(
        selectedImages,
        productId,
      );
      return downloadUrls;
    } catch (e) {
      throw Exception("Failed to upload images: ${e.toString()}");
    }
  }

  Future<void> addProduct() async {
    print('🔍 AddProduct called'); // Debug

    // Validate required fields
    if (nameController.text.trim().isEmpty) {
      print('❌ Name is empty'); // Debug
      _showErrorSnackbar('Missing Field', 'Product name is required');
      return;
    }

    if (selectedCategory.value.isEmpty) {
      print('❌ Category is empty'); // Debug
      _showErrorSnackbar('Missing Field', 'Please select a category');
      return;
    }

    if (priceController.text.trim().isEmpty) {
      print('❌ Price is empty'); // Debug
      _showErrorSnackbar('Missing Field', 'Price is required');
      return;
    }

    // Validate price format
    try {
      double.parse(priceController.text);
    } catch (e) {
      print('❌ Invalid price format'); // Debug
      _showErrorSnackbar('Invalid Price', 'Please enter a valid price');
      return;
    }

    // Validate at least one image
    if (selectedImages.isEmpty) {
      print('❌ No images selected'); // Debug
      _showErrorSnackbar('Missing Images', 'Please select at least one product image');
      return;
    }

    try {
      print('✅ All validations passed, starting upload...'); // Debug
      isLoading.value = true;
      String productId = const Uuid().v4();

      // Upload images
      List<String> imageUrls = await uploadImagesToStorage(productId);
      print('✅ Images uploaded successfully'); // Debug

      ProductModel product = ProductModel(
        id: productId,
        name: nameController.text.trim(),
        category: selectedCategory.value,
        brand: brandController.text.trim(),
        description: descriptionController.text.trim(),
        ingredients: ingredientsController.text.trim(),
        price: double.parse(priceController.text),
        stockQuantity: int.tryParse(stockController.text) ?? 0,
        imageUrls: imageUrls,
        weight: weightController.text.trim(),
        animalType: animalTypeController.text.trim(),
        expiryDate: expiryDateController.text.trim(),
        sku: skuController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection("products")
          .doc(productId)
          .set(product.toMap());

      print('✅ Product saved to Firestore'); // Debug
      clearFields();
      _showSuccessThenRedirect(
        title: 'Product Added!',
        message: '${product.name} has been published successfully',
      );
    } catch (e) {
      print('❌ Error: $e'); // Debug
      String errorMessage = 'Failed to add product';
      if (e.toString().contains('upload')) {
        errorMessage = 'Failed to upload images. Please check your internet connection';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please check your Firebase settings';
      }

      _showErrorSnackbar('Upload Failed', errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(String productId) async {
    // Validate required fields
    if (nameController.text.trim().isEmpty) {
      _showErrorSnackbar('Missing Field', 'Product name is required');
      return;
    }

    if (selectedCategory.value.isEmpty) {
      _showErrorSnackbar('Missing Field', 'Please select a category');
      return;
    }

    if (priceController.text.trim().isEmpty) {
      _showErrorSnackbar('Missing Field', 'Price is required');
      return;
    }

    // Validate price format
    try {
      double.parse(priceController.text);
    } catch (e) {
      _showErrorSnackbar('Invalid Price', 'Please enter a valid price');
      return;
    }

    // Validate at least one image
    if (existingImageUrls.isEmpty && selectedImages.isEmpty) {
      _showErrorSnackbar('Missing Images', 'Please select at least one product image');
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
        name: nameController.text.trim(),
        category: selectedCategory.value,
        brand: brandController.text.trim(),
        description: descriptionController.text.trim(),
        ingredients: ingredientsController.text.trim(),
        price: double.parse(priceController.text),
        stockQuantity: int.tryParse(stockController.text) ?? 0,
        imageUrls: finalImageUrls,
        weight: weightController.text.trim(),
        animalType: animalTypeController.text.trim(),
        expiryDate: expiryDateController.text.trim(),
        sku: skuController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection("products")
          .doc(productId)
          .update(updatedProduct.toMap());

      clearFields();
      _showSuccessThenRedirect(
        title: 'Product Updated!',
        message: '${updatedProduct.name} has been updated successfully',
      );
    } catch (e) {
      String errorMessage = 'Failed to update product';
      if (e.toString().contains('upload')) {
        errorMessage = 'Failed to upload images. Please check your internet connection';
      } else if (e.toString().contains('not-found')) {
        errorMessage = 'Product not found. It may have been deleted';
      }

      _showErrorSnackbar('Update Failed', errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorSnackbar(String title, String message) {
    print('🔴 Showing error snackbar: $title - $message'); // Debug

    // Try GetX snackbar
    try {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white, size: 28),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        isDismissible: true,
        snackStyle: SnackStyle.FLOATING,
        barBlur: 8,
        animationDuration: const Duration(milliseconds: 500),
        overlayBlur: 0.5,
        overlayColor: Colors.black26,
        boxShadows: [
          BoxShadow(
            color: Colors.red.shade900.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      );
    } catch (e) {
      print('❌ GetX snackbar failed: $e');

      // Fallback to ScaffoldMessenger
      try {
        final context = Get.context;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(message),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e2) {
        print('❌ ScaffoldMessenger also failed: $e2');
      }
    }
  }

  void _showSuccessSnackbar(String title, String message) {
    print('🟢 Showing success snackbar: $title - $message'); // Debug

    try {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        isDismissible: true,
        snackStyle: SnackStyle.FLOATING,
        barBlur: 8,
        animationDuration: const Duration(milliseconds: 500),
        overlayBlur: 0.5,
        overlayColor: Colors.black26,
        boxShadows: [
          BoxShadow(
            color: Colors.green.shade900.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      );
    } catch (e) {
      print('❌ GetX snackbar failed: $e');

      // Fallback
      try {
        final context = Get.context;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(message),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF4CAF50),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e2) {
        print('❌ ScaffoldMessenger also failed: $e2');
      }
    }
  }

  void _showSuccessThenRedirect({
    required String title,
    required String message,
  }) {
    print('🎉 Showing success and redirecting: $title'); // Debug
    final snackDuration = const Duration(seconds: 3);

    try {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 32),
        borderRadius: 14,
        margin: const EdgeInsets.all(16),
        duration: snackDuration,
        isDismissible: true,
        snackStyle: SnackStyle.FLOATING,
        barBlur: 8,
        animationDuration: const Duration(milliseconds: 500),
        overlayBlur: 0.5,
        overlayColor: Colors.black26,
        forwardAnimationCurve: Curves.fastOutSlowIn,
        reverseAnimationCurve: Curves.easeInBack,
        boxShadows: [
          BoxShadow(
            color: Colors.green.shade900.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      );
    } catch (e) {
      print('❌ Success snackbar failed: $e');
    }

    Future.delayed(snackDuration + const Duration(milliseconds: 150), () {
      try {
        Get.until((route) => route.settings.name == '/AdminScreen' || route.isFirst);

        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            final adminController = Get.find<AdminBottomNavController>();
            adminController.changeIndex(2);
          } catch (e) {
            Get.offAll(() => AdminScreen());
            Future.delayed(const Duration(milliseconds: 200), () {
              try {
                Get.find<AdminBottomNavController>().changeIndex(2);
              } catch (e) {
                // Handle silently
              }
            });
          }
        });
      } catch (e) {
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