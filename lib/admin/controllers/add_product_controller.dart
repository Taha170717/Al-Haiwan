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
import '../../utils/custom_snackbar.dart';

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
        // Use CustomSnackbar (falls back to Get.context if none provided)
        CustomSnackbar.showSuccess('Images Selected', '${pickedFiles.length} image(s) selected successfully');
      }
    } catch (e) {
      CustomSnackbar.showError('Image Selection Failed', 'Unable to select images. Please try again');
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

  Future<void> addProduct(BuildContext context) async {
    print('\ud83d\udd0d AddProduct called'); // Debug

    // Validate required fields
    if (nameController.text.trim().isEmpty) {
      print('\u274c Name is empty'); // Debug
      _showErrorSnackbar(context, 'Missing Field', 'Product name is required');
      return;
    }

    if (selectedCategory.value.isEmpty) {
      print('\u274c Category is empty'); // Debug
      _showErrorSnackbar(context, 'Missing Field', 'Please select a category');
      return;
    }

    if (priceController.text.trim().isEmpty) {
      print('\u274c Price is empty'); // Debug
      _showErrorSnackbar(context, 'Missing Field', 'Price is required');
      return;
    }

    // Validate price format
    try {
      double.parse(priceController.text);
    } catch (e) {
      print('\u274c Invalid price format'); // Debug
      _showErrorSnackbar(context, 'Invalid Price', 'Please enter a valid price');
      return;
    }

    // Validate at least one image
    if (selectedImages.isEmpty) {
      print('\u274c No images selected'); // Debug
      _showErrorSnackbar(context, 'Missing Images', 'Please select at least one product image');
      return;
    }

    try {
      print('\u2705 All validations passed, starting upload...'); // Debug
      isLoading.value = true;
      String productId = const Uuid().v4();

      // Upload images
      List<String> imageUrls = await uploadImagesToStorage(productId);
      print('\u2705 Images uploaded successfully'); // Debug

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

      print('\u2705 Product saved to Firestore'); // Debug
      clearFields();
      _showSuccessThenRedirect(context,
        title: 'Product Added!',
        message: '${product.name} has been published successfully',
      );
    } catch (e) {
      print('\u274c Error: $e'); // Debug
      String errorMessage = 'Failed to add product';
      if (e.toString().contains('upload')) {
        errorMessage = 'Failed to upload images. Please check your internet connection';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please check your Firebase settings';
      }

      _showErrorSnackbar(context, 'Upload Failed', errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(String productId, BuildContext context) async {
    // Validate required fields
    if (nameController.text.trim().isEmpty) {
      _showErrorSnackbar(context, 'Missing Field', 'Product name is required');
      return;
    }

    if (selectedCategory.value.isEmpty) {
      _showErrorSnackbar(context, 'Missing Field', 'Please select a category');
      return;
    }

    if (priceController.text.trim().isEmpty) {
      _showErrorSnackbar(context, 'Missing Field', 'Price is required');
      return;
    }

    // Validate price format
    try {
      double.parse(priceController.text);
    } catch (e) {
      _showErrorSnackbar(context, 'Invalid Price', 'Please enter a valid price');
      return;
    }

    // Validate at least one image
    if (existingImageUrls.isEmpty && selectedImages.isEmpty) {
      _showErrorSnackbar(context, 'Missing Images', 'Please select at least one product image');
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
      _showSuccessThenRedirect(context,
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

      _showErrorSnackbar(context, 'Update Failed', errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorSnackbar(BuildContext? ctx, String title, String message) {
    // Delegate to CustomSnackbar which handles overlays and fallbacks
    CustomSnackbar.showError(title, message, context: ctx);
  }

  void _showSuccessSnackbar(BuildContext? ctx, String title, String message) {
    CustomSnackbar.showSuccess(title, message, context: ctx);
  }

  void _showSuccessThenRedirect(BuildContext? ctx, {
    required String title,
    required String message,
  }) {
    final snackDuration = const Duration(seconds: 3);

    // Show success message using CustomSnackbar
    CustomSnackbar.showSuccess(title, message, context: ctx, duration: snackDuration);

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

