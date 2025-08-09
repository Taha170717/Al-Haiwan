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
  String _verificationId = "";

  /// Send OTP to phone
  /// Send OTP to phone and link to associated email
  Future<void> sendResetCodeToPhone({required String phoneNumber}) async {
    try {
      isLoading.value = true;
      print("Started fetching user for phone number: $phoneNumber"); // Debugging Log

      // Query Firestore to find the user matching the phone number.
      final userDoc = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .get();

      if (userDoc.docs.isEmpty) {
        print("No user found with this phone number: $phoneNumber");
        Get.snackbar("Error", "No account found with this phone number");
        return;
      }

      final userEmail = userDoc.docs.first["email"];
      print("User email associated with phone: $userEmail."); // Debugging Log

      // Send OTP via Firebase phone authentication.
      print("Starting Firebase phone verification for $phoneNumber."); // Debug Log

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("Auto-verification completed for phone: $phoneNumber"); // Debugging Log
          Get.snackbar("Info", "Auto-verification completed.");
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Phone verification failed: ${e.message}"); // Debugging Log
          Get.snackbar("Error", "Failed to send OTP: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          print("OTP successfully sent to phone: $phoneNumber"); // Debugging Log

          Get.to(() => Verification(
            contactInfo: phoneNumber,
            isEmail: false,
            emailLinked: userEmail,
          ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          print("Code auto-retrieval timeout for phone: $phoneNumber"); // Debugging Log
        },
      );
    } catch (e) {
      print("Error sending reset code to phone: $e"); // Debugging Log
      Get.snackbar("Error", "Failed to send OTP: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify Phone OTP and reset password for associated email
  Future<void> verifyPhoneResetCode({
    required String phoneNumber,
    required String otp,
    required String emailLinked, // Email to reset the password
  }) async {
    try {
      isLoading.value = true;

      final phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      // If verification succeeds
      await _auth.signInWithCredential(phoneAuthCredential);

      // Mark OTP verification as complete in Firestore
      await _firestore.collection('otp_verifications').doc(phoneNumber).set({
        'used': true,
        'verified': true,
        'verifiedAt': FieldValue.serverTimestamp()
      });

      // Navigate to password reset screen with Email linked
      Get.to(() => CreateNewPass(
        email: emailLinked,
        isEmail: true, resetCode: '', destination: '', // To show old password if needed
      ));
    } catch (e) {
      Get.snackbar("Error", "Failed to verify OTP: $e");
    } finally {
      isLoading.value = false;
    }
  }



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
      final otpRef = _firestore.collection('otp_verifications').doc(email);

      // ✅ Delete old OTP if it exists
      final existingDoc = await otpRef.get();
      if (existingDoc.exists) {
        await otpRef.delete();
      }

      // ✅ Email setup
      final smtpServer = gmail(
        'tahazafar112@gmail.com',
        'fyua tkso jhpq ncmv', // ⚠️ Store in env/secure vault in production
      );

      final message = Message()
        ..from = Address('tahazafar112@gmail.com', 'Al-Haiwan App')
        ..recipients.add(email)
        ..subject = 'Your OTP Code for Password Reset'
        ..text = 'Your OTP code is: $otp.\n\nThis code is valid for 5 minutes.';

      // ✅ Send the email
      await send(message, smtpServer);

      // ✅ Save OTP to Firestore
      await otpRef.set({
        'otp': otp,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(Duration(minutes: 5))),
        'used': false,
      });

      // ✅ Navigate to Verification Screen
      Get.snackbar("Success", "OTP sent to your email.");
      Get.to(() => Verification(contactInfo: email, isEmail: true, emailLinked: '',));
    } catch (e) {
      Get.snackbar("Error", "Failed to send OTP: ${e.toString()}");
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
        // 🟢 ADD THIS LINE TO AUTO DELETE
        await _firestore.collection('otp_verifications').doc(contactInfo).delete().catchError((_) {});
        return;
      }


      if (createdAt == null ||
          DateTime.now().difference(createdAt.toDate()).inMinutes > 5) {
        Get.snackbar("Error", "OTP has expired.");
        return;
      }

      await _firestore.collection('otp_verifications').doc(contactInfo).update({'used': true});

      Get.to(() => CreateNewPass(email: contactInfo, resetCode: '', destination: '', isEmail: true,));
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
        final email = user.email;

        await user.updatePassword(newPassword);

        // Delete OTP after successful password reset
        if (email != null) {
          await _firestore.collection('otp_verifications').doc(email).delete().catchError((_) {});
        }

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

      // 1) Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'User could not be created.',
        );
      }

      final uid = user.uid;
      final now = FieldValue.serverTimestamp();

      // 2) Prepare common user data
      final userData = <String, dynamic>{
        'uid': uid,
        'username': username,
        'email': email,
        'phone': phone,
        'isDoctor': isDoctor,
        'role': isDoctor ? 'doctor' : 'user',
        'createdAt': now,
        'updatedAt': now,
      };

      // 3) Prepare doctor data if applicable
      final doctorData = <String, dynamic>{
        'uid': uid,
        'name': username,
        'email': email,
        'phone': phone,
        'status': 'pendingApproval',
        'createdAt': now,
        'updatedAt': now,
      };

      // 4) Write both documents atomically (users + doctors if needed)
      final usersDocRef = _firestore.collection('users').doc(uid);
      final doctorsDocRef = _firestore.collection('doctors').doc(uid);

      final batch = _firestore.batch();
      batch.set(usersDocRef, userData);
      if (isDoctor) {
        batch.set(doctorsDocRef, doctorData);
      }
      await batch.commit();

      // 5) Navigate based on user type
      Get.snackbar('Success', 'Account created successfully');
      showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Registration failed');
    } catch (e) {
      // If Firestore write failed after auth creation, try to rollback the auth user
      try {
        await _auth.currentUser?.delete();
      } catch (_) {
        // ignore cleanup errors
      }
      Get.snackbar('Error', 'Failed to register: $e');
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
      showLoginSuccessDialog(isDoctor: isDoctor, email: '');
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
      showLoginSuccessDialog(isDoctor: false, email: '');
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF199A8E), size: 60),
              const SizedBox(height: 20),
              const Text(
                "Registration Successful!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF199A8E),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Your account has been created successfully.\nYou can now log in to continue.",
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
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text("Login", style: TextStyle(color: Colors.white)),
                onPressed: () => Get.offAll(() => Loginpage()),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void showLoginSuccessDialog({required bool isDoctor, required String email}) {
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
                  }
                  else if (email == "tahazafar112@gmail.com"){
                    Get.offAll(() => AdminScreen());
                  }
                  else {
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