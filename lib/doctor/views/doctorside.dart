import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:al_haiwan/repository/screens/login/loginpage.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => Loginpage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Doctor Dashboard',
          style: TextStyle(
            color: Color(0XFF199A8E),
            fontFamily: "bolditalic",
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Color(0XFF199A8E)),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Welcome to the Doctor Dashboard',
          style: TextStyle(
            fontSize: 24,
            color: Color(0XFF199A8E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
