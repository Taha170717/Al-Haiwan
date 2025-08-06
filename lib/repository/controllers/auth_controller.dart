import 'dart:math';
import 'package:al_haiwan/repository/bottomNav/bottomNavScreen.dart';
import 'package:al_haiwan/repository/screens/resetpassword/verfication.dart';
import 'package:al_haiwan/repository/screens/login/loginpage.dart';
import 'package:al_haiwan/repository/screens/resetpassword/createnewpass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../../admin/views/adminside.dart';
import '../../doctor/views/doctorside.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate a 6-digit OTP
  String _generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Send OTP to email
  Future<void> sendResetCode({
    required String email,
    required bool isEmail,
  }) async {
    try {
      isLoading.value = true;
      final otp = _generateOTP();

      final smtpServer = gmail(
        'tahazafar112@gmail.com',
        'fyua tkso jhpq ncmv', // Use env var in production
      );

      final message = Message()
        ..from = Address('tahazafar112@gmail.com', 'Al-Haiwan App')
        ..recipients.add(email)
        ..subject = 'Your OTP Code for Password Reset'
        ..text = 'Your OTP code is: $otp.\n\nIt is valid for 5 minutes.';

      await send(message, smtpServer);

      await _firestore.collection('otp_verifications').doc(email).set({
        'otp': otp,
        'createdAt': FieldValue.serverTimestamp(),
        'used': false,
      });

      Get.snackbar("Success", "OTP sent to your email.");
      Get.to(() => Verification(contactInfo: email));
    } catch (e) {
      Get.snackbar("Error", "Failed to send OTP: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP
  Future<void> verifyResetCode({
    required String contactInfo,
    required String userOtp,
  }) async {
    try {
      isLoading.value = true;
      final doc = await _firestore.collection('otp_verifications').doc(contactInfo).get();

      if (!doc.exists) {
        Get.snackbar("Error", "No OTP found. Please request a new one.");
        return;
      }

      final data = doc.data();
      final storedOtp = data?['otp'];
      final createdAt = data?['createdAt'] as Timestamp?;
      final used = data?['used'] ?? false;

      if (used == true) {
        Get.snackbar("Error", "OTP has already been used.");
        return;
      }

      if (storedOtp != userOtp) {
        Get.snackbar("Error", "Incorrect OTP.");
        return;
      }

      if (createdAt == null ||
          DateTime.now().difference(createdAt.toDate()).inMinutes > 5) {
        Get.snackbar("Error", "OTP has expired.");
        return;
      }

      await _firestore.collection('otp_verifications').doc(contactInfo).update({'used': true});

      Get.to(() => CreateNewPass(email: contactInfo, resetCode: '', destination: '',));
    } catch (e) {
      Get.snackbar("Error", "Failed to verify OTP: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset password after OTP
  Future<void> resetPassword(String newPassword) async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;

      if (user != null) {
        await user.updatePassword(newPassword);
        Get.snackbar("Success", "Password has been reset successfully.");
        Get.offAll(() => Loginpage());
      } else {
        Get.snackbar("Error", "No user is logged in.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to reset password: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Re-authenticate and reset password
  Future<void> resetPasswordWithReauth({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: oldPassword,
      );

      await userCredential.user?.updatePassword(newPassword);

      Get.snackbar("Success", "Password reset successfully.");
      Get.offAll(() => Loginpage());
    } catch (e) {
      Get.snackbar("Error", "Reset failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Register
  Future<void> registerUser({
    required String username,
    required String email,
    required String phone,
    required String password,
    required bool isDoctor,
  }) async {
    try {
      isLoading.value = true;

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'phone': phone,
        'isDoctor': isDoctor,
        'createdAt': Timestamp.now(),
      });

      Get.snackbar("Success", "Registration completed!");
      showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Unknown error occurred.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Login
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = userCredential.user!.uid;

      // Admin Check
      if (email == "tahazafar112@gmail.com") {
        Get.snackbar("Success", "Admin login successful!");
        Get.offAll(() => AdminScreen());
        return;
      }

      // Check Firestore for role
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        Get.snackbar("Error", "User record not found in database.");
        return;
      }

      final isDoctor = userDoc['isDoctor'] ?? false;

      Get.snackbar("Success", "Logged in successfully!");
      showLoginSuccessDialog(isDoctor: isDoctor);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login Error", e.message ?? "Unknown error.");
    } finally {
      isLoading.value = false;
    }
  }


  /// Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': userCredential.user!.displayName ?? '',
          'email': userCredential.user!.email ?? '',
          'phone': userCredential.user!.phoneNumber ?? '',
          'isDoctor': false,
          'createdAt': Timestamp.now(),
        });
      }

      Get.snackbar("Success", "Google Sign-In successful.");
      showLoginSuccessDialog(isDoctor: false);
    } catch (e) {
      Get.snackbar("Error", "Google Sign-In failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Dialogs
  void showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF199A8E), size: 60),
              const SizedBox(height: 10),
              const Text("Registration Successful!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.offAll(() => Loginpage()),
                child: const Text("Login", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showLoginSuccessDialog({required bool isDoctor}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF199A8E), size: 60),
              const SizedBox(height: 20),
              const Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF199A8E)),
              ),
              const SizedBox(height: 10),
              const Text(
                "Login Successful. You're being redirected...",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF199A8E),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text("Continue", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  if (isDoctor) {
                    Get.offAll(() => DoctorScreen());
                  } else {
                    Get.offAll(() => BottomNavScreen());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}
