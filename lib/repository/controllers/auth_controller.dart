import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;

  Future<void> registerUser({
    required String username,
    required String email,
    required String phone,
    required String password,
    required bool isDoctor,
  }) async {
    try {
      isLoading.value = true;

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'username': username,
        'email': email,
        'phone': phone,
        'isDoctor': isDoctor,
        'createdAt': Timestamp.now(),
      });

      isLoading.value = false;

      Get.back(); // Close loading
      showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.message ?? "Unknown error");
    }
  }

  void showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0XFFF5F8FF),
                ),
                padding: EdgeInsets.all(12),
                child: Icon(Icons.check, size: 60, color: Color(0xFF199A8E)),
              ),
              SizedBox(height: 16),
              Text("Success!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Your account has been successfully registered",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.offAllNamed('/login'), // Use route if setup or replace with LoginPage()
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0XFF199A8E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("Login", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
