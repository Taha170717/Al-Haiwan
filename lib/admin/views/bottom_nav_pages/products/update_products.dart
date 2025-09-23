import 'dart:typed_data';
import 'dart:io' if (dart.library.html) 'dart:io';
import 'package:al_haiwan/admin/controllers/add_product_controller.dart';
import 'package:al_haiwan/admin/views/bottom_nav_pages/products/product_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateProducts extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> existingData;

  const UpdateProducts({
    super.key,
    required this.productId,
    required this.existingData,
  });

  static const Color primary = Color(0xFF199A8E);

  @override
  State<UpdateProducts> createState() => _UpdateProductsState();

  static Widget _sectionCard({required String title, Widget? trailing, required Widget child}) {
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
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: primary)),
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
}

class _UpdateProductsState extends State<UpdateProducts> {
  final AddProductController controller = Get.put(AddProductController());

  @override
  Widget build(BuildContext context) {
    // Load product data into the controller once
    controller.loadProductData(
      ProductModel.fromMap(widget.existingData), // convert map to model
    );

    final width = MediaQuery.of(context).size.width;
    final horizontal = width * 0.05;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Update Product",
          style: TextStyle(
            color: UpdateProducts.primary,
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
              UpdateProducts._sectionCard(
                title: "Basic Information",
                child: Column(
                  children: [
                    _buildTextField(controller.nameController, "Product Name",
                        prefixIcon: Icons.inventory_2_outlined),
                    _buildDropdown(),
                    _buildTextField(controller.brandController, "Brand",
                        prefixIcon: Icons.branding_watermark_outlined),
                    _buildTextField(controller.descriptionController, "Description",
                        maxLines: 3, prefixIcon: Icons.description_outlined),
                    _buildTextField(controller.ingredientsController, "Ingredients",
                        maxLines: 2, prefixIcon: Icons.science_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              UpdateProducts._sectionCard(
                title: "Pricing & Inventory",
                child: Column(
                  children: [
                    _buildTextField(controller.priceController, "Price",
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.attach_money),
                    _buildTextField(controller.stockController, "Stock Quantity",
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.inventory_outlined),
                    _buildTextField(controller.weightController, "Weight/Size",
                        prefixIcon: Icons.scale_outlined),
                    _buildTextField(controller.animalTypeController, "Target Animal Type",
                        prefixIcon: Icons.pets_outlined),
                    _buildDatePickerField(
                        context: context,
                        textController: controller.expiryDateController,
                        label: "Expiry Date",
                        prefixIcon: Icons.event_outlined),
                    _buildTextField(controller.skuController, "SKU / Product Code",
                        prefixIcon: Icons.qr_code_2_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              UpdateProducts._sectionCard(
                title: "Product Images",
                trailing: Obx(() => Text(
                  "${controller.existingImageUrls.length + controller.selectedImages.length} images",
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
                          // Existing images from Firestore
                          ...List.generate(
                            controller.existingImageUrls.length,
                                (index) {
                              final url = controller.existingImageUrls[index];
                              return _imageTile(
                                child: Image.network(
                                  url,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2,
                                          color: UpdateProducts.primary,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Image load error for URL: $url, Error: $error');
                                    return Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.red[200]!, width: 1),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error_outline,
                                              color: Colors.red[400], size: 20),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Failed\nto load',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.red[600],
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          GestureDetector(
                                            onTap: () {
                                              // Force rebuild to retry image loading
                                              setState(() {});
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.red[100],
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Retry',
                                                style: TextStyle(
                                                  color: Colors.red[700],
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                onRemove: () => controller.existingImageUrls.removeAt(index),
                              );
                            },
                          ),
                          // Newly picked images
                          ...List.generate(
                            controller.selectedImages.length,
                                (index) {
                              final img = controller.selectedImages[index];
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
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: UpdateProducts.primary,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Selected image load error: $error');
                                      return Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          color: Colors.orange[50],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.orange[200]!, width: 1),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.warning_amber_outlined,
                                                color: Colors.orange[600], size: 20),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Preview\nfailed',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.orange[700],
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  onRemove: () => controller.selectedImages.removeAt(index),
                                );
                              } else {
                                return FutureBuilder<Uint8List>(
                                  future: img.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return _imageTile(
                                        child: Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: UpdateProducts.primary,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return _imageTile(
                                        child: Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.red[50],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.red[200]!, width: 1),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.error_outline,
                                                  color: Colors.red[400], size: 20),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Read\nfailed',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.red[600],
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        onRemove: () => controller.selectedImages.removeAt(index),
                                      );
                                    }

                                    if (!snapshot.hasData) {
                                      return _imageTile(
                                        child: Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: UpdateProducts.primary,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    return _imageTile(
                                      child: Image.memory(
                                        snapshot.data!,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                                      onRemove: () => controller.selectedImages.removeAt(index),
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
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.updateProduct(widget.productId),
                    icon: controller.isLoading.value
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.save, color: Colors.white),
                    label: Text(
                      controller.isLoading.value ? "Updating..." : "Update Product",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UpdateProducts.primary,
                      disabledBackgroundColor: UpdateProducts.primary.withOpacity(0.5),
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

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text, IconData? prefixIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: UpdateProducts.primary),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: UpdateProducts.primary, size: 20) : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: UpdateProducts.primary, width: 2),
          ),
        ),
      ),
    );
  }

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
          labelStyle: const TextStyle(color: UpdateProducts.primary),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: UpdateProducts.primary, size: 20) : null,
          suffixIcon: const Icon(Icons.calendar_today_outlined, color: UpdateProducts.primary, size: 20),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: now,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            textController.text = "${picked.year}-${picked.month}-${picked.day}";
          }
        },
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
              .map((category) => DropdownMenuItem(value: category, child: Text(category)))
              .toList(),
          icon: const Icon(Icons.arrow_drop_down, color: UpdateProducts.primary),
          decoration: InputDecoration(
            labelText: "Select Category",
            labelStyle: const TextStyle(color: UpdateProducts.primary),
            prefixIcon: const Icon(Icons.category_outlined, color: UpdateProducts.primary, size: 20),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
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
          child: Container(width: 90, height: 90, color: Colors.grey[200], child: child),
        ),
        if (onRemove != null)
          Positioned(
            right: 2,
            top: 2,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
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

  Widget _addImageTile({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: UpdateProducts.primary.withOpacity(0.6), width: 1.2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: UpdateProducts.primary, size: 24),
            SizedBox(height: 6),
            Text("Add", style: TextStyle(color: UpdateProducts.primary, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
