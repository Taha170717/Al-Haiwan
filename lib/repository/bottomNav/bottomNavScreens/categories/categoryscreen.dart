import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'category_viewmodel.dart';

class Categoryscreen extends StatelessWidget {
  final CategoryViewModel categoryController = Get.put(CategoryViewModel());

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Obx(() => GridView.builder(
          itemCount: categoryController.categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3 / 2.8,
          ),
          itemBuilder: (context, index) {
            final category = categoryController.categories[index];
            return _buildCategoryCard(category, screen);
          },
        )),
      ),
    );
  }

  Widget _buildCategoryCard(category, Size screen) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF199A8E), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screen.width * 0.18,
            height: screen.width * 0.18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF199A8E), width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF199A8E).withOpacity(0.5),
                  blurRadius: 2,
                 // offset: const Offset(0, 3),
                ),
              ],
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              category.iconPath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            category.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
