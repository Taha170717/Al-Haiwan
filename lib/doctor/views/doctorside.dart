import 'dart:async';

import 'package:al_haiwan/doctor/controller/doctor_bottom_nav_Controller.dart';
import 'package:al_haiwan/doctor/views/bottom_nav_pages/chat/chatpage.dart';
import 'package:al_haiwan/doctor/views/bottom_nav_pages/dashboard/dashboardpage.dart';
import 'package:al_haiwan/doctor/views/bottom_nav_pages/medicalrecords/medicalrecordpage.dart';
import 'package:al_haiwan/doctor/views/bottom_nav_pages/profile/profilepage.dart';
import 'package:al_haiwan/doctor/views/bottom_nav_pages/appointments/appoinmentspage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../repository/screens/login/loginpage.dart';
import 'dart:ui';
/andjjdjs
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

  User? user;
  String? username;
  String? email;
  bool isDoctor = false;
  bool isVerified = false;
  String? profileImageUrl;
  bool isLoading = true;
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  StreamSubscription<DocumentSnapshot>? _verificationSubscription;

  @override
  void initState() {
    super.initState();
    _setupUserListener();
    _setupVerificationListener();
    ever(controller.currentIndex, (index) => _checkVerificationForNavigation(index));
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _verificationSubscription?.cancel();
    super.dispose();
  }

  void _setupUserListener() {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data()!;
          if (mounted) {
            setState(() {
              username = data['username'] ?? "Unknown";
              email = data['email'] ?? user!.email;
              isDoctor = data['isDoctor'] ?? false;
              isVerified = data['isVerified'] ?? false;
              isLoading = false;
            });
          }
        } else {
          _createUserDocument();
        }
      }, onError: (error) {
        print("Error listening to user details: $error");
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _setupVerificationListener() {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _verificationSubscription = FirebaseFirestore.instance
          .collection('doctor_verification_requests')
          .doc(user!.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && mounted) {
          final data = snapshot.data()!;

          String? imageUrl;

          if (data['documents'] != null) {
            final documents = data['documents'] as Map<String, dynamic>;
            imageUrl = documents['profilePicture'] ??
                documents['profileImageUrl'] ??
                documents['profile_picture'] ??
                documents['image_url'];
          }

          if (imageUrl == null) {
            imageUrl = data['profilePicture'] ??
                data['profileImageUrl'] ??
                data['profile_picture'] ??
                data['image_url'];
          }

          setState(() {
            profileImageUrl = imageUrl;
          });
        }
      }, onError: (error) {
        print("Error listening to verification details: $error");
      });
    }
  }

  Future<void> _createUserDocument() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'username': user!.displayName ?? "Doctor",
        'email': user!.email,
        'isDoctor': true,
        'isVerified': false,
        'verificationStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error creating user document: $e");
    }
  }

  void _checkVerificationForNavigation(int targetIndex) {
    if (!isVerified && targetIndex != 4) {
      Future.delayed(Duration.zero, () {
        controller.changeIndex(4);
        _showVerificationDialog();
      });
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Colors.orange,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Admin Verification Required",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Your doctor account is pending admin approval. Please complete your profile information and submit for verification. All features will be unlocked once approved by admin.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.orange),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Later",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          controller.changeIndex(4);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Complete Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => Loginpage());
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: const Color(0xFF199A8E),
              ),
              const SizedBox(height: 16),
              Text(
                "Loading your profile...",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Obx(() => Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          isVerified ? "Welcome Doctor" : "Welcome Doctor (Pending Approval)",
          style: TextStyle(
            color: isVerified ? const Color(0xFF199A8E) : Colors.orange.shade700,
            fontFamily: "bolditalic",
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0XFF199A8E)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isVerified ? Colors.green : Colors.orange,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVerified ? Icons.verified : Icons.pending_outlined,
                  color: isVerified ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  isVerified ? "Verified" : "Pending",
                  style: TextStyle(
                    color: isVerified ? Colors.green : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: controller.currentIndex.value,
            children: pages,
          ),
          if (!isVerified && controller.currentIndex.value != 4)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            color: Colors.orange,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Feature Locked",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Complete your profile verification to unlock all features",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/doctor_icons/dashboard.png', 0),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/doctor_icons/appointments.png', 1),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/doctor_icons/medicalrecords.png', 2),
            label: 'Medical Records',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/doctor_icons/chats.png', 3),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/doctor_icons/profilesetting.png', 4),
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
        onTap: (index) {
          if (!isVerified && index != 4) {
            _showVerificationDialog();
          } else {
            controller.changeIndex(index);
          }
        },
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
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: profileImageUrl != null && profileImageUrl!.isNotEmpty
                                ? Image.network(
                              profileImageUrl!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: const Color(0xFF199A8E),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                                : Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isDoctor
                            ? "Dr. ${username ?? "Doctor"}"
                            : "Not a Doctor",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isDoctor ? (email ?? "No Email") : "Not Authorized",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isVerified
                              ? Colors.green.withOpacity(0.9)
                              : Colors.orange.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isVerified ? Icons.verified : Icons.pending_outlined,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isVerified ? "Admin Verified" : "Pending Approval",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildDrawerTile(
              icon: "assets/doctor_icons/dashboard.png",
              label: "Dashboard",
              isLocked: !isVerified,
              onTap: () {
                if (!isVerified) {
                  Get.back();
                  _showVerificationDialog();
                } else {
                  controller.changeIndex(0);
                  Get.back();
                }
              },
            ),
            _buildDivider(),
            _buildDrawerTile(
              icon: "assets/doctor_icons/appointments.png",
              label: "Appointments",
              isLocked: !isVerified,
              onTap: () {
                if (!isVerified) {
                  Get.back();
                  _showVerificationDialog();
                } else {
                  Get.to(() => AppointmentPage());
                }
              },
            ),
            _buildDivider(),
            _buildDrawerTile(
              icon: "assets/doctor_icons/medicalrecords.png",
              label: "Patient Records",
              isLocked: !isVerified,
              onTap: () {
                if (!isVerified) {
                  Get.back();
                  _showVerificationDialog();
                }
              },
            ),
            _buildDivider(),
            _buildDrawerTile(
              icon: "assets/doctor_icons/chats.png",
              label: "Messages",
              isLocked: !isVerified,
              onTap: () {
                if (!isVerified) {
                  Get.back();
                  _showVerificationDialog();
                } else {
                  controller.changeIndex(1);
                  Get.back();
                }
              },
            ),
            _buildDivider(),
            _buildDrawerTile(
              icon: "assets/doctor_icons/money.png",
              label: "Earnings",
              isLocked: !isVerified,
              onTap: () {
                if (!isVerified) {
                  Get.back();
                  _showVerificationDialog();
                }
              },
            ),
            _buildDivider(),
            _buildDrawerTile(
              icon: "assets/doctor_icons/available.png",
              label: "Availability Settings",
              isLocked: !isVerified,
              onTap: () {
                if (!isVerified) {
                  Get.back();
                  _showVerificationDialog();
                } else {
                  controller.changeIndex(2);
                  Get.back();
                }
              },
            ),
            _buildDivider(),
            _buildDrawerTile(
              icon: "assets/doctor_icons/profilesetting.png",
              label: "Profile",
              isLocked: false,
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
    final isLocked = !isVerified && index != 4;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0x1A199A8E) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          ColorFiltered(
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
          if (isLocked)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 8,
                ),
              ),
            ),
        ],
      ),
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
    bool isLocked = false,
  }) {
    return ListTile(
      leading: Stack(
        children: [
          Image.asset(
              icon,
              height: 24,
              width: 24,
              color: isLocked ? Colors.grey : const Color(0XFF199A8E)
          ),
          if (isLocked)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isLocked ? Colors.grey : const Color(0XFF199A8E),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: isLocked ? Colors.grey : const Color(0XFF199A8E)
      ),
      onTap: onTap,
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
