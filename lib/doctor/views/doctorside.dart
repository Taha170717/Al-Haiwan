import 'package:al_haiwan/doctor/controller/doctor_bottom_nav_Controller.dart';
import 'package:al_haiwan/doctor/views/bottom_nav_pages/chat/chatpage.dart';
import 'package:al_haiwan/doctor/views/bottom_nav_pages/dashboard/dashboardpage.dart';
import 'package:al_haiwan/doctor/views/bottom_nav_pages/medicalrecords/medicalrecordpage.dart';
import 'package:al_haiwan/doctor/views/bottom_nav_pages/profile/profilepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../repository/screens/login/loginpage.dart';
import 'bottom_nav_pages/appointments/appoinmentspage.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  final DoctorBottomNavController controller = Get.put(DoctorBottomNavController());
  final List<Widget> pages = [
    DoctorDashboard(),
    AppointmentPage(),
    MedicalRecordPage(),
    Chatpage(),
    DoctorProfile(),
  ];

  User? user; // Firebase authenticated user
  String? username; // Username of the logged-in user
  String? email; // Email of the logged-in user
  bool isDoctor = false; // Flag for doctor account

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      user = FirebaseAuth.instance.currentUser; // Get authenticated user
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get(); // Fetch data from Firestore
        if (snapshot.exists) {
          setState(() {
            username = snapshot.data()?['username'] ?? "Unknown";
            email = snapshot.data()?['email'] ?? user!.email;
            isDoctor = snapshot.data()?['isDoctor'] ?? false;
          });
        }
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(() =>  Loginpage());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Welcome Doctor",
          style: TextStyle(
            color: Color(0xFF199A8E),
            fontFamily: "bolditalic",
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0XFF199A8E)),
      ),
      body: IndexedStack(
        index: controller.currentIndex.value,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/doctor_icons/dashboard.png', 0),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/doctor_icons/appointment.png', 1),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/doctor_icons/medicalrecord.png', 2),
            label: 'Medical Records',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/doctor_icons/chat.png', 3),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/doctor_icons/profile.png', 4),
            label: 'Profile',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: controller.currentIndex.value,
        selectedItemColor: const Color(0XFF199A8E),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: controller.changeIndex,
      ),
      drawer: _buildDrawer(),
    ));
  }

  Widget _buildDrawer() {
    return SizedBox(
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
              accountName: Text(
                isDoctor ? (username ?? "Doctor") : "Not a Doctor",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                isDoctor ? (email ?? "No Email") : "Not Authorized",
                style: const TextStyle(fontSize: 14),
              ),
            ),
            _buildDivider(),
            _buildDrawerTile(
              icon: "assets/doctor_icons/dashboard.png",
              label: "Dashboard",
              onTap: () {
                controller.changeIndex(0);
                Get.back();
              },
            ),
            _buildDivider(),
            _buildDrawerTile(
              icon: "assets/doctor_icons/appointment.png",
              label: "Appointments",
              onTap: () {
                Get.to(() => AppointmentPage());
              },
            ),
            _buildDivider(),
            _buildDrawerTile(
              icon: "assets/doctor_icons/medicalrecords.png",
              label: "Patient Records",
              onTap: () {},
            ),
            _buildDivider(),
            _buildDrawerTile(
              icon: "assets/doctor_icons/chat.png",
              label: "Messages",
              onTap: () {
                controller.changeIndex(1);
                Get.back();
              },
            ),
            _buildDivider(),
            _buildDrawerTile(
              icon: "assets/doctor_icons/money.png",
              label: "Earnings",
              onTap: () {},
            ),
            _buildDivider(),
            _buildDrawerTile(
              icon: "assets/doctor_icons/available.png",
              label: "Availability Settings",
              onTap: () {
                controller.changeIndex(2);
                Get.back();
              },
            ),
            _buildDrawerTile(
              icon: "assets/doctor_icons/profile.png",
              label: "Profile",
              onTap: () {
                controller.changeIndex(4);
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