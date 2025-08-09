import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' if (dart.library.html) 'dart:io'; // Only imports dart:io on mobile
import 'package:al_haiwan/admin/views/bottom_nav_pages/products/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddProductController extends GetxController {
  var isLoading = false.obs;
  var selectedImages = <XFile>[].obs; // Changed from File to XFile

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
    List<String> downloadUrls = [];

    for (var image in selectedImages) {
      String fileName = "${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg";
      var ref = FirebaseStorage.instance.ref().child("products").child(fileName);

      if (kIsWeb) {
        // Web: Upload as bytes
        final bytes = await image.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        // Mobile: Upload as file
        await ref.putFile(File(image.path));
      }

      String url = await ref.getDownloadURL();
      downloadUrls.add(url);
    }

    return downloadUrls;
  }

  Future<void> addProduct() async {
    if (nameController.text.isEmpty ||
        selectedCategory.value.isEmpty ||
        priceController.text.isEmpty) {
      Get.snackbar("Error", "Please fill required fields",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      String productId = Uuid().v4();

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

      Get.snackbar("Success", "Product added successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
      clearFields();
      Get.back();
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
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
    selectedCategory.value = '';
  }
}
