import 'package:al_haiwan/admin/controllers/admin_bottom_nav_controller.dart';
import 'package:al_haiwan/doctor/views/bottom_nav_pages/appointments/doctor_appointment_management_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../user/repository/screens/login/loginpage.dart';
import 'bottom_nav_pages/admin_doctor_verfication/doctor_verfication.dart';
import 'bottom_nav_pages/appointments/appointmentspage.dart';
import 'bottom_nav_pages/dashboard/dashboardpage.dart';
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
    AdminAppointmentsScreen(),
    AdminProducts(),
    AdminOrderManagementScreen(),
    AdminDoctorVerificationPage()
  ];

  User? user; // To store the logged-in user's information

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    user = FirebaseAuth.instance.currentUser; // Fetch the logged-in user
    setState(() {}); // Update the UI
  }

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
        title: const Text(
          "Al-Haiwan Admin Panel",
          style: TextStyle(color: Color(0xFF199A8E), fontFamily: "bolditalic"),
        ),
        iconTheme: const IconThemeData(color: Color(0XFF199A8E)),
      ),
      body: IndexedStack(
        index: controller.currentIndex.value,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/adminicons/dashboard.png', 0),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/adminicons/appointment.png', 1),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/adminicons/products.png', 2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/adminicons/orders.png', 3),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icons/consult.png', 4),
            label: 'Doctors',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0XFF199A8E),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: (index) => controller.changeIndex(index),
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                currentAccountPicture: const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage("assets/images/user.png"),
                ),
                accountName: const Text(
                  "Admin",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(
                  user?.email ?? "No user logged in", // Display user email or fallback
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              _buildDrawerTile(
                icon: "assets/adminicons/profile.png",
                label: "Profile",
                onTap: () {
                  controller.changeIndex(4);
                  Get.back();
                },
              ),
              _buildDivider(),
              _buildDrawerTile(
                icon: "assets/adminicons/patient.png",
                label: "Patients",
                onTap: () {},
              ),
              _buildDivider(),
              _buildDrawerTile(
                icon: "assets/icons/consult.png",
                label: "Doctors",
                onTap: () {
                  Get.to(() => AdminDoctorVerificationPage());
                },
              ),
              _buildDivider(),
              _buildDrawerTile(
                icon: "assets/adminicons/appointment.png",
                label: "Appointments",
                onTap: () {
                  controller.changeIndex(1);
                  Get.back();
                },
              ),
              _buildDivider(),
              _buildDrawerTile(
                icon: "assets/adminicons/report.png",
                label: "Report & Analytics",
                onTap: () {
                  Get.to(() => AdminOrderManagementScreen());
                },
              ),
              _buildDivider(),
              _buildDrawerTile(
                icon: "assets/adminicons/products.png",
                label: "Products",
                onTap: () {
                  controller.changeIndex(2);
                  Get.back();
                },
              ),
              _buildDivider(),
              _buildDrawerTile(
                icon: "assets/adminicons/orders.png",
                label: "Orders",
                onTap: () {
                  controller.changeIndex(3);
                  Get.back();
                },
              ),
              _buildDivider(),
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
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) =>  Loginpage()),
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

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFF199A8E),
      thickness: 0.6,
      indent: 20,
      endIndent: 20,
    );
  }

  Widget _buildDrawerTile({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Image.asset(icon, height: 24, width: 24, color: const Color(0XFF199A8E)),
      title: Text(
        label,
        style: const TextStyle(
          color: Color(0XFF199A8E),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0XFF199A8E)),
      onTap: onTap,
    );
  }
}