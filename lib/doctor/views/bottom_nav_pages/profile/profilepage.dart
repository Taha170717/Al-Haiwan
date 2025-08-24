import 'package:al_haiwan/user/repository/screens/login/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'doctor_profile_management_screen.dart'; // Import Firestore

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  String? profilePicUrl;
  String? doctorName;
  String? specialty;
  String? email;

  bool isLoading = true;

  Future<void> _loadDoctorData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctor_verification_requests')
          .doc(user.uid)
          .get();
      final data = doc.data();
      setState(() {
        profilePicUrl = data?['documents']?['profilePicture'] ?? '';
        doctorName = data?['basicInfo']?['fullName'] ?? '';
        specialty = data?['professionalDetails']?['specialization'] ?? '';
        email = data?['basicInfo']?['email'] ?? user.email ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); 
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Loginpage()), 
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Failed: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBFA),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF199A8E), Color(0xFF53B7A4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: screen.height * 0.08),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: screen.width * 0.16,
                          backgroundImage: profilePicUrl != null &&
                                  profilePicUrl!.isNotEmpty
                              ? NetworkImage(profilePicUrl!)
                              : AssetImage('assets/images/default_doctor.png')
                                  as ImageProvider,
                          backgroundColor: Colors.white,
                  ),
                  SizedBox(height: screen.height * 0.02),
                  Text(
                          doctorName ?? 'Doctor',
                          style: TextStyle(
                      fontSize: screen.width * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screen.height * 0.007),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                            specialty ?? 'Specialization',
                            style: TextStyle(
                          fontSize: screen.width * 0.04, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: screen.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email,
                          color: Colors.white70, size: screen.width * 0.045),
                      SizedBox(width: 8),
                      Text(
                              email ?? '',
                              style: TextStyle(
                            color: Colors.white70,
                            fontSize: screen.width * 0.037),
                      ),
                    ],
                  ),
                  SizedBox(height: screen.height * 0.02),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.to(()=> DoctorProfileManagementScreen());
                    },
                    icon: Icon(Icons.edit, color: Color(0xFF199A8E)),
                    label: Text('Edit Profile',
                        style: TextStyle(
                            color: Color(0xFF199A8E),
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      foregroundColor: Color(0xFF199A8E),
                      minimumSize: Size(screen.width * 0.5, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screen.height * 0.09),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screen.width * 0.09),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: EdgeInsets.all(screen.width * 0.05),
                      child: Column(
                        children: [
                          ListTile(
                            leading:
                                Icon(Icons.security, color: Color(0xFF199A8E)),
                            title: Text("Account Settings",
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            trailing: Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Account Settings - Coming Soon')));
                            },
                          ),
                          Divider(),
                          ListTile(
                            leading:
                                Icon(Icons.logout, color: Colors.redAccent),
                            title: Text('Logout',
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w700)),
                            trailing: Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () => _showLogoutDialog(context),
                          ),
                        ],
                      ),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.06,
                vertical: MediaQuery.of(context).size.height * 0.035),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red.shade100,
                  radius: MediaQuery.of(context).size.width * 0.09,
                  child: Icon(Icons.warning_rounded,
                      color: Colors.red.shade700,
                      size: MediaQuery.of(context).size.width * 0.09),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                Text(
                  "Logout Confirmation",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.052,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  "Are you sure you want to log out?",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.041,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal,
                          side: BorderSide(color: Colors.teal, width: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.015),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.015),
                        ),
                        child: const Text(
                          "Logout",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}