import 'package:al_haiwan/user/repository/bottomNav/bottomNavScreens/cart/cartscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../controllers/bottom_nav_controller.dart';
import '../../../../controllers/verified_doctor_controller.dart';
import '../../../../models/cart_viewmodel.dart';
import '../categories/category_view_products.dart';
import '../categories/product_detail_page.dart';
import '../doctors/DoctorDetailView.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final VerifiedDoctorsController doctorController = Get.put(VerifiedDoctorsController());
  late final CartViewModel cartVM = Get.find<CartViewModel>();

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Obx(() => cartVM.itemCount > 0 ? FloatingActionButton(
        onPressed: () => Get.to(() => CartScreen()),
        backgroundColor: const Color(0xFF199A8E),
        child: Stack(
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '${cartVM.itemCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ) : const SizedBox.shrink()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: screen.width * 0.04,
              vertical: screen.height * 0.01
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              SizedBox(
                height: screen.height * 0.05,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search doctor, drugs, articles...",
                    hintStyle: TextStyle(fontSize: screen.width * 0.035),
                    prefixIcon: Icon(Icons.search, size: screen.width * 0.05),
                    filled: true,
                    fillColor: Colors.white30,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: screen.height * 0.012,
                        horizontal: screen.width * 0.04
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screen.width * 0.075),
                      borderSide: const BorderSide(
                        color: Color(0xFF199A8E),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screen.width * 0.075),
                      borderSide: const BorderSide(
                        color: Color(0xFF199A8E),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screen.height * 0.025),

              // Category Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryIcon(Icons.local_hospital, "Doctor", screen),
                  _buildCategoryIcon(Icons.local_pharmacy, "Pharmacy", screen),
                  _buildCategoryIcon(Icons.local_hospital_outlined, "Food", screen),
                  _buildCategoryIcon(Icons.local_shipping, "Ambulance", screen),
                ],
              ),
              SizedBox(height: screen.height * 0.025),

              // Promo Banner
              _buildPromoBanner(screen),
              SizedBox(height: screen.height * 0.025),

              // Top Doctor Section
              _buildSectionHeader("Doctor", screen),
              SizedBox(height: screen.height * 0.018),
              SizedBox(
                height: screen.height * 0.26,
                child: Obx(() {
                  if (doctorController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (doctorController.verifiedDoctors.isEmpty) {
                    return const Center(child: Text("No doctors available"));
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: doctorController.verifiedDoctors.length,
                    itemBuilder: (context, index) {
                      final doc = doctorController.verifiedDoctors[index];
                      return _buildDoctorCard(doc, screen);
                    },
                  );
                }),
              ),
              SizedBox(height: screen.height * 0.025),

              // Products Section
              _buildSectionHeader("Pharmacy", screen, () {

                  final controller = Get.find<BottomNavController>();
                  controller.changeIndex(2);

              }),
              SizedBox(height: screen.height * 0.018),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: screen.height * 0.25,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF199A8E)),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return SizedBox(
                      height: screen.height * 0.25,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: screen.width * 0.15,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: screen.height * 0.01),
                            Text(
                              'No products available',
                              style: TextStyle(
                                fontSize: screen.width * 0.035,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: screen.width * 0.03,
                      mainAxisSpacing: screen.height * 0.015,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return _buildProductCard(data, screen, doc.id, context);
                    },
                  );
                },
              ),
              SizedBox(height: screen.height * 0.02),
              Center(
                child: ElevatedButton(
                  onPressed: () {

                      final controller = Get.find<BottomNavController>();
                      controller.changeIndex(3);

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF199A8E),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: screen.width * 0.08,
                      vertical: screen.height * 0.015,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'See More Products',
                    style: TextStyle(
                      fontSize: screen.width * 0.03,
                      fontWeight: FontWeight.bold,
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

  Widget _buildPromoBanner(Size screen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screen.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(screen.width * 0.04),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Early protection for your family health",
                  style: TextStyle(
                      fontSize: screen.width * 0.04,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: screen.height * 0.012),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF199A8E),
                    padding: EdgeInsets.symmetric(
                        horizontal: screen.width * 0.04,
                        vertical: screen.height * 0.01
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                      "Learn more",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: screen.width * 0.035
                      )
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: screen.width * 0.025),
          Container(
            width: screen.width * 0.25,
            height: screen.width * 0.25,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(screen.width * 0.005),
            child: ClipOval(
              child: Image.asset(
                'assets/images/dcotor.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label, Size screen) {
    return Column(
      children: [
        Container(
          width: screen.width * 0.15,
          height: screen.width * 0.15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF199A8E), width: 1.5),
          ),
          child: Icon(icon, color: const Color(0xFF199A8E), size: screen.width * 0.07),
        ),
        SizedBox(height: screen.height * 0.008),
        Text(
            label,
            style: TextStyle(
                color: Colors.black87,
                fontSize: screen.width * 0.032
            )
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Size screen, [VoidCallback? onSeeAllTap]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screen.width * 0.04,
              fontFamily: "bolditalic",
            color: Color(0xFF199A8E),
          ),
        ),
        GestureDetector(
          onTap: onSeeAllTap ?? () {
            final controller = Get.find<BottomNavController>();
            controller.changeIndex(1);
          },
          child: Text(
            "See all",
            style: TextStyle(
                color: Colors.blue,
                fontSize: screen.width * 0.035
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(dynamic doc, Size screen) {
    return GestureDetector(
      onTap: () {
        Get.to(() => DoctorDetailView(doctorId: doc.id, doctor: doc,));
      },
      child: Container(
        width: screen.width * 0.35,
        margin: EdgeInsets.only(right: screen.width * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screen.width * 0.03),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 6,
                offset: const Offset(0, 2)
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screen.width * 0.03),
                  topRight: Radius.circular(screen.width * 0.03)
              ),
              child: Image.network(
                doc.profileImageUrl ?? 'assets/images/default_doctor.png',
                height: screen.height * 0.14,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: screen.height * 0.11,
                    color: Colors.grey[200],
                    child: Icon(Icons.person, size: screen.width * 0.1),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screen.width * 0.015),
              child: Column(
                children: [
                  Text(
                    doc.fullName ?? doc.name ?? 'Unknown Doctor',
                    style: TextStyle(
                        fontSize: screen.width * 0.032,
                        fontWeight: FontWeight.bold
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    doc.specialty ?? 'General',
                    style: TextStyle(
                        fontSize: screen.width * 0.028,
                        color: Colors.grey
                    ),
                  ),
                  SizedBox(height: screen.height * 0.005),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work,
                          size: screen.width * 0.03, color: Colors.blueGrey),
                      Text(doc.experience?.toString() ?? 'N/A',
                          style: TextStyle(fontSize: screen.width * 0.028)),
                      SizedBox(width: screen.width * 0.01),
                      Icon(Icons.location_on, size: screen.width * 0.03, color: Colors.grey),
                      Flexible(
                        child: Text(
                          doc.location ?? 'Unknown',
                          style: TextStyle(fontSize: screen.width * 0.028),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Added context as a parameter to fix the error
  Widget _buildProductCard(Map<String, dynamic> data, Size screen, String productId, BuildContext context) {
    final name = data['name']?.toString() ?? 'Unknown Product';
    final brand = data['brand']?.toString() ?? '';
    final price = data['price']?.toDouble() ?? 0.0;
    final stockQuantity = data['stockQuantity']?.toInt() ?? 0;
    final imageUrls = List<String>.from(data['imageUrls'] ?? []);
    final imageUrl = imageUrls.isNotEmpty ? imageUrls.first : '';

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailPage(productId: productId, productData: data)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.grey[100]!, Colors.grey[50]!],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF199A8E)),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey[200]!, Colors.grey[100]!],
                              ),
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              size: screen.width * 0.12,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      )
                          : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey[200]!, Colors.grey[100]!],
                          ),
                        ),
                        child: Icon(
                          Icons.image,
                          size: screen.width * 0.12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _showProductBottomSheet(context, data, productId, screen),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart,
                          color: Color(0xFF199A8E),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(screen.width * 0.025),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: screen.width * 0.032,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    if (brand.isNotEmpty) ...[
                      SizedBox(height: screen.height * 0.002),
                      Flexible(
                        child: Text(
                          brand,
                          style: TextStyle(
                            fontSize: screen.width * 0.028,
                            color: const Color(0xFF199A8E),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],

                    const Spacer(),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\RS-${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: screen.width * 0.035,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF199A8E),
                          ),
                        ),
                        SizedBox(height: screen.height * 0.002),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screen.width * 0.015,
                            vertical: screen.height * 0.002,
                          ),
                          decoration: BoxDecoration(
                            color: stockQuantity > 5
                                ? Colors.green[100]
                                : stockQuantity > 0
                                ? Colors.orange[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            stockQuantity > 5
                                ? 'In Stock'
                                : stockQuantity > 0
                                ? 'Low Stock'
                                : 'Out of Stock',
                            style: TextStyle(
                              fontSize: screen.width * 0.022,
                              fontWeight: FontWeight.w600,
                              color: stockQuantity > 5
                                  ? Colors.green[700]
                                  : stockQuantity > 0
                                  ? Colors.orange[700]
                                  : Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductBottomSheet(BuildContext context, Map<String, dynamic> data, String productId, Size screen) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: screen.height * 0.35,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: screen.height * 0.015),
              width: screen.width * 0.12,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screen.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: screen.width * 0.2,
                          height: screen.width * 0.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[100],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: data['imageUrls'] != null && (data['imageUrls'] as List).isNotEmpty
                                ? Image.network(
                              (data['imageUrls'] as List).first,
                              fit: BoxFit.cover,
                            )
                                : Icon(Icons.image, color: Colors.grey[400]),
                          ),
                        ),
                        SizedBox(width: screen.width * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'] ?? 'Unknown Product',
                                style: TextStyle(
                                  fontSize: screen.width * 0.035,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: screen.height * 0.005),
                              Text(
                                '\Rs-${(data['price']?.toDouble() ?? 0.0).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: screen.width * 0.04,
                                  color: const Color(0xFF199A8E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screen.height * 0.03),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final imageUrls = data['imageUrls'] as List<dynamic>? ?? [];
                              final imageUrl = imageUrls.isNotEmpty ? imageUrls.first.toString() : '';

                              await cartVM.addToCart(
                                productId,
                                data['name']?.toString() ?? 'Unknown Product',
                                imageUrl,
                                '1 unit',
                                data['price']?.toDouble() ?? 0.0,
                                1,
                              );

                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF199A8E),
                              side: const BorderSide(color: Color(0xFF199A8E)),
                              padding: EdgeInsets.symmetric(vertical: screen.height * 0.02),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontSize: screen.width * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screen.width * 0.04),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final imageUrls = data['imageUrls'] as List<dynamic>? ?? [];
                              final imageUrl = imageUrls.isNotEmpty ? imageUrls.first.toString() : '';

                              await cartVM.addToCart(
                                productId,
                                data['name']?.toString() ?? 'Unknown Product',
                                imageUrl,
                                '1 unit',
                                data['price']?.toDouble() ?? 0.0,
                                1,
                              );

                              Navigator.pop(context);
                              Get.to(() => CartScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF199A8E),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: screen.height * 0.02),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Buy Now',
                              style: TextStyle(
                                fontSize: screen.width * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}