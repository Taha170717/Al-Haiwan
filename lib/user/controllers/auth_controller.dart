import 'dart:math';
import 'package:al_haiwan/user/repository/bottomNav/bottomNavScreen.dart';
import 'package:al_haiwan/user/repository/screens/resetpassword/verfication.dart';
import 'package:al_haiwan/user/repository/screens/login/loginpage.dart';
import 'package:al_haiwan/user/repository/screens/resetpassword/createnewpass.dart';
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

  // Helper method for beautiful snackbars
  void _showSnackbar({
    required String title,
    required String message,
    required SnackbarType type,
    Duration? duration,
  }) {
    Color backgroundColor;
    Color iconColor;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = Color(0xFF4CAF50);
        iconColor = Colors.white;
        icon = Icons.check_circle_rounded;
        break;
      case SnackbarType.error:
        backgroundColor = Color(0xFFE53E3E);
        iconColor = Colors.white;
        icon = Icons.error_rounded;
        break;
      case SnackbarType.warning:
        backgroundColor = Color(0xFFFF9800);
        iconColor = Colors.white;
        icon = Icons.warning_rounded;
        break;
      case SnackbarType.info:
        backgroundColor = Color(0xFF199A8E);
        iconColor = Colors.white;
        icon = Icons.info_rounded;
        break;
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      icon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: 16,
      duration: duration ?? Duration(seconds: 4),
      animationDuration: Duration(milliseconds: 800),
      forwardAnimationCurve: Curves.elasticOut,
      reverseAnimationCurve: Curves.fastOutSlowIn,
      boxShadows: [
        BoxShadow(
          color: backgroundColor.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
      mainButton: TextButton(
        onPressed: () => Get.closeCurrentSnackbar(),
        child: Icon(
          Icons.close_rounded,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
      ),
    );
  }

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
        _showSnackbar(
          title: "Account Not Found",
          message: "No account found with this phone number",
          type: SnackbarType.error,
        );
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
          _showSnackbar(
            title: "Auto-Verification Complete",
            message: "Phone number verified automatically",
            type: SnackbarType.success,
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Phone verification failed: ${e.message}"); // Debugging Log
          _showSnackbar(
            title: "Verification Failed",
            message: "Failed to send OTP: ${e.message}",
            type: SnackbarType.error,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          print("OTP successfully sent to phone: $phoneNumber"); // Debugging Log

          _showSnackbar(
            title: "OTP Sent Successfully",
            message: "Please check your phone for the verification code",
            type: SnackbarType.success,
          );

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
      _showSnackbar(
        title: "Network Error",
        message: "Failed to send OTP. Please check your connection",
        type: SnackbarType.error,
      );
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

      _showSnackbar(
        title: "Verification Successful",
        message: "Phone number verified! You can now reset your password",
        type: SnackbarType.success,
      );

      // Navigate to password reset screen with Email linked
      Get.to(() => CreateNewPass(
        email: emailLinked,
        isEmail: true, resetCode: '', destination: '', // To show old password if needed
      ));
    } catch (e) {
      _showSnackbar(
        title: "Verification Failed",
        message: "Invalid OTP. Please try again",
        type: SnackbarType.error,
      );
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

      // Delete old OTP if it exists
      final existingDoc = await otpRef.get();
      if (existingDoc.exists) {
        await otpRef.delete();
      }

      // Email setup
      final smtpServer = gmail(
        'tahazafar112@gmail.com',
        'fyua tkso jhpq ncmv', // Store in env/secure vault in production
      );

      final message = Message()
        ..from = Address('tahazafar112@gmail.com', 'Al-Haiwan App')
        ..recipients.add(email)
        ..subject = 'Your OTP Code for Password Reset'
        ..text = 'Your OTP code is: $otp.\n\nThis code is valid for 5 minutes.';

      // Send the email
      await send(message, smtpServer);

      // Save OTP to Firestore
      await otpRef.set({
        'otp': otp,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(Duration(minutes: 5))),
        'used': false,
      });

      _showSnackbar(
        title: "OTP Sent Successfully",
        message: "Please check your email for the verification code",
        type: SnackbarType.success,
      );

      Get.to(() => Verification(contactInfo: email, isEmail: true, emailLinked: '',));
    } catch (e) {
      _showSnackbar(
        title: "Email Send Failed",
        message: "Failed to send OTP. Please try again",
        type: SnackbarType.error,
      );
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
        _showSnackbar(
          title: "OTP Not Found",
          message: "No OTP found. Please request a new one",
          type: SnackbarType.warning,
        );
        return;
      }


      final data = doc.data();
      final storedOtp = data?['otp'];
      final createdAt = data?['createdAt'] as Timestamp?;
      final used = data?['used'] ?? false;

      if (used == true) {
        _showSnackbar(
          title: "OTP Already Used",
          message: "This OTP has already been used. Please request a new one",
          type: SnackbarType.warning,
        );
        return;
      }

      if (storedOtp != userOtp) {
        _showSnackbar(
          title: "Incorrect OTP",
          message: "The OTP you entered is incorrect. Please try again",
          type: SnackbarType.error,
        );
        return;
      }

      if (createdAt == null ||
          DateTime.now().difference(createdAt.toDate()).inMinutes > 5) {
        _showSnackbar(
          title: "OTP Expired",
          message: "Your OTP has expired. Please request a new one",
          type: SnackbarType.warning,
        );
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

      _showSnackbar(
        title: "OTP Verified Successfully",
        message: "You can now create a new password",
        type: SnackbarType.success,
      );

      Get.to(() => CreateNewPass(email: contactInfo, resetCode: '', destination: '', isEmail: true,));
    } catch (e) {
      _showSnackbar(
        title: "Verification Error",
        message: "Failed to verify OTP. Please try again",
        type: SnackbarType.error,
      );
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

        _showSnackbar(
          title: "Password Reset Successful",
          message: "Your password has been updated successfully",
          type: SnackbarType.success,
        );

        Get.offAll(() => Loginpage());
      } else {
        _showSnackbar(
          title: "Session Expired",
          message: "Please restart the password reset process",
          type: SnackbarType.warning,
        );
      }
    } catch (e) {
      _showSnackbar(
        title: "Password Reset Failed",
        message: "Failed to reset password. Please try again",
        type: SnackbarType.error,
      );
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

      _showSnackbar(
        title: "Password Updated",
        message: "Your password has been changed successfully",
        type: SnackbarType.success,
      );

      Get.offAll(() => Loginpage());
    } catch (e) {
      _showSnackbar(
        title: "Password Change Failed",
        message:
        "Failed to change password. Please check your current password",
        type: SnackbarType.error,
      );
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
        'status': 'Pending',
        'isVerified': 'false',
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
      _showSnackbar(
        title: "Registration Successful",
        message: "Welcome to Al-Haiwan! Your account has been created",
        type: SnackbarType.success,
        duration: Duration(seconds: 3),
      );

      showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration failed";
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already registered";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password is too weak";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address";
      }

      _showSnackbar(
        title: "Registration Failed",
        message: errorMessage,
        type: SnackbarType.error,
      );
    } catch (e) {
      // If Firestore write failed after auth creation, try to rollback the auth user
      try {
        await _auth.currentUser?.delete();
      } catch (_) {
        // ignore cleanup errors
      }
      _showSnackbar(
        title: "Registration Error",
        message: "Something went wrong. Please try again",
        type: SnackbarType.error,
      );
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
        _showSnackbar(
          title: "Admin Access Granted",
          message: "Welcome back, Administrator!",
          type: SnackbarType.success,
        );
        Get.offAll(() => AdminScreen());
        return;
      }

      // Check Firestore for role
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        _showSnackbar(
          title: "Account Error",
          message: "User record not found. Please contact support",
          type: SnackbarType.error,
        );
        return;
      }

      final isDoctor = userDoc['isDoctor'] ?? false;

      _showSnackbar(
        title: "Login Successful",
        message: "Welcome back! Redirecting to your dashboard",
        type: SnackbarType.success,
      );

      showLoginSuccessDialog(isDoctor: isDoctor, email: '');
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed";
      if (e.code == 'user-not-found') {
        errorMessage = "No account found with this email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This account has been disabled";
      }

      _showSnackbar(
        title: "Login Failed",
        message: errorMessage,
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }


  /// Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _showSnackbar(
          title: "Sign-in Cancelled",
          message: "Google sign-in was cancelled",
          type: SnackbarType.info,
        );
        return;
      }

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

        _showSnackbar(
          title: "Account Created",
          message: "Welcome to Al-Haiwan! Your Google account has been linked",
          type: SnackbarType.success,
        );
      } else {
        _showSnackbar(
          title: "Welcome Back",
          message: "Successfully signed in with Google",
          type: SnackbarType.success,
        );
      }

      showLoginSuccessDialog(isDoctor: false, email: '');
    } catch (e) {
      _showSnackbar(
        title: "Google Sign-in Failed",
        message: "Failed to sign in with Google. Please try again",
        type: SnackbarType.error,
      );
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

enum SnackbarType { success, error, warning, info }
