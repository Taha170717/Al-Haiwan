import 'package:al_haiwan/user/controllers/bottom_nav_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_haiwan/user/repository/bottomNav/bottomNavScreens/cart/cartscreen.dart';
import 'package:al_haiwan/user/repository/bottomNav/bottomNavScreens/categories/categoryscreen.dart';
import 'package:al_haiwan/user/repository/bottomNav/bottomNavScreens/doctors/doctorscreen.dart';
import 'package:al_haiwan/user/repository/bottomNav/bottomNavScreens/home/homescreen.dart';
import 'package:al_haiwan/user/repository/bottomNav/bottomNavScreens/myappointments/myAppointment.dart';

import 'widgets/doctor_chat_drawer.dart';
import '../screens/login/loginpage.dart';
import 'bottomNavScreens/myorders/myorders.dart';
import 'bottomNavScreens/profile/profile.dart';
import '../user_service.dart';
import '../../../luna_Chatbot/screens/chat_screen.dart';

class BottomNavScreen extends StatelessWidget {
  final BottomNavController controller = Get.put(BottomNavController());
  final UserService userService = Get.find<UserService>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> pages = [
    HomeScreen(),
    VerifiedDoctorsScreen(),
    MyAppointmentScreen(),
    Categoryscreen(),
    CartScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Alhewan",
          style: TextStyle(
              color: Color(0xFF199A8E),
              fontFamily: "bolditalic"),
        ),
        iconTheme: IconThemeData(color: Color(0XFF199A8E)),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF199A8E)),
            onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
          ),
        ],
      ),
      body: IndexedStack(
        index: controller.currentIndex.value,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icons/home.png', 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icons/consult.png', 1),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icons/schedule.png', 2),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icons/category.png', 3),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icons/cart.png', 4),
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
      floatingActionButton: (controller.currentIndex.value != 3 &&
          controller.currentIndex.value != 4)
          ? FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Get.to(() => const ChatBotScreen());
        },
        child: Image.asset(
          "assets/images/luna.png",
          width: 90,
          height: 90,
        ),
      )
          : null,
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Obx(() => UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20)),
                ),
                currentAccountPicture: CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFF199A8E).withOpacity(0.1),
                  child: Builder(
                    builder: (context) {
                      userService.refreshProfile();

                      final profileImageUrl = userService.getUserImage;

                      if (profileImageUrl != null &&
                          profileImageUrl.isNotEmpty) {
                        return ClipOval(
                          child: Image.network(
                            profileImageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print(
                                  'Error loading profile image: $error');
                              return Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[200],
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Color(0xFF199A8E),
                                ),
                              );
                            },
                            loadingBuilder:
                                (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 70,
                                height: 70,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        Color(0xFF199A8E)),
                                    value: loadingProgress
                                        .expectedTotalBytes !=
                                        null
                                        ? loadingProgress
                                        .cumulativeBytesLoaded /
                                        loadingProgress
                                            .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        );
                      }
                    },
                  ),
                ),
                accountName: Text(
                  userService.getUserName ?? "User",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(
                  userService.getUserEmail ?? "user@example.com",
                  style: const TextStyle(fontSize: 14),
                ),
              )),
              _buildDrawerTile(
                icon: "assets/icons/profile.png",
                label: "Profile",
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ProfileScreen()));
                },
              ),
              _buildDivider(),
              _buildDrawerTile(
                icon: "assets/icons/home.png",
                label: "Home",
                onTap: () {
                  controller.changeIndex(0);
                  Get.back();
                },
              ),
              _buildDivider(),
              _buildDrawerTile(
                icon: "assets/icons/consult.png",
                label: "Doctors",
                onTap: () {
                  controller.changeIndex(1);
                  Get.back();
                },
              ),
              _buildDivider(),
              _buildDrawerTile(
                icon: "assets/icons/schedule.png",
                label: "Appointments",
                onTap: () {
                  controller.changeIndex(2);
                  Get.back();
                },
              ),
              _buildDivider(),
              _buildDrawerTile(
                icon: "assets/icons/checkout.png",
                label: "My Orders & Appointments",
                onTap: () {
                  Get.to(() => MyAppointmentsOrdersPage());
                },
              ),
              _buildDivider(),
              _buildDrawerTile(
                icon: "assets/icons/category.png",
                label: "Categories",
                onTap: () {
                  controller.changeIndex(3);
                  Get.back();
                },
              ),
              _buildDivider(),
              _buildDrawerTile(
                icon: "assets/icons/cart.png",
                label: "Cart",
                onTap: () {
                  controller.changeIndex(4);
                  Get.back();
                },
              ),
              _buildDivider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
      endDrawer: const DoctorChatDrawer(),
    ));
  }

  /// Bottom nav icon widget
  Widget _buildNavIcon(String assetPath, int index) {
    final isSelected = controller.currentIndex.value == index;

    return Container(
      padding: const EdgeInsets.all(4),
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

  void _showLogoutDialog(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
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
                    onPressed: () async {
                      Navigator.of(context).pop();

                      await userService.signOut();

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

  Widget _buildDrawerTile({required String icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Image.asset(icon, height: 24, width: 24, color: Color(0XFF199A8E)),
      title: Text(label,
          style: TextStyle(
              color: Color(0XFF199A8E), fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0XFF199A8E)),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFF199A8E),
      thickness: 0.6,
      indent: 20,
      endIndent: 20,
    );
  }
}
