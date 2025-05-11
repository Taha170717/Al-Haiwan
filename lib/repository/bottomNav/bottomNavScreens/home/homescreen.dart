import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/doctors/doctorscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/bottom_nav_controller.dart';
import '../doctors/DoctorDetailView.dart';
import '../doctors/doctor_list_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final DoctorListViewModel doctorController = Get.put(DoctorListViewModel());

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
                height: 40, // Adjust height as needed
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search doctor, drugs, articles...",
                    prefixIcon: const Icon(Icons.search, size: 20), // Smaller iconjjkasjdkasdksaldas
                    filled: true,
                    fillColor: Colors.white30,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16), // Reduce padding
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Color(0xFF199A8E)
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
                height: 190,
                child: Obx(() => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: doctorController.doctors.length,
                  itemBuilder: (context, index) {
                    final doc = doctorController.doctors[index];
                    return _buildDoctorCard(doc, screen);
                  },
                )),
              ),
              const SizedBox(height: 20),

              // Products Section
              _buildSectionHeader("Pharmacy"),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 3 / 4,
                children: [
                  _buildProductCard("Vitamin C", "₨ 350", 'assets/images/med1.png'),
                  _buildProductCard("Pain Relief Gel", "₨ 250", 'assets/images/panadol.png'),
                  _buildProductCard("Bandage Pack", "₨ 150", 'assets/images/obh.png'),
                  _buildProductCard("Face Mask", "₨ 200", 'assets/images/med1.png'),
                ],
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
            controller.changeIndex(1); // Assuming index 1 is Doctorscreen
          },
          child: const Text(
            "See all",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }


  Widget _buildDoctorCard(Doctor doc, Size screen) {
    return Container(
      width: screen.width * 0.38,
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
              width: double.infinity,
              height: 100,
              fit: BoxFit.cover,
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
    );
  }

  Widget _buildProductCard(String title, String price, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              child: Image.asset(imagePath, fit: BoxFit.contain, width: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(price, style: const TextStyle(color: Colors.green)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
