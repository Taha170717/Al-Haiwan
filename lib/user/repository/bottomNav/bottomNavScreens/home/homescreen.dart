import 'package:al_haiwan/user/repository/bottomNav/bottomNavScreens/home/product/Product_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/bottom_nav_controller.dart';

import '../../../controllers/verified_doctor_controller.dart';
import '../doctors/DoctorDetailView.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final VerifiedDoctorsController doctorController = Get.put(VerifiedDoctorsController());

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
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
              _buildSectionHeader("Top Doctor", screen),
              SizedBox(height: screen.height * 0.018),
              SizedBox(
                height: screen.height * 0.22,
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
              _buildSectionHeader("Pharmacy", screen),

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

  Widget _buildSectionHeader(String title, Size screen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screen.width * 0.04
          ),
        ),
        GestureDetector(
          onTap: () {
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
                height: screen.height * 0.11,
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
                      Icon(Icons.star, size: screen.width * 0.03, color: Colors.orange),
                      Text(
                          doc.rating?.toString() ?? '0.0',
                          style: TextStyle(fontSize: screen.width * 0.028)
                      ),
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

  Widget _buildProductCard(dynamic product, Size screen) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailView(product: product));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screen.width * 0.03),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 4,
                offset: const Offset(0, 2)
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: screen.height * 0.1,
              padding: EdgeInsets.all(screen.width * 0.01),
              child: Image.asset(
                product.imagePath ?? 'assets/images/default_product.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.medical_services, size: screen.width * 0.1);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screen.width * 0.005),
              child: Column(
                children: [
                  Text(
                    product.name ?? 'Unknown Product',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screen.width * 0.032
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.price ?? '₨0',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: screen.width * 0.03
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
