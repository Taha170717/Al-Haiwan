import 'package:al_haiwan/repository/bottomNav/bottomNavScreen.dart';
import 'package:al_haiwan/repository/screens/login/loginpage.dart';
import 'package:al_haiwan/repository/screens/resetpassword/createnewpass.dart';
import 'package:al_haiwan/repository/screens/resetpassword/verfication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../admin/views/adminside.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  String selectedResetInput = "";
  bool isResetByEmail = true;

  // Register User
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
      showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.message ?? "Registration failed");
    }
  }

  // Login User
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      isLoading.value = false;

      // Check if this is the Admin's email
      if (userCredential.user?.email == 'tahazafar112@gmail.com') {
        Get.offAll(() => AdminScreen()); // Replace with your actual Admin screen
      } else {
        showLoginSuccessDialog();
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar("Login Error", e.message ?? "Login failed");
    }
  }


  // Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return;
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
          'username': userCredential.user?.displayName ?? '',
          'email': userCredential.user?.email ?? '',
          'phone': userCredential.user?.phoneNumber ?? '',
          'isDoctor': false,
          'createdAt': Timestamp.now(),
        });
      }

      isLoading.value = false;
      showLoginSuccessDialog();
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar("Google Sign-In Error", e.message ?? "Something went wrong");
    }
  }

  // ----------- PASSWORD RESET FLOW -----------

  Future<void> sendResetCode({
    required String input,
    required bool isEmail,
  }) async {
    try {
      isLoading.value = true;
      selectedResetInput = input;
      isResetByEmail = isEmail;

      if (isEmail) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: input);
        Get.snackbar("Code Sent", "Password reset email sent.");
        Get.to(() => Verification());
      } else {
        // Dummy handling for phone (you need to implement Firebase Phone Auth)
        Get.snackbar("Code Sent", "A code was sent to your phone number.");
        Get.to(() => Verification());
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to send reset code");
    } finally {
      isLoading.value = false;
    }
  }

  void verifyResetCode(String code) {
    // Dummy code check (6-digit verification)
    if (code.length == 6) {
      Get.to(() => CreateNewPass());
    } else {
      Get.snackbar("Invalid Code", "Please enter a valid 6-digit code.");
    }
  }

  Future<void> resetPassword(String newPassword) async {
    try {
      isLoading.value = true;

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // If user is not logged in, ask them to log in again or send email reset
        Get.snackbar("Error", "You need to log in again to reset password.");
      } else {
        await user.updatePassword(newPassword);
        showPasswordResetDialog();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to reset password.");
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------ DIALOGS ------------------

  void showLoginSuccessDialog() {
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = user?.email == 'tahazafar112@gmail.com'; // Replace with actual admin email

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: Color(0XFFF5F8FF),
                radius: 30,
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
                onPressed: () {
                  if (isAdmin) {
                    Get.offAll(() => AdminScreen()); // 👈 Replace with actual admin screen
                  } else {
                    Get.offAll(() => BottomNavScreen());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0XFF199A8E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("Continue", style: TextStyle(color: Colors.white)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: Color(0XFFF5F8FF),
                radius: 30,
                child: Icon(Icons.check, size: 60, color: Color(0xFF199A8E)),
              ),
              SizedBox(height: 16),
              Text("Success!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Your account has been successfully registered.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.offAll(Loginpage()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0XFF199A8E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("Login", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showPasswordResetDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: Color(0XFFF5F8FF),
                radius: 30,
                child: Icon(Icons.lock_open, size: 60, color: Color(0xFF199A8E)),
              ),
              SizedBox(height: 16),
              Text("Password Updated!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Your password has been successfully changed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.offAll(Loginpage()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0XFF199A8E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("Go to Login", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
