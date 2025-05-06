import 'package:al_haiwan/repository/controllers/bottom_nav_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/cart/cartscreen.dart';
import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/categories/categoryscreen.dart';
import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/doctors/doctorscreen.dart';
import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/home/homescreen.dart';

import '../screens/login/loginpage.dart';
import 'bottomNavScreens/profile/profile.dart';

class BottomNavScreen extends StatelessWidget {
  final BottomNavController controller = Get.put(BottomNavController());

  final List<Widget> pages = [
    HomeScreen(),
    Doctorscreen(),
    Categoryscreen(),
    Cartscreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Alhewan",
          style: TextStyle(color: Color(0xFF199A8E),fontFamily:"bolditalic"), // Custom teal color
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
            icon: _buildNavIcon('assets/images/home.png', 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/images/consult.png', 1),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/images/category.png', 2),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/images/cart.png', 3),
            label: 'Cart',
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

      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85, // 70% of screen width
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0XFF199A8E),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: AssetImage("assets/images/user.png"),
                ),
                accountName: const Text("Muhammad Taha"),
                accountEmail: const Text("tahazafar112@gmail.com"),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile', style: TextStyle(color: Color(0XFF199A8E))),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0XFF199A8E)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => Profilescreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home', style: TextStyle(color: Color(0XFF199A8E))),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0XFF199A8E)),
                onTap: () {
                  controller.changeIndex(0);
                  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.medical_services),
                title: const Text('Doctors', style: TextStyle(color: Color(0XFF199A8E))),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0XFF199A8E)),
                onTap: () {
                  controller.changeIndex(1);
                  Get.back();
                },
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Appointments', style: TextStyle(color: Color(0XFF199A8E))),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0XFF199A8E)),

                onTap: () {
                  // Navigate to appointment screen
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.receipt_long),
                title: Text('My Orders', style: TextStyle(color: Color(0XFF199A8E))),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0XFF199A8E)),

                onTap: () {
                  // Navigate to orders screen
                  Navigator.pop(context);
                },
              ),


              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Categories', style: TextStyle(color: Color(0XFF199A8E))),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0XFF199A8E)),
                onTap: () {
                  controller.changeIndex(2);
                  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('Cart', style: TextStyle(color: Color(0XFF199A8E))),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0XFF199A8E)),
                onTap: () {
                  controller.changeIndex(3);
                  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),
      ),

    ));
  }

  /// Bottom nav icon widget
  Widget _buildNavIcon(String assetPath, int index) {
    final isSelected = controller.currentIndex.value == index;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isSelected ? Color(0x1A199A8E) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          isSelected ? Color(0XFF199A8E) : Colors.grey,
          BlendMode.srcIn,
        ),
        child: Image.asset(assetPath, width: 24, height: 24),
      ),
    );
  }
  void _showLogoutDialog(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEFF9F8),
                  ),
                  child: const Icon(Icons.logout,
                      color: Color(0xFF199A8E), size: 32),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Are you sure to log out of your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => Loginpage()),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF199A8E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Log Out",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color(0xFF199A8E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}



