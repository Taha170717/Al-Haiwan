import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/doctors/doctorscreen.dart';
import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/home/product/Product%20ViewModel.dart';
import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/home/product/Product_detail.dart';
import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/home/product/product%20Modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/bottom_nav_controller.dart';
import '../doctors/DoctorDetailView.dart';
import '../doctors/doctor_list_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final DoctorListViewModel doctorController = Get.put(DoctorListViewModel());
  final ProductListViewModel productController = Get.put(ProductListViewModel());


  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              SizedBox(
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search doctor, drugs, articles...",
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white30,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),

                    // Border when NOT focused
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Color(0xFF199A8E),
                        width: 1.5,
                      ),
                    ),

                    // Border when focused (active)
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Color(0xFF199A8E), // Custom teal
                        width: 1.0, // Slightly thinner border
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Category Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryIcon(Icons.local_hospital, "Doctor"),
                  _buildCategoryIcon(Icons.local_pharmacy, "Pharmacy"),
                  _buildCategoryIcon(Icons.local_hospital_outlined, "Food"),
                  _buildCategoryIcon(Icons.local_shipping, "Ambulance"),
                ],
              ),
              const SizedBox(height: 20),

              // Promo Banner
              _buildPromoBanner(screen),
              const SizedBox(height: 20),

              // Top Doctor Section
              _buildSectionHeader("Top Doctor"),
              SizedBox(
                height: 15,
              ),
              SizedBox(
                height: 180,
                child: Obx(() => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: doctorController.doctors.length,
                  itemBuilder: (context, index) {
                    final doc = doctorController.doctors[index];
                    return _buildDoctorCard(doc);
                  },
                )),
              ),
              const SizedBox(height: 20),

              // Products Section
              _buildSectionHeader("Pharmacy"),
              Obx(() => GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 4,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productController.products.length,
                itemBuilder: (context, index) {
                  final product = productController.products[index];
                  return _buildProductCard(product);
                },
              )),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner(Size screen) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Early protection for your family health",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF199A8E),
                  ),
                  onPressed: () {},
                  child: const Text("Learn more", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: screen.width * 0.25,
            height: screen.width * 0.25,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(2),
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

  Widget _buildCategoryIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF199A8E), width: 1.5),
          ),
          child: Icon(icon, color: const Color(0xFF199A8E), size: 28),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        GestureDetector(
          onTap: () {
            final controller = Get.find<BottomNavController>();
            controller.changeIndex(1); // Assuming Doctorscreen is at index 1
          },
          child: const Text(
            "See all",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(Doctor doc) {
    return GestureDetector(
      onTap: () {
        Get.to(() => DoctorDetailView(doctor: doc)); // Pass the doctor object
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              child: Image.asset(
                doc.image,
                height: 90,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                children: [
                  Text(doc.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  Text(doc.speciality, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.orange),
                      Text(doc.rating.toString(), style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      const Icon(Icons.location_on, size: 12, color: Colors.grey),
                      Text(doc.distance, style: const TextStyle(fontSize: 11)),
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

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailView(product: product));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 80,
              padding: const EdgeInsets.all(4),
              child: Image.asset(product.imagePath, fit: BoxFit.contain),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(product.price, style: const TextStyle(color: Colors.green)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}
