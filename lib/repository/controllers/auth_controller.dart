import 'package:al_haiwan/repository/bottomNav/bottomNavScreen.dart';
import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/home/homescreen.dart';
import 'package:al_haiwan/repository/screens/login/loginpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

      Future.delayed(Duration(milliseconds: 200), () {
        showSuccessDialog();
      });
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.message ?? "Unknown error");
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      isLoading.value = false;

      Future.delayed(Duration(milliseconds: 200), () {
        showLoginSuccessDialog();
      });
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar("Login Error", e.message ?? "Unknown error");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return; // User cancelled sign-in
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': userCredential.user!.displayName ?? '',
          'email': userCredential.user!.email ?? '',
          'phone': userCredential.user!.phoneNumber ?? '',
          'isDoctor': false,
          'createdAt': Timestamp.now(),
        });
      }

      isLoading.value = false;

      Future.delayed(Duration(milliseconds: 200), () {
        showLoginSuccessDialog();
      });
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar("Google Sign-In Error", e.message ?? "Unknown error");
    }
  }

  void showLoginSuccessDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
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
                child: Icon(Icons.check_circle_outline,
                    size: 60, color: Color(0xFF199A8E)),
              ),
              SizedBox(height: 16),
              Text("Login Successful!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("You have successfully logged into your account.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.offAll(() => BottomNavScreen()), // Replace with your Home route
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0XFF199A8E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  minimumSize: Size(double.infinity, 50),
                ),
                child:
                Text("Continue", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void showSuccessDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
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
              Text("Your Account Has Been Successfully Registered",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.offAll(Loginpage()), // Or Get.offAll(Loginpage())
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
