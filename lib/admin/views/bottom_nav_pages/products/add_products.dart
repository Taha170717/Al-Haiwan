import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/add_product_controller.dart';

class AddProducts extends StatelessWidget {
  AddProducts({super.key, required String productId, required Map<String, dynamic> existingData});

  final AddProductController controller = Get.put(AddProductController());
  static const Color primary = Color(0xFF199A8E);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontal = width * 0.05;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
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
              _sectionCard(
                title: "Basic Information",
                child: Column(
                  children: [
                    _buildTextField(
                      controller.nameController,
                      "Product Name",
                      prefixIcon: Icons.inventory_2_outlined,
                    ),
                    _buildDropdown(),
                    _buildTextField(
                      controller.brandController,
                      "Brand",
                      prefixIcon: Icons.branding_watermark_outlined,
                    ),
                    _buildTextField(
                      controller.descriptionController,
                      "Description",
                      maxLines: 3,
                      prefixIcon: Icons.description_outlined,
                    ),
                    _buildTextField(
                      controller.ingredientsController,
                      "Ingredients",
                      maxLines: 2,
                      prefixIcon: Icons.science_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: "Pricing & Inventory",
                child: Column(
                  children: [
                    _buildTextField(
                      controller.priceController,
                      "Price",
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.attach_money,
                    ),
                    _buildTextField(
                      controller.stockController,
                      "Stock Quantity",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.inventory_outlined,
                    ),
                    _buildTextField(
                      controller.weightController,
                      "Weight/Size",
                      prefixIcon: Icons.scale_outlined,
                    ),
                    _buildTextField(
                      controller.animalTypeController,
                      "Target Animal Type",
                      prefixIcon: Icons.pets_outlined,
                    ),
                    _buildDatePickerField(
                      context: context,
                      textController: controller.expiryDateController,
                      label: "Expiry Date",
                      prefixIcon: Icons.event_outlined,
                    ),
                    _buildTextField(
                      controller.skuController,
                      "SKU / Product Code",
                      prefixIcon: Icons.qr_code_2_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: "Product Images",
                trailing: Obx(() => Text(
                  controller.selectedImages.isEmpty
                      ? "No images selected"
                      : "${controller.selectedImages.length} selected",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                          () => Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ...List.generate(
                            controller.selectedImages.length,
                                (index) {
                              final img = controller.selectedImages[index];
                              // On web, using Image.network works well for blob URLs.
                              if (kIsWeb) {
                                return _imageTile(
                                  child: Image.network(
                                    img.path,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 90,
                                        height: 90,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Image load error: $error');
                                      return Container(
                                        width: 90,
                                        height: 90,
                                        color: Colors.grey[300],
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 24,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Failed',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  onRemove: () => controller.selectedImages
                                      .removeAt(index),
                                );
                              } else {
                                // On mobile, safely read bytes to avoid direct dart:io import
                                return FutureBuilder<Uint8List>(
                                  future: img.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting ||
                                        !snapshot.hasData) {
                                      return _imageTile(
                                        child: Container(
                                          width: 90,
                                          height: 90,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onRemove: null,
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return _imageTile(
                                        child: Container(
                                          width: 90,
                                          height: 90,
                                          color: Colors.grey[300],
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                                size: 24,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Error',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        onRemove: () => controller.selectedImages
                                            .removeAt(index),
                                      );
                                    }

                                    return _imageTile(
                                      child: Image.memory(
                                        snapshot.data!,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 90,
                                            height: 90,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                              size: 32,
                                            ),
                                          );
                                        },
                                      ),
                                      onRemove: () => controller.selectedImages
                                          .removeAt(index),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                          _addImageTile(onTap: controller.pickImages),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                    () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                    controller.isLoading.value ? null : controller.addProduct,
                    icon: controller.isLoading.value
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.check_circle_outline,
                        color: Colors.white),
                    label: Text(
                      controller.isLoading.value ? "Adding..." : "Add Product",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      disabledBackgroundColor: primary.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
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

  // ---------- Helpers ----------

  static Widget _sectionCard({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        IconData? prefixIcon,
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
          prefixIcon: prefixIcon == null
              ? null
              : Icon(prefixIcon, color: primary, size: 20),
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
    );
  }

  // Calendar date picker field (read-only)
  Widget _buildDatePickerField({
    required BuildContext context,
    required TextEditingController textController,
    required String label,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: textController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: primary),
          prefixIcon: prefixIcon == null
              ? null
              : Icon(prefixIcon, color: primary, size: 20),
          suffixIcon:
          const Icon(Icons.calendar_today_outlined, color: primary, size: 20),
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
        onTap: () => _pickDate(context, textController),
      ),
    );
  }

  Future<void> _pickDate(
      BuildContext context, TextEditingController textController) async {
    final now = DateTime.now();
    final initial = _tryParseDate(textController.text) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      textController.text = _formatDate(picked);
    }
  }

  DateTime? _tryParseDate(String value) {
    if (value.trim().isEmpty) return null;
    try {
      // expecting yyyy-MM-dd
      final parts = value.split('-');
      if (parts.length == 3) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (y != null && m != null && d != null) {
          return DateTime(y, m, d);
        }
      }
    } catch (_) {}
    return null;
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
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
              .map(
                (category) => DropdownMenuItem(
              value: category,
              child: Text(category),
            ),
          )
              .toList(),
          icon: const Icon(Icons.arrow_drop_down, color: primary),
          decoration: InputDecoration(
            labelText: "Select Category",
            labelStyle: const TextStyle(color: primary),
            prefixIcon:
            const Icon(Icons.category_outlined, color: primary, size: 20),
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

  Widget _imageTile({required Widget child, VoidCallback? onRemove}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 90,
            height: 90,
            color: Colors.grey[200],
            child: child,
          ),
        ),
        if (onRemove != null)
          Positioned(
            right: 2,
            top: 2,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  // Add image tile
  Widget _addImageTile({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container
        (
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withOpacity(0.6), width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_a_photo_outlined, color: primary, size: 24),
            SizedBox(height: 6),
            Text(
              "Add",
              style: TextStyle(
                color: primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
