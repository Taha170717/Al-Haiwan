import 'package:al_haiwan/admin/controllers/admin_bottom_nav_controller.dart';
import 'package:al_haiwan/admin/views/bottom_nav_pages/appointments/appointmentspage.dart';
import 'package:al_haiwan/admin/views/bottom_nav_pages/dashboard/dashboardpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../repository/screens/login/loginpage.dart';
import 'bottom_nav_pages/orders/order_page.dart';
import 'bottom_nav_pages/products/products_page.dart';
import 'bottom_nav_pages/profile/profile_page.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AdminBottomNavController controller = Get.put(AdminBottomNavController());
  final List<Widget> pages = [
    AdminDashboard(),
    AdminAppointment(),
    AdminProducts(),
    AdminOrders(),
    AdminProfile(),

  ];
  Future<void> _logout() async {
   await FirebaseAuth.instance.signOut();
    Get.offAll(() => Loginpage());
  }
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Al-haiwan Admin Panel",
            style: TextStyle(
                color: Color(0xFF199A8E),
                fontFamily: "bolditalic"), // Custom teal color
          ),
          iconTheme: IconThemeData(color: Color(0XFF199A8E)),
        ),
      body: IndexedStack(
        index: controller.currentIndex.value,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icons/dashboard.png', 0),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icons/consult.png', 1),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icons/category.png', 2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icons/cart.png', 3),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icons/cart.png', 4),
            label: 'Profile',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: controller.currentIndex.value,
        selectedItemColor: Color(0XFF199A8E),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontSize: 10),
        unselectedLabelStyle: TextStyle(fontSize: 10),
        onTap: controller.changeIndex,
      ),
    )
    );
  }
  Widget _buildNavIcon(String assetPath, int index) {
    final isSelected = controller.currentIndex.value == index;

    return Container(
      padding: const EdgeInsets.all(4), // Reduced padding
      decoration: BoxDecoration(
        color: isSelected ? const Color(0x1A199A8E) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          isSelected ? const Color(0XFF199A8E) : Colors.grey,
          BlendMode.srcIn,
        ),
        child: Image.asset(
          assetPath,
          width: 22,
          height: 22,
        ),
      ),
    );
  }
}
