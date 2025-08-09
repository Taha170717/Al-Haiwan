import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_product_controller.dart';

class AddProducts extends StatelessWidget {
  AddProducts({super.key});

  final AddProductController controller = Get.put(AddProductController());
  static const Color primary = Color(0xFF199A8E);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontal = width * 0.05;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Add Products",
          style: TextStyle(
            color: primary,
            fontFamily: "bolditalic",
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(controller.nameController, "Product Name"),
              _buildDropdown(),
              _buildTextField(controller.brandController, "Brand"),
              _buildTextField(
                controller.descriptionController,
                "Description",
                maxLines: 3,
              ),
              _buildTextField(controller.ingredientsController, "Ingredients"),
              _buildTextField(
                controller.priceController,
                "Price",
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              _buildTextField(
                controller.stockController,
                "Stock Quantity",
                keyboardType: TextInputType.number,
              ),
              _buildTextField(controller.weightController, "Weight/Size"),
              _buildTextField(
                controller.animalTypeController,
                "Target Animal Type",
              ),
              _buildTextField(controller.expiryDateController, "Expiry Date"),
              _buildTextField(controller.skuController, "SKU / Product Code"),

              const SizedBox(height: 18),
              const Text(
                "Product Images",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
              const SizedBox(height: 10),


            Obx(() => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...controller.selectedImages.map((img) {
            if (kIsWeb) {
              // On web, img.path is already a blob URL
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(img.path, width: 80, height: 80, fit: BoxFit.cover),
              );
            } else {
              // On mobile, we can read bytes or use Image.file
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(File(img.path), width: 80, height: 80, fit: BoxFit.cover),
              );
            }
          }),
          GestureDetector(
            onTap: controller.pickImages,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0XFF199A8E), width: 1),
              ),
              child: const Icon(Icons.add_a_photo, color: Color(0XFF199A8E)),
            ),
          ),
        ],
      )),



    const SizedBox(height: 26),
              Obx(
                    () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                    controller.isLoading.value ? null : controller.addProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      disabledBackgroundColor: primary.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                      CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text(
                      "Add Product",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: primary),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Obx(
            () => DropdownButtonFormField<String>(
          value: controller.selectedCategory.value.isEmpty
              ? null
              : controller.selectedCategory.value,
          onChanged: (value) => controller.selectedCategory.value = value ?? '',
          items: controller.categories
              .map((category) => DropdownMenuItem(
            value: category,
            child: Text(category),
          ))
              .toList(),
          decoration: InputDecoration(
            labelText: "Select Category",
            labelStyle: const TextStyle(color: primary),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: primary, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}